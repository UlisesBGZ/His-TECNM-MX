class FhirAppointment {
  final String? id;
  final String status;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final String? patientId;
  final String? patientName;
  final String? practitionerId;
  final String? practitionerName;
  final String? comment;
  final int? minutesDuration;

  FhirAppointment({
    this.id,
    required this.status,
    this.description,
    this.start,
    this.end,
    this.patientId,
    this.patientName,
    this.practitionerId,
    this.practitionerName,
    this.comment,
    this.minutesDuration,
  });

  factory FhirAppointment.fromJson(Map<String, dynamic> json) {
    DateTime? startDate;
    DateTime? endDate;

    if (json['start'] != null) {
      startDate = DateTime.parse(json['start']);
    }
    if (json['end'] != null) {
      endDate = DateTime.parse(json['end']);
    }

    String? patientId;
    String? patientName;
    String? practitionerId;
    String? practitionerName;

    if (json['participant'] != null && json['participant'] is List) {
      for (var participant in json['participant']) {
        if (participant['actor'] != null) {
          String? reference = participant['actor']['reference'];
          String? display = participant['actor']['display'];

          if (reference != null) {
            if (reference.startsWith('Patient/')) {
              patientId = reference.replaceFirst('Patient/', '');
              patientName = display;
            } else if (reference.startsWith('Practitioner/')) {
              practitionerId = reference.replaceFirst('Practitioner/', '');
              practitionerName = display;
            }
          }
        }
      }
    }

    return FhirAppointment(
      id: json['id'],
      status: json['status'] ?? 'proposed',
      description: json['description'],
      start: startDate,
      end: endDate,
      patientId: patientId,
      patientName: patientName,
      practitionerId: practitionerId,
      practitionerName: practitionerName,
      comment: json['comment'],
      minutesDuration: json['minutesDuration'],
    );
  }

  Map<String, dynamic> toFhirJson() {
    final json = <String, dynamic>{
      'resourceType': 'Appointment',
      'status': status,
    };

    if (id != null) json['id'] = id;
    if (description != null) json['description'] = description;
    if (start != null) json['start'] = start!.toIso8601String();
    if (end != null) json['end'] = end!.toIso8601String();
    if (comment != null) json['comment'] = comment;
    if (minutesDuration != null) json['minutesDuration'] = minutesDuration;

    // Participants
    final participants = <Map<String, dynamic>>[];

    if (patientId != null) {
      participants.add({
        'actor': {
          'reference': 'Patient/$patientId',
          if (patientName != null) 'display': patientName,
        },
        'status': 'accepted',
      });
    }

    if (practitionerId != null) {
      participants.add({
        'actor': {
          'reference': 'Practitioner/$practitionerId',
          if (practitionerName != null) 'display': practitionerName,
        },
        'status': 'accepted',
      });
    }

    if (participants.isNotEmpty) {
      json['participant'] = participants;
    }

    return json;
  }

  String get statusDisplay {
    switch (status) {
      case 'proposed':
        return 'Propuesta';
      case 'pending':
        return 'Pendiente';
      case 'booked':
        return 'Confirmada';
      case 'arrived':
        return 'Paciente llegó';
      case 'fulfilled':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      case 'noshow':
        return 'No asistió';
      default:
        return status;
    }
  }

  String get dateTimeDisplay {
    if (start == null) return 'Sin fecha';

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

    final day = start!.day;
    final month = months[start!.month - 1];
    final year = start!.year;
    final hour = start!.hour.toString().padLeft(2, '0');
    final minute = start!.minute.toString().padLeft(2, '0');

    return '$day $month $year - $hour:$minute';
  }

  String? get durationDisplay {
    if (minutesDuration == null) return null;

    final hours = minutesDuration! ~/ 60;
    final minutes = minutesDuration! % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}
