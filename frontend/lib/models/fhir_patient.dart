class FhirPatient {
  static const String _paternalLastNameExtensionUrl =
      'http://hospital.com/fhir/StructureDefinition/paternal-last-name';
  static const String _maternalLastNameExtensionUrl =
      'http://hospital.com/fhir/StructureDefinition/maternal-last-name';
  static const String _bloodTypeExtensionUrl =
      'http://hospital.com/fhir/StructureDefinition/blood-type';
  static const String _clinicalAntecedentsExtensionUrl =
      'http://hospital.com/fhir/StructureDefinition/clinical-antecedents';
  static const String _ehrIdExtensionUrl =
      'http://hospital.com/fhir/StructureDefinition/ehr-id';
  static const String _ehrLinkageNamespaceExtensionUrl =
      'http://hospital.com/fhir/StructureDefinition/ehr-linkage-namespace';

  final String? id;
  final String? identifier; // CURP o identificador institucional
  final String? firstName;
  final String? paternalLastName;
  final String? maternalLastName;
  final String? gender; // male, female, other, unknown
  final String? birthDate; // YYYY-MM-DD
  final String? bloodType;
  final String? state;
  final String? municipality;
  final String? postalCode;
  final String? streetAndNumber;
  final String? colony;
  final String? phone;
  final String? email;
  final String? clinicalAntecedents;
  final String? ehrId;
  final String? linkageNamespace;
  final String? address; // Compatibilidad con versiones anteriores

  FhirPatient({
    this.id,
    this.identifier,
    this.firstName,
    this.paternalLastName,
    this.maternalLastName,
    this.gender,
    this.birthDate,
    this.bloodType,
    this.state,
    this.municipality,
    this.postalCode,
    this.streetAndNumber,
    this.colony,
    this.phone,
    this.email,
    this.clinicalAntecedents,
    this.ehrId,
    this.linkageNamespace,
    this.address,
  });

  factory FhirPatient.fromJson(Map<String, dynamic> json) {
    String? firstName;
    String? paternalLastName;
    String? maternalLastName;
    String? identifier;
    String? bloodType;
    String? state;
    String? municipality;
    String? postalCode;
    String? streetAndNumber;
    String? colony;
    String? phone;
    String? email;
    String? clinicalAntecedents;
    String? ehrId;
    String? linkageNamespace;
    String? address;

    // Nombre
    if (json['name'] != null && (json['name'] as List).isNotEmpty) {
      final name = (json['name'] as List).first;
      if (name['given'] != null && (name['given'] as List).isNotEmpty) {
        firstName = (name['given'] as List).join(' ');
      }
      if (name['family'] != null) {
        final family = name['family'].toString().trim();
        final familyParts = family.split(RegExp(r'\s+'));
        if (familyParts.isNotEmpty) {
          paternalLastName = familyParts.first;
          if (familyParts.length > 1) {
            maternalLastName = familyParts.sublist(1).join(' ');
          }
        }
      }
    }

    // Identificador (CURP o institucional)
    if (json['identifier'] != null && (json['identifier'] as List).isNotEmpty) {
      final id = (json['identifier'] as List).first;
      identifier = id['value'];
    }

    // Contacto
    if (json['telecom'] != null) {
      for (var telecom in json['telecom']) {
        if (telecom['system'] == 'phone') {
          phone = telecom['value'];
        } else if (telecom['system'] == 'email') {
          email = telecom['value'];
        }
      }
    }

    // Dirección estructurada
    if (json['address'] != null && (json['address'] as List).isNotEmpty) {
      final addr = (json['address'] as List).first;
      final lines = addr['line'] as List?;
      streetAndNumber = lines?.join(', ') ?? '';
      municipality = addr['city']?.toString();
      state = addr['state']?.toString();
      postalCode = addr['postalCode']?.toString();
      colony = addr['district']?.toString();

      final addressParts = <String>[];
      if (streetAndNumber.isNotEmpty) {
        addressParts.add(streetAndNumber);
      }
      if (colony != null && colony.isNotEmpty) {
        addressParts.add(colony);
      }
      if (municipality != null && municipality.isNotEmpty) {
        addressParts.add(municipality);
      }
      if (state != null && state.isNotEmpty) {
        addressParts.add(state);
      }
      if (postalCode != null && postalCode.isNotEmpty) {
        addressParts.add(postalCode);
      }
      address = addressParts.join(', ');
    }

    bloodType = _readExtensionValue(json, _bloodTypeExtensionUrl);
    paternalLastName =
        _readExtensionValue(json, _paternalLastNameExtensionUrl) ??
            paternalLastName;
    maternalLastName =
        _readExtensionValue(json, _maternalLastNameExtensionUrl) ??
            maternalLastName;
    clinicalAntecedents =
        _readExtensionValue(json, _clinicalAntecedentsExtensionUrl);
    ehrId = _readExtensionValue(json, _ehrIdExtensionUrl);
    linkageNamespace =
        _readExtensionValue(json, _ehrLinkageNamespaceExtensionUrl);

    return FhirPatient(
      id: json['id'],
      identifier: identifier,
      firstName: firstName,
      paternalLastName: paternalLastName,
      maternalLastName: maternalLastName,
      gender: json['gender'],
      birthDate: json['birthDate'],
      bloodType: bloodType,
      state: state,
      municipality: municipality,
      postalCode: postalCode,
      streetAndNumber: streetAndNumber,
      colony: colony,
      phone: phone,
      email: email,
      clinicalAntecedents: clinicalAntecedents,
      ehrId: ehrId,
      linkageNamespace: linkageNamespace,
      address: address,
    );
  }

  Map<String, dynamic> toFhirJson() {
    final Map<String, dynamic> resource = {
      'resourceType': 'Patient',
    };

    if (id != null) {
      resource['id'] = id;
    }

    // Identificador (CURP o institucional)
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
    final combinedSurnames = [
      if (paternalLastName != null && paternalLastName!.isNotEmpty)
        paternalLastName!.trim(),
      if (maternalLastName != null && maternalLastName!.isNotEmpty)
        maternalLastName!.trim(),
    ].join(' ').trim();

    final givenNames = firstName == null
        ? <String>[]
        : firstName!
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();

    if (givenNames.isNotEmpty || combinedSurnames.isNotEmpty) {
      resource['name'] = [
        {
          'use': 'official',
          if (combinedSurnames.isNotEmpty) 'family': combinedSurnames,
          if (givenNames.isNotEmpty) 'given': givenNames,
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

    // Dirección estructurada
    final addressParts = <String, dynamic>{};
    if (streetAndNumber != null && streetAndNumber!.isNotEmpty) {
      addressParts['line'] = [streetAndNumber!.trim()];
    }
    if (municipality != null && municipality!.isNotEmpty) {
      addressParts['city'] = municipality!.trim();
    }
    if (state != null && state!.isNotEmpty) {
      addressParts['state'] = state!.trim();
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      addressParts['postalCode'] = postalCode!.trim();
    }
    if (colony != null && colony!.isNotEmpty) {
      addressParts['district'] = colony!.trim();
    }
    if (addressParts.isNotEmpty) {
      addressParts['use'] = 'home';
      resource['address'] = [addressParts];
    }

    // Extensiones clínicas y de trazabilidad
    final extensions = <Map<String, dynamic>>[];

    void addExtension(String url, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        extensions.add({
          'url': url,
          'valueString': value.trim(),
        });
      }
    }

    addExtension(_paternalLastNameExtensionUrl, paternalLastName);
    addExtension(_maternalLastNameExtensionUrl, maternalLastName);
    addExtension(_bloodTypeExtensionUrl, bloodType);
    addExtension(_clinicalAntecedentsExtensionUrl, clinicalAntecedents);
    addExtension(_ehrIdExtensionUrl, ehrId);
    addExtension(_ehrLinkageNamespaceExtensionUrl, linkageNamespace);

    if (extensions.isNotEmpty) {
      resource['extension'] = extensions;
    }

    return resource;
  }

  static String? _readExtensionValue(Map<String, dynamic> json, String url) {
    final extensions = json['extension'];
    if (extensions == null || extensions is! List) {
      return null;
    }

    for (final item in extensions) {
      if (item is Map<String, dynamic> && item['url'] == url) {
        final value = item['valueString'];
        if (value != null) {
          return value.toString();
        }
      }
    }

    return null;
  }

  String get fullName {
    final given = firstName?.trim() ?? '';
    final paternal = paternalLastName?.trim() ?? '';
    final maternal = maternalLastName?.trim() ?? '';
    final parts = <String>[];

    if (given.isNotEmpty) parts.add(given);
    if (paternal.isNotEmpty) parts.add(paternal);
    if (maternal.isNotEmpty) parts.add(maternal);

    if (parts.isNotEmpty) {
      return parts.join(' ');
    }

    return identifier ?? 'Sin nombre';
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
