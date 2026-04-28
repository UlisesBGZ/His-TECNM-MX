class FhirEncounter {
  final String? id;
  final String status; // pending | active | finalized
  final String? reason;
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

    return FhirEncounter(
      id: json['id']?.toString(),
      status: _fromFhirStatus(json['status']?.toString()),
      reason: reason,
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

    return data;
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
    final day = start!.day.toString().padLeft(2, '0');
    final month = start!.month.toString().padLeft(2, '0');
    final year = start!.year;
    final hour = start!.hour.toString().padLeft(2, '0');
    final minute = start!.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
