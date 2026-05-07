/// Tipos de antecedentes clínicos
enum AntecedentType {
  heredofamiliar,
  noPatologico,
  ginecoObstetrico,
}

extension AntecedentTypeExtension on AntecedentType {
  String get displayName {
    switch (this) {
      case AntecedentType.heredofamiliar:
        return 'Heredofamiliares';
      case AntecedentType.noPatologico:
        return 'No patológicos';
      case AntecedentType.ginecoObstetrico:
        return 'Ginecoobstétricos';
    }
  }

  String get value {
    switch (this) {
      case AntecedentType.heredofamiliar:
        return 'HEREDOFAMILIAR';
      case AntecedentType.noPatologico:
        return 'NO_PATOLOGICO';
      case AntecedentType.ginecoObstetrico:
        return 'GINECO_OBSTETRICO';
    }
  }

  static AntecedentType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HEREDOFAMILIAR':
        return AntecedentType.heredofamiliar;
      case 'NO_PATOLOGICO':
        return AntecedentType.noPatologico;
      case 'GINECO_OBSTETRICO':
        return AntecedentType.ginecoObstetrico;
      default:
        throw ArgumentError('Unknown antecedent type: $value');
    }
  }
}

/// Modelo de Antecedente Clínico basado en FHIR
/// Se almacena como Observation con categoría personalizada
class FhirAntecedent {
  final String? id;
  final String patientId;
  final AntecedentType type;
  final String content;
  final String? practitionerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'final' para antecedentes activos

  FhirAntecedent({
    this.id,
    required this.patientId,
    required this.type,
    required this.content,
    this.practitionerId,
    required this.createdAt,
    this.updatedAt,
    this.status = 'final',
  });

  /// Convierte el modelo a formato FHIR JSON (Observation)
  Map<String, dynamic> toFhirJson() {
    return {
      'resourceType': 'Observation',
      if (id != null) 'id': id,
      'status': status,
      'category': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'clinical',
              'display': 'Clinical'
            }
          ]
        }
      ],
      'code': {
        'coding': [
          {
            'system': 'http://custom.system/antecedent-type',
            'code': type.value,
            'display': type.displayName
          }
        ],
        'text': 'Antecedente Clínico: ${type.displayName}'
      },
      'subject': {'reference': 'Patient/$patientId'},
      if (practitionerId != null)
        'performer': [
          {'reference': 'Practitioner/$practitionerId'}
        ],
      'effectiveDateTime': createdAt.toIso8601String(),
      'issued': (updatedAt ?? createdAt).toIso8601String(),
      'valueString': content,
      'meta': {
        'tag': [
          {
            'system': 'http://custom.system/record-type',
            'code': 'antecedent',
            'display': 'Antecedent'
          }
        ]
      }
    };
  }

  /// Crea instancia desde JSON FHIR (Observation)
  factory FhirAntecedent.fromJson(Map<String, dynamic> json) {
    String typeStr = 'HEREDOFAMILIAR'; // default
    if (json['code']?['coding'] != null) {
      final coding = List.from(json['code']['coding']);
      if (coding.isNotEmpty && coding[0]['code'] != null) {
        typeStr = coding[0]['code'];
      }
    }

    final patientRef = json['subject']?['reference'] ?? '';
    final patientId = patientRef.split('/').last;

    final performers = json['performer'] as List? ?? [];
    String? practitionerId;
    if (performers.isNotEmpty) {
      final ref = performers[0]?['reference'] ?? '';
      practitionerId = ref.split('/').last;
    }

    return FhirAntecedent(
      id: json['id'],
      patientId: patientId,
      type: AntecedentTypeExtension.fromString(typeStr),
      content: json['valueString'] ?? '',
      practitionerId: practitionerId,
      createdAt: json['effectiveDateTime'] != null
          ? DateTime.parse(json['effectiveDateTime'])
          : DateTime.now(),
      updatedAt: json['issued'] != null ? DateTime.parse(json['issued']) : null,
      status: json['status'] ?? 'final',
    );
  }

  /// Crea una copia con cambios específicos
  FhirAntecedent copyWith({
    String? id,
    String? patientId,
    AntecedentType? type,
    String? content,
    String? practitionerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return FhirAntecedent(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      content: content ?? this.content,
      practitionerId: practitionerId ?? this.practitionerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'FhirAntecedent(id: $id, type: ${type.displayName}, patientId: $patientId)';
}
