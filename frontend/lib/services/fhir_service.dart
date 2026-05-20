import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fhir_patient.dart';
import '../models/fhir_appointment.dart';
import '../models/fhir_encounter.dart';
import '../models/fhir_practitioner.dart';
import '../models/fhir_antecedent.dart';
import '../models/user.dart';

class FhirService {
  // ⚙️ CONFIGURACIÓN DINÁMICA DE RED
  // 🔧 SOLO CAMBIA ESTAS IPs si corres en dispositivo móvil
  static const String _mobileBaseUrl = 'http://192.168.0.181:8080/fhir';
  static const String _webBaseUrl = 'http://localhost:8080/fhir';
  static const String _mobileApiBaseUrl = 'http://192.168.0.181:8080/api';
  static const String _webApiBaseUrl = 'http://localhost:8080/api';
  static const String _tokenKey = 'auth_token';

  // Getter dinámico que detecta la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      return _webBaseUrl; // Web usa localhost
    } else {
      return _mobileBaseUrl; // Móvil usa IP de red
    }
  }

  static String get apiBaseUrl {
    if (kIsWeb) {
      return _webApiBaseUrl;
    } else {
      return _mobileApiBaseUrl;
    }
  }

  // Caché en memoria del practitioner ID por userId
  static final Map<String, String> _practitionerCache = {};

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
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

  Future<Map<String, String>> _getApiHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
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

  // Obtener pacientes del registro universal institucional
  Future<List<FhirPatient>> getPatients({int count = 50}) async {
    try {
      final headers = await _getHeaders();

      // Usar _total=accurate y timestamp para evitar caché del navegador
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final searchUrl =
          '$baseUrl/Patient?_count=$count&_total=accurate&_t=$timestamp';
      print('🔍 Buscando pacientes del registro universal con URL: $searchUrl');

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
            final resource = entry['resource'] as Map<String, dynamic>;
            if (resource['active'] == false) {
              continue;
            }

            final patient = FhirPatient.fromJson(resource);
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

  // Buscar pacientes por nombre en el registro universal
  Future<List<FhirPatient>> searchPatients(String query) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/Patient?name=$query&_count=20';

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
            final resource = entry['resource'] as Map<String, dynamic>;
            if (resource['active'] == false) {
              continue;
            }
            patients.add(FhirPatient.fromJson(resource));
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

  // Crear paciente con alta unificada FHIR + EHRbase
  Future<FhirPatient> createPatient(FhirPatient patient) async {
    try {
      final user = await _getCurrentUser();

      // Los admins no pueden crear pacientes
      if (user != null && user.isAdmin) {
        throw Exception('Los administradores no pueden crear pacientes');
      }

      final headers = await _getApiHeaders();
      final requestBody = {
        'identifier': patient.identifier,
        'firstName': patient.firstName,
        'paternalLastName': patient.paternalLastName,
        'maternalLastName': patient.maternalLastName,
        'gender': patient.gender,
        'birthDate': patient.birthDate,
        'bloodType': patient.bloodType,
        'state': patient.state,
        'municipality': patient.municipality,
        'postalCode': patient.postalCode,
        'streetAndNumber': patient.streetAndNumber,
        'colony': patient.colony,
        'phone': patient.phone,
        'email': patient.email,
        'clinicalAntecedents': patient.clinicalAntecedents,
      };

      print('📋 JSON de alta unificada: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/virtual-ehr/patients'),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📤 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        final fhirPatientId = result['fhirPatientId']?.toString();

        if (fhirPatientId == null || fhirPatientId.isEmpty) {
          throw Exception('La alta unificada no devolvio fhirPatientId');
        }

        final createdPatient = await getPatient(fhirPatientId);
        print('✅ Paciente creado exitosamente con ID: ${createdPatient.id}');
        print('🔗 Vínculo EHRbase: ${createdPatient.ehrId ?? result['ehrId']}');
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

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        return;
      }

      // Si el backend bloquea el borrado fisico por integridad referencial,
      // aplicar baja logica (active=false) para conservar trazabilidad clinica.
      if (response.statusCode == 409 || response.statusCode == 422) {
        final patientResponse = await http.get(
          Uri.parse('$baseUrl/Patient/$id'),
          headers: headers,
        );

        if (patientResponse.statusCode != 200) {
          throw Exception(
              'No fue posible desactivar el paciente (lectura fallida)');
        }

        final patientJson =
            json.decode(patientResponse.body) as Map<String, dynamic>;
        patientJson['active'] = false;

        final updateResponse = await http.put(
          Uri.parse('$baseUrl/Patient/$id'),
          headers: headers,
          body: json.encode(patientJson),
        );

        if (updateResponse.statusCode == 200 ||
            updateResponse.statusCode == 201) {
          return;
        }

        String detail =
            'Error al desactivar paciente: ${updateResponse.statusCode}';
        try {
          final errorJson = json.decode(updateResponse.body);
          detail = errorJson['issue']?[0]?['diagnostics'] ?? detail;
        } catch (_) {
          // Mantener mensaje por defecto si no hay OperationOutcome parseable.
        }
        throw Exception(detail);
      }

      String detail = 'Error al eliminar paciente: ${response.statusCode}';
      try {
        final errorJson = json.decode(response.body);
        detail = errorJson['issue']?[0]?['diagnostics'] ?? detail;
      } catch (_) {
        // Mantener mensaje por defecto si no hay OperationOutcome parseable.
      }
      throw Exception(detail);
    } catch (e) {
      throw Exception('Error al eliminar paciente: $e');
    }
  }

  Future<void> saveEncounterComposition({
    required String fhirPatientId,
    required String ehrId,
    required String fhirEncounterId,
    String? motivoConsulta,
    String? padecimientoActual,
    String? diagnostico,
    double? presionSistolica,
    double? presionDiastolica,
    double? pulso,
    double? temperatura,
    double? peso,
    double? talla,
    double? frecuenciaRespiratoria,
  }) async {
    try {
      final headers = await _getApiHeaders();
      final body = <String, dynamic>{
        'ehrId': ehrId,
        'fhirEncounterId': fhirEncounterId,
        if (motivoConsulta != null && motivoConsulta.isNotEmpty)
          'motivoConsulta': motivoConsulta,
        if (padecimientoActual != null && padecimientoActual.isNotEmpty)
          'padecimientoActual': padecimientoActual,
        if (diagnostico != null && diagnostico.isNotEmpty)
          'diagnostico': diagnostico,
        if (presionSistolica != null) 'presionSistolica': presionSistolica,
        if (presionDiastolica != null) 'presionDiastolica': presionDiastolica,
        if (pulso != null) 'pulso': pulso,
        if (temperatura != null) 'temperatura': temperatura,
        if (peso != null) 'peso': peso,
        if (talla != null) 'talla': talla,
        if (frecuenciaRespiratoria != null)
          'frecuenciaRespiratoria': frecuenciaRespiratoria,
      };

      final response = await http.post(
        Uri.parse(
            '$apiBaseUrl/virtual-ehr/patients/$fhirPatientId/ehr-composition'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Composición openEHR guardada: ${result['compositionId']}');
      } else {
        print('⚠️ EHRbase composition respondió: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error al guardar composición openEHR (no crítico): $e');
    }
  }

  Future<Map<String, dynamic>> verifyPatientLinkage(
      String fhirPatientId) async {
    try {
      final headers = await _getApiHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/virtual-ehr/patients/$fhirPatientId/linkage'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'linked': data['linked'] == true,
          'fhirPatientId': data['fhirPatientId'],
          'ehrId': data['ehrId'],
          'linkageNamespace': data['linkageNamespace'],
        };
      }

      throw Exception('Error al verificar enlace: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error al verificar enlace FHIR/EHR: $e');
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

  // ==================== ENCOUNTER METHODS ====================

  Future<List<FhirEncounter>> getEncounters({
    int count = 50,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/Encounter?_count=$count&_sort=-date';

      if (status != null && status.isNotEmpty && status != 'all') {
        final fhirStatus = _mapEncounterStatusToFhir(status);
        url += '&status=$fhirStatus';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);
        if (bundle['entry'] == null) return [];

        final List<FhirEncounter> encounters = [];
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            encounters.add(FhirEncounter.fromJson(entry['resource']));
          }
        }
        return encounters;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener encuentros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<List<FhirEncounter>> searchEncountersByPatient(
      String patientId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Encounter?subject=Patient/$patientId&_count=50'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);
        if (bundle['entry'] == null) return [];

        final List<FhirEncounter> encounters = [];
        for (var entry in bundle['entry']) {
          if (entry['resource'] != null) {
            encounters.add(FhirEncounter.fromJson(entry['resource']));
          }
        }
        return encounters;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error en busqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<FhirEncounter> getEncounter(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Encounter/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final resource = json.decode(response.body);
        return FhirEncounter.fromJson(resource);
      } else if (response.statusCode == 404) {
        throw Exception('Encuentro no encontrado');
      } else {
        throw Exception('Error al obtener encuentro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  Future<FhirEncounter> createEncounter(FhirEncounter encounter) async {
    try {
      final headers = await _getHeaders();
      final user = await _getCurrentUser();
      final practitionerId = await _getCurrentPractitionerId();

      final payload = FhirEncounter(
        status: encounter.status,
        reason: encounter.reason,
        motivoConsulta: encounter.motivoConsulta,
        padecimientoActual: encounter.padecimientoActual,
        vitals: encounter.vitals,
        diagnostico: encounter.diagnostico,
        planTratamiento: encounter.planTratamiento,
        start: encounter.start,
        end: encounter.end,
        patientId: encounter.patientId,
        patientName: encounter.patientName,
        practitionerId: practitionerId,
        practitionerName: user?.fullName,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/Encounter'),
        headers: headers,
        body: json.encode(payload.toFhirJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirEncounter.fromJson(resource);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['issue']?[0]?['diagnostics'] ??
            'Error al crear encuentro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear encuentro: $e');
    }
  }

  Future<FhirEncounter> updateEncounter(FhirEncounter encounter) async {
    if (encounter.id == null) {
      throw Exception('El encuentro debe tener un ID para actualizar');
    }

    try {
      final headers = await _getHeaders();
      final user = await _getCurrentUser();
      final practitionerId = await _getCurrentPractitionerId();

      final payload = FhirEncounter(
        id: encounter.id,
        status: encounter.status,
        reason: encounter.reason,
        motivoConsulta: encounter.motivoConsulta,
        padecimientoActual: encounter.padecimientoActual,
        vitals: encounter.vitals,
        diagnostico: encounter.diagnostico,
        planTratamiento: encounter.planTratamiento,
        start: encounter.start,
        end: encounter.end,
        patientId: encounter.patientId,
        patientName: encounter.patientName,
        practitionerId: practitionerId,
        practitionerName: user?.fullName,
      );

      final response = await http.put(
        Uri.parse('$baseUrl/Encounter/${encounter.id}'),
        headers: headers,
        body: json.encode(payload.toFhirJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirEncounter.fromJson(resource);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['issue']?[0]?['diagnostics'] ??
            'Error al actualizar encuentro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar encuentro: $e');
    }
  }

  Future<void> deleteEncounter(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/Encounter/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 404) {
        throw Exception('Error al eliminar encuentro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar encuentro: $e');
    }
  }

  String _mapEncounterStatusToFhir(String status) {
    switch (status) {
      case 'pending':
        return 'planned';
      case 'active':
        return 'in-progress';
      case 'finalized':
        return 'finished';
      default:
        return status;
    }
  }

  // ==================== ANTECEDENT METHODS ====================

  /// Obtiene todos los antecedentes de un paciente
  Future<List<FhirAntecedent>> getAntecedentsByPatient(String patientId) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/Observation?subject=Patient/$patientId&_count=100';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final bundle = json.decode(response.body);
        if (bundle['entry'] == null) return [];

        final List<FhirAntecedent> antecedents = [];
        for (var entry in bundle['entry']) {
          final resource = entry['resource'];
          if (resource == null) continue;

          try {
            final tags = resource['meta']?['tag'] as List? ?? [];
            final isAntecedent = tags.any((tag) => tag['code'] == 'antecedent');

            if (isAntecedent) {
              antecedents.add(FhirAntecedent.fromJson(resource));
            }
          } catch (e) {
            print('⚠️ Error parsing antecedent: $e');
          }
        }

        return antecedents;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
          'Error al obtener antecedentes: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener antecedentes: $e');
    }
  }

  /// Obtiene el antecedente más reciente de un tipo específico
  Future<FhirAntecedent?> getLatestAntecedentByType(
    String patientId,
    AntecedentType type,
  ) async {
    try {
      final antecedents = await getAntecedentsByPatient(patientId);

      final filtered = antecedents.where((a) => a.type == type).toList();

      if (filtered.isEmpty) return null;

      // Ordenar por fecha de actualización (descendente) para obtener el más reciente
      filtered.sort((a, b) =>
          (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));

      return filtered.first;
    } catch (e) {
      throw Exception('Error al obtener antecedente por tipo: $e');
    }
  }

  /// Crea o actualiza un antecedente (garantiza no duplicados por tipo)
  Future<FhirAntecedent> createOrUpdateAntecedent(
    FhirAntecedent antecedent,
  ) async {
    try {
      final practitionerId = await _getCurrentPractitionerId();
      if (practitionerId == null) {
        throw Exception('No se pudo obtener el practitioner del usuario');
      }

      // Verificar si existe un antecedente del mismo tipo
      final existing = await getLatestAntecedentByType(
        antecedent.patientId,
        antecedent.type,
      );

      final antecedentToSave = existing != null
          ? antecedent.copyWith(
              id: existing.id,
              createdAt: existing.createdAt,
              updatedAt: existing.updatedAt ?? DateTime.now(),
              practitionerId: practitionerId,
            )
          : antecedent.copyWith(
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              practitionerId: practitionerId,
            );

      final headers = await _getHeaders();
      final method = existing != null ? 'PUT' : 'POST';
      final url = existing != null
          ? '$baseUrl/Observation/${existing.id}'
          : '$baseUrl/Observation';

      final response = await (method == 'PUT'
          ? http.put(
              Uri.parse(url),
              headers: headers,
              body: json.encode(antecedentToSave.toFhirJson()),
            )
          : http.post(
              Uri.parse(url),
              headers: headers,
              body: json.encode(antecedentToSave.toFhirJson()),
            ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resource = json.decode(response.body);
        return FhirAntecedent.fromJson(resource);
      } else {
        throw Exception(
            'Error al guardar antecedente: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al guardar antecedente: $e');
    }
  }

  /// Dual-write: guarda antecedente en EHRbase (best effort)
  Future<void> saveAntecedentesEhr({
    required String fhirPatientId,
    required String ehrId,
    required String tipoAntecedente,
    required String contenido,
    String? composerName,
  }) async {
    final url = '$apiBaseUrl/virtual-ehr/patients/$fhirPatientId/antecedentes-composition';
    print('🔵 EHRbase antecedente write — url: $url');
    print('🔵 ehrId: $ehrId | tipo: $tipoAntecedente | composer: $composerName');
    try {
      final headers = await _getApiHeaders();
      final body = <String, dynamic>{
        'ehrId': ehrId,
        'tipoAntecedente': tipoAntecedente,
        'contenido': contenido,
      };
      if (composerName != null && composerName.isNotEmpty) {
        body['composerName'] = composerName;
      }
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      print('✅ EHRbase antecedente response: ${response.statusCode} — ${response.body}');
    } catch (e) {
      print('❌ EHRbase antecedente write failed: $e');
    }
  }

  /// Elimina un antecedente
  Future<void> deleteAntecedent(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/Observation/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 404) {
        throw Exception(
            'Error al eliminar antecedente: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al eliminar antecedente: $e');
    }
  }

  // ⚠️ DEPRECATED: Métodos de DiagnosticReport removidos en Sprint 5
  // Estos métodos existen solo para que el código compile
  // Los archivos legacy (clinical_record_wizard_screen, report_list_screen, etc.)
  // ya no se usan en el nuevo flujo (Pacientes → Vista Clínica → Antecedentes/Encuentros)

  @Deprecated(
      'DiagnosticReport removido. Usar ClinicalAntecedentsSection en su lugar')
  Future<List<dynamic>> getDiagnosticReports({int count = 100}) async {
    throw UnimplementedError(
      'DiagnosticReport fue removido en Sprint 5. '
      'Usa ClinicalAntecedentsSection en su lugar.',
    );
  }

  @Deprecated(
      'DiagnosticReport removido. Usar ClinicalAntecedentsSection en su lugar')
  Future<dynamic> getDiagnosticReport(String id) async {
    throw UnimplementedError(
      'DiagnosticReport fue removido en Sprint 5. '
      'Usa ClinicalAntecedentsSection en su lugar.',
    );
  }

  @Deprecated(
      'DiagnosticReport removido. Usar ClinicalAntecedentsSection en su lugar')
  Future<dynamic> createDiagnosticReport(dynamic report) async {
    throw UnimplementedError(
      'DiagnosticReport fue removido en Sprint 5. '
      'Usa ClinicalAntecedentsSection en su lugar.',
    );
  }

  @Deprecated(
      'DiagnosticReport removido. Usar ClinicalAntecedentsSection en su lugar')
  Future<dynamic> updateDiagnosticReport(dynamic report) async {
    throw UnimplementedError(
      'DiagnosticReport fue removido en Sprint 5. '
      'Usa ClinicalAntecedentsSection en su lugar.',
    );
  }

  @Deprecated(
      'DiagnosticReport removido. Usar ClinicalAntecedentsSection en su lugar')
  Future<void> deleteDiagnosticReport(String id) async {
    throw UnimplementedError(
      'DiagnosticReport fue removido en Sprint 5. '
      'Usa ClinicalAntecedentsSection en su lugar.',
    );
  }
}
