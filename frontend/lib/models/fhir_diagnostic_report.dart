class FhirDiagnosticReport {
  final String? id;
  final String status;
  final String? category;
  final String code;
  final String? patientId;
  final String? patientName;
  final String? practitionerId;
  final String? practitionerName;
  final DateTime? effectiveDateTime;
  final DateTime? issued;
  final String? conclusion;

  FhirDiagnosticReport({
    this.id,
    required this.status,
    this.category,
    required this.code,
    this.patientId,
    this.patientName,
    this.practitionerId,
    this.practitionerName,
    this.effectiveDateTime,
    this.issued,
    this.conclusion,
  });

  factory FhirDiagnosticReport.fromJson(Map<String, dynamic> json) {
    String? patientId;
    String? practitionerId;

    // Extraer patient ID
    if (json['subject'] != null && json['subject']['reference'] != null) {
      final ref = json['subject']['reference'] as String;
      patientId = ref.replaceAll('Patient/', '');
    }

    // Extraer practitioner ID del performer
    if (json['performer'] != null && json['performer'] is List) {
      final performers = json['performer'] as List;
      if (performers.isNotEmpty && performers[0]['reference'] != null) {
        final ref = performers[0]['reference'] as String;
        practitionerId = ref.replaceAll('Practitioner/', '');
      }
    }

    // Extraer category
    String? category;
    if (json['category'] != null && json['category'] is List) {
      final categories = json['category'] as List;
      if (categories.isNotEmpty &&
          categories[0]['coding'] != null &&
          categories[0]['coding'] is List) {
        final codings = categories[0]['coding'] as List;
        if (codings.isNotEmpty && codings[0]['code'] != null) {
          category = codings[0]['code'] as String;
        }
      }
    }

    // Extraer code
    String code = 'Reporte';
    if (json['code'] != null &&
        json['code']['coding'] != null &&
        json['code']['coding'] is List) {
      final codings = json['code']['coding'] as List;
      if (codings.isNotEmpty && codings[0]['display'] != null) {
        code = codings[0]['display'] as String;
      }
    }

    return FhirDiagnosticReport(
      id: json['id'] as String?,
      status: json['status'] as String? ?? 'registered',
      category: category,
      code: code,
      patientId: patientId,
      patientName: json['_patientName'] as String?,
      practitionerId: practitionerId,
      practitionerName: json['_practitionerName'] as String?,
      effectiveDateTime: json['effectiveDateTime'] != null
          ? DateTime.parse(json['effectiveDateTime'] as String)
          : null,
      issued: json['issued'] != null
          ? DateTime.parse(json['issued'] as String)
          : null,
      conclusion: json['conclusion'] as String?,
    );
  }

  Map<String, dynamic> toFhirJson() {
    final json = <String, dynamic>{
      'resourceType': 'DiagnosticReport',
      'status': status,
      'code': {
        'coding': [
          {
            'display': code,
          }
        ],
        'text': code,
      },
    };

    if (id != null) json['id'] = id;

    if (category != null) {
      json['category'] = [
        {
          'coding': [
            {
              'system': 'http://terminology.hl7.org/CodeSystem/v2-0074',
              'code': category,
            }
          ]
        }
      ];
    }

    if (patientId != null) {
      json['subject'] = {
        'reference': 'Patient/$patientId',
        'display': patientName,
      };
    }

    if (practitionerId != null) {
      json['performer'] = [
        {
          'reference': 'Practitioner/$practitionerId',
          'display': practitionerName,
        }
      ];
    }

    if (effectiveDateTime != null) {
      json['effectiveDateTime'] = effectiveDateTime!.toIso8601String();
    }

    if (issued != null) {
      json['issued'] = issued!.toIso8601String();
    }

    if (conclusion != null && conclusion!.isNotEmpty) {
      json['conclusion'] = conclusion;
    }

    return json;
  }

  String get statusDisplay {
    switch (status) {
      case 'registered':
        return 'Registrado';
      case 'partial':
        return 'Parcial';
      case 'preliminary':
        return 'Preliminar';
      case 'final':
        return 'Final';
      case 'amended':
        return 'Modificado';
      case 'corrected':
        return 'Corregido';
      case 'cancelled':
        return 'Cancelado';
      case 'entered-in-error':
        return 'Error de entrada';
      default:
        return status;
    }
  }

  String get categoryDisplay {
    switch (category) {
      case 'LAB':
        return 'Laboratorio';
      case 'RAD':
        return 'Radiología';
      case 'PATH':
        return 'Patología';
      case 'MB':
        return 'Microbiología';
      case 'GE':
        return 'Genética';
      case 'OTH':
        return 'Otro';
      default:
        return category ?? 'Sin categoría';
    }
  }

  String? get dateDisplay {
    final date = effectiveDateTime ?? issued;
    if (date == null) return null;
    return '${date.day}/${date.month}/${date.year}';
  }
}
