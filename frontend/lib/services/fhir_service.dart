import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fhir_patient.dart';
import '../models/fhir_appointment.dart';
import '../models/fhir_practitioner.dart';
import '../models/fhir_medication_request.dart';
import '../models/fhir_diagnostic_report.dart';
import '../models/user.dart';

class FhirService {
  // ⚙️ CONFIGURACIÓN DINÁMICA DE RED
  // 🔧 SOLO CAMBIA ESTAS IPs si corres en dispositivo móvil
  static const String _mobileBaseUrl = 'http://192.168.0.181:8080/fhir';
  static const String _webBaseUrl = 'http://localhost:8080/fhir';

  // Getter dinámico que detecta la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      return _webBaseUrl; // Web usa localhost
    } else {
      return _mobileBaseUrl; // Móvil usa IP de red
    }
  }

  // Caché en memoria del practitioner ID por userId
  static final Map<String, String> _practitionerCache = {};

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<String?> _getCurrentPractitionerId() async {
    final user = await _getCurrentUser();
    if (user == null || user.id == null) {
      print('ERROR: Usuario no encontrado o sin ID');
      return null;
    }

    final userIdString = user.id.toString();

    // Verificar caché primero
    if (_practitionerCache.containsKey(userIdString)) {
      final cachedId = _practitionerCache[userIdString];
      print(
          '✅ Practitioner encontrado en caché para userId $userIdString: $cachedId');
      return cachedId;
    }

    try {
      // Buscar practitioner existente en el servidor
      print('🔍 Buscando practitioner en servidor para userId: $userIdString');
      final practitioner = await getPractitionerByUserId(userIdString);
      if (practitioner != null && practitioner.id != null) {
        print('✅ Practitioner encontrado en servidor: ${practitioner.id}');
        // Guardar en caché
        _practitionerCache[userIdString] = practitioner.id!;
        return practitioner.id;
      }

      // Si no existe, crear uno nuevo
      print(
          '⚠️ Practitioner no encontrado, creando nuevo para userId: $userIdString');
      final newPractitioner = await createPractitioner(
        FhirPractitioner(
          identifier: userIdString,
          name: user.fullName,
          qualification: 'Médico',
        ),
      );

      if (newPractitioner.id == null) {
        print('❌ ERROR: Practitioner creado sin ID');
        return null;
      }

      print('✅ Practitioner creado exitosamente con ID: ${newPractitioner.id}');
      // Guardar en caché
      _practitionerCache[userIdString] = newPractitioner.id!;
      return newPractitioner.id;
    } catch (e) {
      print('❌ ERROR en _getCurrentPractitionerId: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/fhir+json',
      'Accept': 'application/fhir+json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== PRACTITIONER METHODS ====================

  Future<FhirPractitioner?> getPractitionerByUserId(String userId) async {
    try {
      final headers = await _getHeaders();
      final searchUrl =
          '$baseUrl/Practitioner?identifier=http://hospital.com/user-id|$userId';
      print('   URL de búsqueda: $searchUrl');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: headers,
      );

      print('   Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);
        print('   Total encontrados: ${bundle['total'] ?? 0}');

        if (bundle['entry'] != null && bundle['entry'].isNotEmpty) {
          final practitioner =
              FhirPractitioner.fromJson(bundle['entry'][0]['resource']);
          print(
              '   Practitioner ID: ${practitioner.id}, Identifier: ${practitioner.identifier}');
          return practitioner;
        }
      }
      print('   No se encontró practitioner');
      return null;
    } catch (e) {
      print('   Error en búsqueda: $e');
      return null;
    }
  }

  Future<FhirPractitioner> createPractitioner(
      FhirPractitioner practitioner) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(practitioner.toFhirJson());

      final response = await http.post(
        Uri.parse('$baseUrl/Practitioner'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirPractitioner.fromJson(resource);
      } else {
        throw Exception('Error al crear practitioner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear practitioner: $e');
    }
  }

  // ==================== PATIENT METHODS ====================

  // Obtener todos los pacientes del usuario actual
  Future<List<FhirPatient>> getPatients({int count = 50}) async {
    try {
      final headers = await _getHeaders();
      final user = await _getCurrentUser();

      // Si es admin, obtener todos los pacientes
      if (user != null && user.isAdmin) {
        final response = await http.get(
          Uri.parse('$baseUrl/Patient?_count=$count&_total=accurate'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final bundle = json.decode(response.body);
          if (bundle['entry'] == null) return [];

          final List<FhirPatient> patients = [];
          for (var entry in bundle['entry']) {
            if (entry['resource'] != null) {
              patients.add(FhirPatient.fromJson(entry['resource']));
            }
          }
          return patients;
        } else if (response.statusCode == 404) {
          return [];
        } else {
          throw Exception('Error al obtener pacientes: ${response.statusCode}');
        }
      }

      // Para usuarios normales, filtrar por practitioner
      final practitionerId = await _getCurrentPractitionerId();
      if (practitionerId == null) {
        print('⚠️ No se pudo obtener practitioner ID');
        return []; // No tiene practitioner asignado
      }

      // Usar _total=accurate y sin _sort para evitar problemas de paginación
      // Agregar timestamp para evitar caché del navegador
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final searchUrl =
          '$baseUrl/Patient?general-practitioner=Practitioner/$practitionerId&_count=$count&_total=accurate&_t=$timestamp';
      print('🔍 Buscando pacientes con URL: $searchUrl');

      final response = await http.get(
        Uri.parse(searchUrl),
        headers: headers,
      );

      print('   Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);
        print('   Total encontrados: ${bundle['total'] ?? 0}');
        print('   Entries en bundle: ${bundle['entry']?.length ?? 0}');

        // Debug: ver estructura del bundle
        if (bundle['link'] != null) {
          print('   ⚠️ Bundle tiene links de paginación:');
          for (var link in bundle['link']) {
            print('      ${link['relation']}: ${link['url']}');
          }
        }

        if (bundle['entry'] == null) {
          print('   No hay entries en el bundle');
          return [];
        }

        final List<FhirPatient> patients = [];
        int index = 0;
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            final patient = FhirPatient.fromJson(entry['resource']);
            patients.add(patient);
            print(
                '   [$index] Parseado: ID=${patient.id}, Nombre=${patient.fullName}');
            index++;
          }
        }

        print('✅ Se cargaron ${patients.length} pacientes');
        return patients;
      } else if (response.statusCode == 404) {
        return []; // No hay pacientes aún
      } else {
        throw Exception('Error al obtener pacientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Buscar pacientes por nombre (solo del usuario actual)
  Future<List<FhirPatient>> searchPatients(String query) async {
    try {
      final headers = await _getHeaders();
      final user = await _getCurrentUser();

      String url;
      if (user != null && user.isAdmin) {
        url = '$baseUrl/Patient?name=$query&_count=20';
      } else {
        final practitionerId = await _getCurrentPractitionerId();
        if (practitionerId == null) return [];
        url =
            '$baseUrl/Patient?name=$query&general-practitioner=Practitioner/$practitionerId&_count=20';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);

        if (bundle['entry'] == null) {
          return [];
        }

        final List<FhirPatient> patients = [];
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            patients.add(FhirPatient.fromJson(entry['resource']));
          }
        }

        return patients;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un paciente por ID
  Future<FhirPatient> getPatient(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Patient/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final resource = json.decode(response.body);
        return FhirPatient.fromJson(resource);
      } else if (response.statusCode == 404) {
        throw Exception('Paciente no encontrado');
      } else {
        throw Exception('Error al obtener paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo paciente (vinculado al practitioner del usuario actual)
  Future<FhirPatient> createPatient(FhirPatient patient) async {
    try {
      final user = await _getCurrentUser();

      // Los admins no pueden crear pacientes
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden crear pacientes');
      }

      print('Obteniendo practitioner para crear paciente...');
      final practitionerId = await _getCurrentPractitionerId();
      if (practitionerId == null) {
        throw Exception('No se pudo obtener o crear el registro de médico. '
            'Verifique su conexión y que el servidor FHIR esté funcionando correctamente.');
      }
      print('Practitioner obtenido: $practitionerId, creando paciente...');

      final headers = await _getHeaders();
      final patientJson = patient.toFhirJson();

      // Agregar el practitioner al paciente
      patientJson['generalPractitioner'] = [
        {
          'reference': 'Practitioner/$practitionerId',
        }
      ];

      print('📋 JSON del paciente a crear: ${json.encode(patientJson)}');

      final body = json.encode(patientJson);

      final response = await http.post(
        Uri.parse('$baseUrl/Patient'),
        headers: headers,
        body: body,
      );

      print('📤 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        final createdPatient = FhirPatient.fromJson(resource);
        print('✅ Paciente creado exitosamente con ID: ${createdPatient.id}');
        print(
            '   generalPractitioner en respuesta: ${resource['generalPractitioner']}');
        return createdPatient;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['issue']?[0]?['diagnostics'] ??
            'Error al crear paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear paciente: $e');
    }
  }

  // Actualizar un paciente (mantiene el practitioner original)
  Future<FhirPatient> updatePatient(FhirPatient patient) async {
    if (patient.id == null) {
      throw Exception('El paciente debe tener un ID para actualizar');
    }

    try {
      final user = await _getCurrentUser();

      // Los admins no pueden editar pacientes
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden editar pacientes');
      }

      final headers = await _getHeaders();
      final body = json.encode(patient.toFhirJson());

      final response = await http.put(
        Uri.parse('$baseUrl/Patient/${patient.id}'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirPatient.fromJson(resource);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['issue']?[0]?['diagnostics'] ??
            'Error al actualizar paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar paciente: $e');
    }
  }

  // Eliminar un paciente
  Future<void> deletePatient(String id) async {
    try {
      final user = await _getCurrentUser();

      // Los admins no pueden eliminar pacientes
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden eliminar pacientes');
      }

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/Patient/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 404) {
        throw Exception('Error al eliminar paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar paciente: $e');
    }
  }

  // ==================== APPOINTMENT METHODS ====================

  // Obtener todas las citas
  Future<List<FhirAppointment>> getAppointments(
      {int count = 50, String? status}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/Appointment?_count=$count&_sort=-date';

      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);

        if (bundle['entry'] == null) {
          return [];
        }

        final List<FhirAppointment> appointments = [];
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            appointments.add(FhirAppointment.fromJson(entry['resource']));
          }
        }

        return appointments;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener citas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Buscar citas por paciente
  Future<List<FhirAppointment>> searchAppointmentsByPatient(
      String patientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Appointment?patient=Patient/$patientId&_count=50'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);

        if (bundle['entry'] == null) {
          return [];
        }

        final List<FhirAppointment> appointments = [];
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            appointments.add(FhirAppointment.fromJson(entry['resource']));
          }
        }

        return appointments;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener una cita por ID
  Future<FhirAppointment> getAppointment(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Appointment/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final resource = json.decode(response.body);
        return FhirAppointment.fromJson(resource);
      } else if (response.statusCode == 404) {
        throw Exception('Cita no encontrada');
      } else {
        throw Exception('Error al obtener cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear una nueva cita
  Future<FhirAppointment> createAppointment(FhirAppointment appointment) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(appointment.toFhirJson());

      final response = await http.post(
        Uri.parse('$baseUrl/Appointment'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirAppointment.fromJson(resource);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['issue']?[0]?['diagnostics'] ??
            'Error al crear cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  // Actualizar una cita
  Future<FhirAppointment> updateAppointment(FhirAppointment appointment) async {
    if (appointment.id == null) {
      throw Exception('La cita debe tener un ID para actualizar');
    }

    try {
      final headers = await _getHeaders();
      final body = json.encode(appointment.toFhirJson());

      final response = await http.put(
        Uri.parse('$baseUrl/Appointment/${appointment.id}'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirAppointment.fromJson(resource);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['issue']?[0]?['diagnostics'] ??
            'Error al actualizar cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar cita: $e');
    }
  }

  // Eliminar una cita
  Future<void> deleteAppointment(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/Appointment/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 404) {
        throw Exception('Error al eliminar cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar cita: $e');
    }
  }

  // MedicationRequest methods
  Future<List<FhirMedicationRequest>> getMedicationRequests({
    int count = 100,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final user = await _getCurrentUser();

      var url = '$baseUrl/MedicationRequest?_count=$count';

      if (user != null && !user.isAdmin) {
        final practitionerId = await _getCurrentPractitionerId();
        if (practitionerId != null) {
          url += '&requester=Practitioner/$practitionerId';
        }
      }

      if (status != null && status != 'all') {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List entries = data['entry'] ?? [];
        return entries
            .map((e) => FhirMedicationRequest.fromJson(e['resource']))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener recetas: $e');
    }
  }

  Future<List<FhirMedicationRequest>> searchMedicationRequestsByPatient(
      String patientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/MedicationRequest?subject=Patient/$patientId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List entries = data['entry'] ?? [];
        return entries
            .map((e) => FhirMedicationRequest.fromJson(e['resource']))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al buscar recetas del paciente: $e');
    }
  }

  Future<FhirMedicationRequest?> getMedicationRequest(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/MedicationRequest/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return FhirMedicationRequest.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener receta: $e');
    }
  }

  Future<FhirMedicationRequest> createMedicationRequest(
      FhirMedicationRequest medicationRequest) async {
    final user = await _getCurrentUser();

    if (user != null && user.isAdmin) {
      throw Exception('Los administradores no pueden crear recetas médicas');
    }

    try {
      final practitionerId = await _getCurrentPractitionerId();
      if (practitionerId == null) {
        throw Exception('No se pudo obtener el ID del médico');
      }

      final medicationRequestWithPractitioner = FhirMedicationRequest(
        status: medicationRequest.status,
        intent: medicationRequest.intent,
        medication: medicationRequest.medication,
        patientId: medicationRequest.patientId,
        patientName: medicationRequest.patientName,
        practitionerId: practitionerId,
        practitionerName: user?.fullName,
        dosageInstruction: medicationRequest.dosageInstruction,
        quantityValue: medicationRequest.quantityValue,
        daysSupply: medicationRequest.daysSupply,
        authoredOn: medicationRequest.authoredOn ?? DateTime.now(),
        note: medicationRequest.note,
      );

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/MedicationRequest'),
        headers: headers,
        body: json.encode(medicationRequestWithPractitioner.toFhirJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FhirMedicationRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Error al crear receta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear receta: $e');
    }
  }

  Future<FhirMedicationRequest> updateMedicationRequest(
      FhirMedicationRequest medicationRequest) async {
    final user = await _getCurrentUser();

    if (user != null && user.isAdmin) {
      throw Exception('Los administradores no pueden editar recetas médicas');
    }

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/MedicationRequest/${medicationRequest.id}'),
        headers: headers,
        body: json.encode(medicationRequest.toFhirJson()),
      );

      if (response.statusCode == 200) {
        return FhirMedicationRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Error al actualizar receta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar receta: $e');
    }
  }

  Future<void> deleteMedicationRequest(String id) async {
    final user = await _getCurrentUser();

    if (user != null && user.isAdmin) {
      throw Exception('Los administradores no pueden eliminar recetas médicas');
    }

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/MedicationRequest/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 404) {
        throw Exception('Error al eliminar receta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar receta: $e');
    }
  }

  // ==================== DIAGNOSTIC REPORT METHODS ====================

  Future<List<FhirDiagnosticReport>> getDiagnosticReports({
    int count = 50,
    String? category,
  }) async {
    try {
      final headers = await _getHeaders();
      final user = await _getCurrentUser();

      String url;
      if (user != null && user.isAdmin) {
        // Admin ve todos los reportes
        url = '$baseUrl/DiagnosticReport?_count=$count';
        if (category != null && category.isNotEmpty) {
          url += '&category=$category';
        }
      } else {
        // Usuarios normales solo ven sus reportes
        final practitionerId = await _getCurrentPractitionerId();
        if (practitionerId == null) {
          return [];
        }

        url =
            '$baseUrl/DiagnosticReport?performer=Practitioner/$practitionerId&_count=$count';
        if (category != null && category.isNotEmpty) {
          url += '&category=$category';
        }
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);
        if (bundle['entry'] == null) return [];

        final List<FhirDiagnosticReport> reports = [];
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            final report = FhirDiagnosticReport.fromJson(entry['resource']);

            // Enriquecer con nombre del paciente
            if (report.patientId != null) {
              try {
                final patient = await getPatient(report.patientId!);
                reports.add(FhirDiagnosticReport(
                  id: report.id,
                  status: report.status,
                  category: report.category,
                  code: report.code,
                  patientId: report.patientId,
                  patientName: patient.fullName,
                  practitionerId: report.practitionerId,
                  practitionerName: report.practitionerName,
                  effectiveDateTime: report.effectiveDateTime,
                  issued: report.issued,
                  conclusion: report.conclusion,
                ));
              } catch (e) {
                reports.add(report);
              }
            } else {
              reports.add(report);
            }
          }
        }

        return reports;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error al obtener reportes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  Future<FhirDiagnosticReport> getDiagnosticReport(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('$baseUrl/DiagnosticReport/$id'), headers: headers);

      if (response.statusCode == 200) {
        final resource = json.decode(response.body);
        return FhirDiagnosticReport.fromJson(resource);
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener reporte: $e');
    }
  }

  Future<FhirDiagnosticReport> createDiagnosticReport(
      FhirDiagnosticReport report) async {
    try {
      final user = await _getCurrentUser();
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden crear reportes');
      }

      final practitionerId = await _getCurrentPractitionerId();
      if (practitionerId == null) {
        throw Exception('No se pudo obtener el practitioner del usuario');
      }

      // Agregar practitioner al reporte
      final reportWithPractitioner = FhirDiagnosticReport(
        status: report.status,
        category: report.category,
        code: report.code,
        patientId: report.patientId,
        patientName: report.patientName,
        practitionerId: practitionerId,
        effectiveDateTime: report.effectiveDateTime,
        issued: report.issued ?? DateTime.now(),
        conclusion: report.conclusion,
      );

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/DiagnosticReport'),
        headers: headers,
        body: json.encode(reportWithPractitioner.toFhirJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirDiagnosticReport.fromJson(resource);
      } else {
        throw Exception(
            'Error al crear reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear reporte: $e');
    }
  }

  Future<FhirDiagnosticReport> updateDiagnosticReport(
      FhirDiagnosticReport report) async {
    try {
      final user = await _getCurrentUser();
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden actualizar reportes');
      }

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/DiagnosticReport/${report.id}'),
        headers: headers,
        body: json.encode(report.toFhirJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirDiagnosticReport.fromJson(resource);
      } else {
        throw Exception(
            'Error al actualizar reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al actualizar reporte: $e');
    }
  }

  Future<void> deleteDiagnosticReport(String id) async {
    try {
      final user = await _getCurrentUser();
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden eliminar reportes');
      }

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/DiagnosticReport/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 404) {
        throw Exception(
            'Error al eliminar reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar reporte: $e');
    }
  }
}
