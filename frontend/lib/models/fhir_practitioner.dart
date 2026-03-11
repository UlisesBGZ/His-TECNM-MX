class FhirPractitioner {
  final String? id;
  final String? identifier; // userId
  final String name;
  final String? qualification;

  FhirPractitioner({
    this.id,
    this.identifier,
    required this.name,
    this.qualification,
  });

  factory FhirPractitioner.fromJson(Map<String, dynamic> json) {
    String? identifierValue;
    if (json['identifier'] != null && json['identifier'] is List) {
      for (var id in json['identifier']) {
        if (id['system'] == 'http://hospital.com/user-id') {
          identifierValue = id['value'];
          break;
        }
      }
    }

    String practitionerName = 'Unknown';
    if (json['name'] != null &&
        json['name'] is List &&
        json['name'].isNotEmpty) {
      final nameObj = json['name'][0];
      final given = nameObj['given'] != null && nameObj['given'].isNotEmpty
          ? nameObj['given'][0]
          : '';
      final family = nameObj['family'] ?? '';
      practitionerName = '$given $family'.trim();
    }

    String? qual;
    if (json['qualification'] != null &&
        json['qualification'] is List &&
        json['qualification'].isNotEmpty) {
      qual = json['qualification'][0]['code']?['text'];
    }

    return FhirPractitioner(
      id: json['id'],
      identifier: identifierValue,
      name: practitionerName,
      qualification: qual,
    );
  }

  Map<String, dynamic> toFhirJson() {
    final nameParts = name.split(' ');
    final family = nameParts.isNotEmpty ? nameParts.last : '';
    final given = nameParts.length > 1
        ? nameParts.sublist(0, nameParts.length - 1).join(' ')
        : '';

    final json = <String, dynamic>{
      'resourceType': 'Practitioner',
      'identifier': [
        {
          'system': 'http://hospital.com/user-id',
          'value': identifier,
        }
      ],
      'name': [
        {
          'family': family,
          'given': [given],
        }
      ],
      'active': true,
    };

    if (id != null) json['id'] = id;

    if (qualification != null) {
      json['qualification'] = [
        {
          'code': {
            'text': qualification,
          }
        }
      ];
    }

    return json;
  }
}
