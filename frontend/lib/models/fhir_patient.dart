class FhirPatient {
  final String? id;
  final String? identifier; // Cédula o documento
  final String? firstName;
  final String? lastName;
  final String? gender; // male, female, other, unknown
  final String? birthDate; // YYYY-MM-DD
  final String? phone;
  final String? email;
  final String? address;

  FhirPatient({
    this.id,
    this.identifier,
    this.firstName,
    this.lastName,
    this.gender,
    this.birthDate,
    this.phone,
    this.email,
    this.address,
  });

  // Convertir de FHIR JSON a modelo simplificado
  factory FhirPatient.fromJson(Map<String, dynamic> json) {
    String? firstName;
    String? lastName;
    String? identifier;
    String? phone;
    String? email;
    String? address;

    // Extraer nombre (FHIR usa estructura compleja)
    if (json['name'] != null && (json['name'] as List).isNotEmpty) {
      final name = (json['name'] as List).first;
      if (name['given'] != null && (name['given'] as List).isNotEmpty) {
        firstName = (name['given'] as List).first;
      }
      if (name['family'] != null) {
        lastName = name['family'];
      }
    }

    // Extraer identificador (cédula)
    if (json['identifier'] != null && (json['identifier'] as List).isNotEmpty) {
      final id = (json['identifier'] as List).first;
      identifier = id['value'];
    }

    // Extraer contacto
    if (json['telecom'] != null) {
      for (var telecom in json['telecom']) {
        if (telecom['system'] == 'phone') {
          phone = telecom['value'];
        } else if (telecom['system'] == 'email') {
          email = telecom['value'];
        }
      }
    }

    // Extraer dirección
    if (json['address'] != null && (json['address'] as List).isNotEmpty) {
      final addr = (json['address'] as List).first;
      final lines = addr['line'] as List?;
      address = lines?.join(', ') ?? '';
      if (addr['city'] != null) {
        address = '$address, ${addr['city']}';
      }
    }

    return FhirPatient(
      id: json['id'],
      identifier: identifier,
      firstName: firstName,
      lastName: lastName,
      gender: json['gender'],
      birthDate: json['birthDate'],
      phone: phone,
      email: email,
      address: address,
    );
  }

  // Convertir a JSON FHIR para crear/actualizar
  Map<String, dynamic> toFhirJson() {
    final Map<String, dynamic> resource = {
      'resourceType': 'Patient',
    };

    if (id != null) {
      resource['id'] = id;
    }

    // Identificador (cédula)
    if (identifier != null && identifier!.isNotEmpty) {
      resource['identifier'] = [
        {
          'use': 'official',
          'system': 'urn:oid:2.16.840.1.113883.2.10.1',
          'value': identifier,
        }
      ];
    }

    // Nombre
    if (firstName != null || lastName != null) {
      resource['name'] = [
        {
          'use': 'official',
          if (lastName != null) 'family': lastName,
          if (firstName != null) 'given': [firstName],
        }
      ];
    }

    if (gender != null) {
      resource['gender'] = gender;
    }

    if (birthDate != null) {
      resource['birthDate'] = birthDate;
    }

    // Contacto
    final List<Map<String, dynamic>> telecom = [];
    if (phone != null && phone!.isNotEmpty) {
      telecom.add({
        'system': 'phone',
        'value': phone,
        'use': 'mobile',
      });
    }
    if (email != null && email!.isNotEmpty) {
      telecom.add({
        'system': 'email',
        'value': email,
        'use': 'home',
      });
    }
    if (telecom.isNotEmpty) {
      resource['telecom'] = telecom;
    }

    // Dirección
    if (address != null && address!.isNotEmpty) {
      resource['address'] = [
        {
          'use': 'home',
          'line': [address],
        }
      ];
    }

    return resource;
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? 'Sin nombre';
  }

  String get genderDisplay {
    switch (gender) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Femenino';
      case 'other':
        return 'Otro';
      default:
        return 'Desconocido';
    }
  }

  int? get age {
    if (birthDate == null) return null;
    try {
      final birth = DateTime.parse(birthDate!);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}
