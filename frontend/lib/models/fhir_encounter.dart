import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:intl/intl.dart';

/// Signos vitales del encuentro
class VitalsData {
  final double? weight; // kg
  final double? height; // cm
  final double? heartRate; // lpm
  final double? respiratoryRate; // rpm
  final double? systolic; // mmHg
  final double? diastolic; // mmHg
  final double? temperature; // °C

  VitalsData({
    this.weight,
    this.height,
    this.heartRate,
    this.respiratoryRate,
    this.systolic,
    this.diastolic,
    this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'systolic': systolic,
      'diastolic': diastolic,
      'temperature': temperature,
    };
  }

  factory VitalsData.fromJson(Map<String, dynamic> json) {
    return VitalsData(
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      heartRate: (json['heartRate'] as num?)?.toDouble(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toDouble(),
      systolic: (json['systolic'] as num?)?.toDouble(),
      diastolic: (json['diastolic'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  VitalsData copyWith({
    double? weight,
    double? height,
    double? heartRate,
    double? respiratoryRate,
    double? systolic,
    double? diastolic,
    double? temperature,
  }) {
    return VitalsData(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      temperature: temperature ?? this.temperature,
    );
  }

  /// Retorna un resumen de vitales para mostrar en cards
  String get summaryDisplay {
    final parts = <String>[];
    if (systolic != null && diastolic != null) {
      parts.add(
          'TA: ${systolic!.toStringAsFixed(0)}/${diastolic!.toStringAsFixed(0)}');
    }
    if (heartRate != null) {
      parts.add('FC: ${heartRate!.toStringAsFixed(0)}');
    }
    if (temperature != null) {
      parts.add('T: ${temperature!.toStringAsFixed(1)}°C');
    }
    if (respiratoryRate != null) {
      parts.add('FR: ${respiratoryRate!.toStringAsFixed(0)}');
    }
    return parts.join(' | ');
  }
}

class FhirEncounter {
  final String? id;
  final String status; // pending | active | finalized
  final String? reason;
  final String? motivoConsulta; // Motivo de la consulta
  final String? padecimientoActual; // Padecimiento actual / Enfermedad actual
  final VitalsData? vitals; // Signos vitales
  final String? diagnostico; // Diagnóstico
  final String? planTratamiento; // Plan de tratamiento
  final DateTime? start;
  final DateTime? end;
  final String? patientId;
  final String? patientName;
  final String? practitionerId;
  final String? practitionerName;

  FhirEncounter({
    this.id,
    required this.status,
    this.reason,
    this.motivoConsulta,
    this.padecimientoActual,
    this.vitals,
    this.diagnostico,
    this.planTratamiento,
    this.start,
    this.end,
    this.patientId,
    this.patientName,
    this.practitionerId,
    this.practitionerName,
  });

  factory FhirEncounter.fromJson(Map<String, dynamic> json) {
    DateTime? startDate;
    DateTime? endDate;

    if (json['period'] != null) {
      final period = json['period'] as Map<String, dynamic>;
      if (period['start'] != null) {
        startDate = DateTime.parse(period['start']);
      }
      if (period['end'] != null) {
        endDate = DateTime.parse(period['end']);
      }
    }

    String? patientId;
    String? patientName;
    if (json['subject'] != null) {
      final subject = json['subject'] as Map<String, dynamic>;
      final reference = subject['reference']?.toString();
      if (reference != null && reference.startsWith('Patient/')) {
        patientId = reference.replaceFirst('Patient/', '');
      }
      patientName = subject['display']?.toString();
    }

    String? practitionerId;
    String? practitionerName;
    if (json['participant'] != null && json['participant'] is List) {
      for (final participant in json['participant']) {
        if (participant is Map<String, dynamic> &&
            participant['individual'] != null) {
          final individual = participant['individual'] as Map<String, dynamic>;
          final reference = individual['reference']?.toString();
          if (reference != null && reference.startsWith('Practitioner/')) {
            practitionerId = reference.replaceFirst('Practitioner/', '');
            practitionerName = individual['display']?.toString();
            break;
          }
        }
      }
    }

    String? reason;
    if (json['reasonCode'] != null &&
        json['reasonCode'] is List &&
        (json['reasonCode'] as List).isNotEmpty) {
      final reasonCode = (json['reasonCode'] as List).first;
      if (reasonCode is Map<String, dynamic>) {
        reason = reasonCode['text']?.toString();
        if ((reason == null || reason.isEmpty) &&
            reasonCode['coding'] is List) {
          final codingList = reasonCode['coding'] as List;
          if (codingList.isNotEmpty &&
              codingList.first is Map<String, dynamic>) {
            reason = (codingList.first as Map<String, dynamic>)['display']
                ?.toString();
          }
        }
      }
    }

    // Extractos de extensiones personalizadas
    String? motivoConsulta;
    String? padecimientoActual;
    VitalsData? vitals;
    String? diagnostico;
    String? planTratamiento;

    if (json['extension'] != null && json['extension'] is List) {
      for (var ext in json['extension'] as List) {
        if (ext is Map<String, dynamic>) {
          final url = ext['url'];
          if (url == 'http://custom.system/motivo-consulta') {
            motivoConsulta = ext['valueString'];
          } else if (url == 'http://custom.system/padecimiento-actual') {
            padecimientoActual = ext['valueString'];
          } else if (url == 'http://custom.system/signos-vitales' &&
              ext['valueString'] != null) {
            try {
              final vitalsJson = jsonDecode(ext['valueString']);
              vitals = VitalsData.fromJson(vitalsJson);
            } catch (e) {
              // Ignorar si hay error al parsear
            }
          } else if (url == 'http://custom.system/diagnostico') {
            diagnostico = ext['valueString'];
          } else if (url == 'http://custom.system/plan-tratamiento') {
            planTratamiento = ext['valueString'];
          }
        }
      }
    }

    return FhirEncounter(
      id: json['id']?.toString(),
      status: _fromFhirStatus(json['status']?.toString()),
      reason: reason,
      motivoConsulta: motivoConsulta,
      padecimientoActual: padecimientoActual,
      vitals: vitals,
      diagnostico: diagnostico,
      planTratamiento: planTratamiento,
      start: startDate,
      end: endDate,
      patientId: patientId,
      patientName: patientName,
      practitionerId: practitionerId,
      practitionerName: practitionerName,
    );
  }

  Map<String, dynamic> toFhirJson() {
    final data = <String, dynamic>{
      'resourceType': 'Encounter',
      'status': _toFhirStatus(status),
      'class': {
        'system': 'http://terminology.hl7.org/CodeSystem/v3-ActCode',
        'code': 'AMB',
        'display': 'ambulatory',
      },
    };

    if (id != null) {
      data['id'] = id;
    }

    if (patientId != null) {
      data['subject'] = {
        'reference': 'Patient/$patientId',
        if (patientName != null) 'display': patientName,
      };
    }

    if (start != null || end != null) {
      data['period'] = {
        if (start != null) 'start': start!.toIso8601String(),
        if (end != null) 'end': end!.toIso8601String(),
      };
    }

    if (reason != null && reason!.trim().isNotEmpty) {
      data['reasonCode'] = [
        {
          'text': reason!.trim(),
        }
      ];
    }

    if (practitionerId != null) {
      data['participant'] = [
        {
          'individual': {
            'reference': 'Practitioner/$practitionerId',
            if (practitionerName != null) 'display': practitionerName,
          }
        }
      ];
    }

    // Agregar extensiones personalizadas
    final extensions = <Map<String, dynamic>>[];

    if (motivoConsulta != null && motivoConsulta!.trim().isNotEmpty) {
      extensions.add({
        'url': 'http://custom.system/motivo-consulta',
        'valueString': motivoConsulta!.trim(),
      });
    }

    if (padecimientoActual != null && padecimientoActual!.trim().isNotEmpty) {
      extensions.add({
        'url': 'http://custom.system/padecimiento-actual',
        'valueString': padecimientoActual!.trim(),
      });
    }

    if (vitals != null) {
      extensions.add({
        'url': 'http://custom.system/signos-vitales',
        'valueString': jsonEncode(vitals!.toJson()),
      });
    }

    if (diagnostico != null && diagnostico!.trim().isNotEmpty) {
      extensions.add({
        'url': 'http://custom.system/diagnostico',
        'valueString': diagnostico!.trim(),
      });
    }

    if (planTratamiento != null && planTratamiento!.trim().isNotEmpty) {
      extensions.add({
        'url': 'http://custom.system/plan-tratamiento',
        'valueString': planTratamiento!.trim(),
      });
    }

    if (extensions.isNotEmpty) {
      data['extension'] = extensions;
    }

    return data;
  }

  /// Copia con cambios específicos
  FhirEncounter copyWith({
    String? id,
    String? status,
    String? reason,
    String? motivoConsulta,
    String? padecimientoActual,
    VitalsData? vitals,
    String? diagnostico,
    String? planTratamiento,
    DateTime? start,
    DateTime? end,
    String? patientId,
    String? patientName,
    String? practitionerId,
    String? practitionerName,
  }) {
    return FhirEncounter(
      id: id ?? this.id,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      padecimientoActual: padecimientoActual ?? this.padecimientoActual,
      vitals: vitals ?? this.vitals,
      diagnostico: diagnostico ?? this.diagnostico,
      planTratamiento: planTratamiento ?? this.planTratamiento,
      start: start ?? this.start,
      end: end ?? this.end,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      practitionerId: practitionerId ?? this.practitionerId,
      practitionerName: practitionerName ?? this.practitionerName,
    );
  }

  static String _toFhirStatus(String status) {
    switch (status) {
      case 'pending':
        return 'planned';
      case 'active':
        return 'in-progress';
      case 'finalized':
        return 'finished';
      default:
        return 'planned';
    }
  }

  static String _fromFhirStatus(String? status) {
    switch (status) {
      case 'planned':
        return 'pending';
      case 'in-progress':
        return 'active';
      case 'finished':
        return 'finalized';
      default:
        return 'pending';
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'active':
        return 'Activa';
      case 'finalized':
        return 'Finalizada';
      default:
        return status;
    }
  }

  String get dateTimeDisplay {
    if (start == null) return 'Sin fecha';
    try {
      final datePart = DateFormat('dd MMM yyyy').format(start!);
      final hour = start!.hour.toString().padLeft(2, '0');
      final minute = start!.minute.toString().padLeft(2, '0');
      return '$datePart $hour:$minute';
    } catch (e) {
      final day = start!.day.toString().padLeft(2, '0');
      final month = start!.month.toString().padLeft(2, '0');
      final year = start!.year;
      final hour = start!.hour.toString().padLeft(2, '0');
      final minute = start!.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    }
  }
}
