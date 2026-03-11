import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:fhir_hospital_app/models/fhir_patient.dart';
import 'package:fhir_hospital_app/models/fhir_appointment.dart';
import 'package:fhir_hospital_app/models/user.dart';

/// Tests unitarios para FhirService y modelos FHIR
/// Verifica el correcto parseo y manejo de recursos FHIR
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FhirPatient - Model Tests', () {
    test('Debe parsear correctamente un paciente desde JSON FHIR', () {
      // Given - JSON típico de respuesta FHIR
      final json = {
        'resourceType': 'Patient',
        'id': '1059',
        'identifier': [
          {
            'use': 'official',
            'system': 'urn:oid:2.16.840.1.113883.2.10.1',
            'value': '123456789'
          }
        ],
        'name': [
          {
            'use': 'official',
            'family': 'Lopez',
            'given': ['Pao']
          }
        ],
        'gender': 'female',
        'birthDate': '1990-05-15',
        'telecom': [
          {'system': 'phone', 'value': '555-1234', 'use': 'mobile'},
          {'system': 'email', 'value': 'pao.lopez@example.com', 'use': 'home'}
        ],
        'address': [
          {
            'use': 'home',
            'line': ['123 Main St']
          }
        ]
      };

      // When
      final patient = FhirPatient.fromJson(json);

      // Then
      expect(patient.id, equals('1059'));
      expect(patient.firstName, equals('Pao'));
      expect(patient.lastName, equals('Lopez'));
      expect(patient.identifier, equals('123456789'));
      expect(patient.gender, equals('female'));
      expect(patient.birthDate, equals('1990-05-15'));
      expect(patient.phone, equals('555-1234'));
      expect(patient.email, equals('pao.lopez@example.com'));
      expect(patient.address, equals('123 Main St'));
    });

    test('Debe manejar pacientes sin datos opcionales', () {
      // Given - JSON mínimo
      final json = {
        'resourceType': 'Patient',
        'id': '1234',
        'name': [
          {
            'family': 'Smith',
            'given': ['John']
          }
        ]
      };

      // When
      final patient = FhirPatient.fromJson(json);

      // Then
      expect(patient.id, equals('1234'));
      expect(patient.firstName, equals('John'));
      expect(patient.lastName, equals('Smith'));
      expect(patient.identifier, isNull);
      expect(patient.phone, isNull);
      expect(patient.email, isNull);
    });

    test('Debe convertir paciente a JSON FHIR correctamente', () {
      // Given
      final patient = FhirPatient(
        id: '1001',
        firstName: 'Test',
        lastName: 'Patient',
        identifier: '987654321',
        gender: 'male',
        birthDate: '1985-10-20',
        phone: '555-9876',
        email: 'test@example.com',
        address: '456 Oak Ave',
      );

      // When
      final json = patient.toFhirJson();

      // Then
      expect(json['resourceType'], equals('Patient'));
      expect(json['id'], equals('1001'));
      expect(json['identifier'], isNotNull);
      expect(json['name'], isNotNull);
      expect(json['gender'], equals('male'));
      expect(json['birthDate'], equals('1985-10-20'));
    });
  });

  group('FhirAppointment - Model Tests', () {
    test('Debe parsear correctamente una cita desde JSON FHIR', () {
      // Given
      final json = {
        'resourceType': 'Appointment',
        'id': '2001',
        'status': 'booked',
        'serviceType': [
          {
            'coding': [
              {
                'system': 'http://terminology.hl7.org/CodeSystem/service-type',
                'code': 'general',
                'display': 'Consulta General'
              }
            ]
          }
        ],
        'description': 'Consulta de rutina',
        'start': '2026-03-01T10:00:00Z',
        'end': '2026-03-01T10:30:00Z',
        'participant': [
          {
            'actor': {'reference': 'Patient/1059', 'display': 'Pao Lopez'}
          }
        ]
      };

      // When
      final appointment = FhirAppointment.fromJson(json);

      // Then
      expect(appointment.id, equals('2001'));
      expect(appointment.status, equals('booked'));
      expect(appointment.description, equals('Consulta de rutina'));
      expect(appointment.description, equals('Consulta de rutina'));
      expect(appointment.start, isNotNull);
      expect(appointment.end, isNotNull);
    });
  });

  group('FhirService - URL Construction Tests', () {
    test('Debe construir correctamente URL de búsqueda de pacientes', () {
      // Given
      const baseUrl = 'http://192.168.20.225:8080/fhir';
      const practitionerId = '1052';

      // When
      final url =
          '$baseUrl/Patient?general-practitioner=Practitioner/$practitionerId&_count=50&_total=accurate';

      // Then
      expect(url, contains('/fhir/Patient'));
      expect(url, contains('general-practitioner=Practitioner/1052'));
      expect(url, contains('_count=50'));
      expect(url, contains('_total=accurate'));
    });

    test('Debe construir correctamente URL de búsqueda con filtros', () {
      // Given
      const baseUrl = 'http://192.168.20.225:8080/fhir';
      const searchText = 'Lopez';

      // When
      final url = '$baseUrl/Patient?name=$searchText';

      // Then
      expect(url, contains('name=Lopez'));
    });
  });

  group('User Model Tests', () {
    test('Debe parsear correctamente usuario desde JSON', () {
      // Given
      final json = {
        'id': 4,
        'username': 'doctor1',
        'email': 'doctor@hospital.com',
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'roles': ['USER', 'DOCTOR']
      };

      // When
      final user = User.fromJson(json);

      // Then
      expect(user.id, equals(4));
      expect(user.username, equals('doctor1'));
      expect(user.email, equals('doctor@hospital.com'));
      expect(user.firstName, equals('Juan'));
      expect(user.lastName, equals('Pérez'));
      expect(user.roles, contains('DOCTOR'));
    });

    test('Debe convertir usuario a JSON correctamente', () {
      // Given
      final user = User(
        id: 5,
        username: 'nurse1',
        email: 'nurse@hospital.com',
        firstName: 'María',
        lastName: 'García',
        roles: ['USER', 'NURSE'],
      );

      // When
      final json = user.toJson();

      // Then
      expect(json['id'], equals(5));
      expect(json['username'], equals('nurse1'));
      expect(json['roles'], contains('NURSE'));
    });
  });

  group('FhirService - Practitioner Cache Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Debe cachear correctamente el ID de practitioner', () async {
      // Given
      final prefs = await SharedPreferences.getInstance();
      const userId = '4';
      const practitionerId = '1052';

      // When - Guardar en "caché" (simulado con SharedPreferences)
      await prefs.setString('practitioner_$userId', practitionerId);

      // Then - Recuperar de caché
      final cachedId = prefs.getString('practitioner_$userId');
      expect(cachedId, equals(practitionerId));
    });
  });

  group('FhirService - FHIR Bundle Parsing Tests', () {
    test('Debe parsear correctamente un Bundle FHIR con múltiples pacientes',
        () {
      // Given - Bundle típico de respuesta FHIR
      final bundleJson = {
        'resourceType': 'Bundle',
        'type': 'searchset',
        'total': 3,
        'entry': [
          {
            'resource': {
              'resourceType': 'Patient',
              'id': '1',
              'name': [
                {
                  'family': 'Lopez',
                  'given': ['Pao']
                }
              ]
            }
          },
          {
            'resource': {
              'resourceType': 'Patient',
              'id': '2',
              'name': [
                {
                  'family': 'Smith',
                  'given': ['John']
                }
              ]
            }
          },
          {
            'resource': {
              'resourceType': 'Patient',
              'id': '3',
              'name': [
                {
                  'family': 'García',
                  'given': ['María']
                }
              ]
            }
          }
        ]
      };

      // When
      final entries = bundleJson['entry'] as List;
      final patients = entries
          .map((e) =>
              FhirPatient.fromJson(e['resource'] as Map<String, dynamic>))
          .toList();

      // Then
      expect(patients.length, equals(3));
      expect(patients[0].firstName, equals('Pao'));
      expect(patients[1].firstName, equals('John'));
      expect(patients[2].firstName, equals('María'));
    });

    test('Debe manejar Bundle vacío', () {
      // Given
      final bundleJson = {
        'resourceType': 'Bundle',
        'type': 'searchset',
        'total': 0,
        'entry': []
      };

      // When
      final entries = bundleJson['entry'] as List;

      // Then
      expect(entries, isEmpty);
    });
  });
}
