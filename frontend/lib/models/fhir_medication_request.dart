class FhirMedicationRequest {
  final String? id;
  final String status;
  final String intent;
  final String medication;
  final String? patientId;
  final String? patientName;
  final String? practitionerId;
  final String? practitionerName;
  final String? dosageInstruction;
  final int? quantityValue;
  final int? daysSupply;
  final DateTime? authoredOn;
  final String? note;

  FhirMedicationRequest({
    this.id,
    required this.status,
    required this.intent,
    required this.medication,
    this.patientId,
    this.patientName,
    this.practitionerId,
    this.practitionerName,
    this.dosageInstruction,
    this.quantityValue,
    this.daysSupply,
    this.authoredOn,
    this.note,
  });

  factory FhirMedicationRequest.fromJson(Map<String, dynamic> json) {
    DateTime? authored;
    if (json['authoredOn'] != null) {
      authored = DateTime.parse(json['authoredOn']);
    }

    String? patientId;
    String? patientName;
    if (json['subject'] != null && json['subject']['reference'] != null) {
      String ref = json['subject']['reference'];
      if (ref.startsWith('Patient/')) {
        patientId = ref.replaceFirst('Patient/', '');
      }
      patientName = json['subject']['display'];
    }

    String? practitionerId;
    String? practitionerName;
    if (json['requester'] != null && json['requester']['reference'] != null) {
      String ref = json['requester']['reference'];
      if (ref.startsWith('Practitioner/')) {
        practitionerId = ref.replaceFirst('Practitioner/', '');
      }
      practitionerName = json['requester']['display'];
    }

    String medication = 'Medicamento';
    if (json['medicationCodeableConcept'] != null &&
        json['medicationCodeableConcept']['text'] != null) {
      medication = json['medicationCodeableConcept']['text'];
    }

    String? dosage;
    if (json['dosageInstruction'] != null &&
        json['dosageInstruction'] is List &&
        json['dosageInstruction'].isNotEmpty) {
      dosage = json['dosageInstruction'][0]['text'];
    }

    int? quantity;
    int? days;
    if (json['dispenseRequest'] != null) {
      if (json['dispenseRequest']['quantity'] != null) {
        quantity = json['dispenseRequest']['quantity']['value']?.toInt();
      }
      if (json['dispenseRequest']['expectedSupplyDuration'] != null) {
        days =
            json['dispenseRequest']['expectedSupplyDuration']['value']?.toInt();
      }
    }

    String? note;
    if (json['note'] != null &&
        json['note'] is List &&
        json['note'].isNotEmpty) {
      note = json['note'][0]['text'];
    }

    return FhirMedicationRequest(
      id: json['id'],
      status: json['status'] ?? 'active',
      intent: json['intent'] ?? 'order',
      medication: medication,
      patientId: patientId,
      patientName: patientName,
      practitionerId: practitionerId,
      practitionerName: practitionerName,
      dosageInstruction: dosage,
      quantityValue: quantity,
      daysSupply: days,
      authoredOn: authored,
      note: note,
    );
  }

  Map<String, dynamic> toFhirJson() {
    final json = <String, dynamic>{
      'resourceType': 'MedicationRequest',
      'status': status,
      'intent': intent,
      'medicationCodeableConcept': {
        'text': medication,
      },
    };

    if (id != null) json['id'] = id;

    if (patientId != null) {
      json['subject'] = {
        'reference': 'Patient/$patientId',
        if (patientName != null) 'display': patientName,
      };
    }

    if (practitionerId != null) {
      json['requester'] = {
        'reference': 'Practitioner/$practitionerId',
        if (practitionerName != null) 'display': practitionerName,
      };
    }

    if (dosageInstruction != null && dosageInstruction!.isNotEmpty) {
      json['dosageInstruction'] = [
        {'text': dosageInstruction}
      ];
    }

    if (quantityValue != null || daysSupply != null) {
      json['dispenseRequest'] = {};
      if (quantityValue != null) {
        json['dispenseRequest']['quantity'] = {
          'value': quantityValue,
          'unit': 'comprimidos',
        };
      }
      if (daysSupply != null) {
        json['dispenseRequest']['expectedSupplyDuration'] = {
          'value': daysSupply,
          'unit': 'días',
          'system': 'http://unitsofmeasure.org',
          'code': 'd',
        };
      }
    }

    if (authoredOn != null) {
      json['authoredOn'] = authoredOn!.toIso8601String();
    }

    if (note != null && note!.isNotEmpty) {
      json['note'] = [
        {'text': note}
      ];
    }

    return json;
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Activa';
      case 'on-hold':
        return 'En espera';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      case 'entered-in-error':
        return 'Error';
      case 'stopped':
        return 'Detenida';
      case 'draft':
        return 'Borrador';
      default:
        return status;
    }
  }

  String? get dateDisplay {
    if (authoredOn == null) return null;

    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    final day = authoredOn!.day;
    final month = months[authoredOn!.month - 1];
    final year = authoredOn!.year;

    return '$day $month $year';
  }

  String? get supplyDisplay {
    if (quantityValue == null) return null;

    final parts = <String>[];
    parts.add('$quantityValue comp.');
    if (daysSupply != null) {
      parts.add('$daysSupply días');
    }
    return parts.join(' - ');
  }
}
