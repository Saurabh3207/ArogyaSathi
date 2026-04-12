import 'package:uuid/uuid.dart';

class VitalEvent {
  final String eventId;
  final String patientId;
  final String eventType;
  final String eventDate;
  final int reportedToPhc;
  final String lastModifiedAt;
  final int isDeleted;

  VitalEvent({
    String? eventId,
    required this.patientId,
    required this.eventType,
    required this.eventDate,
    this.reportedToPhc = 0,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : eventId = eventId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'patient_id': patientId,
      'event_type': eventType,
      'event_date': eventDate,
      'reported_to_phc': reportedToPhc,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory VitalEvent.fromMap(Map<String, dynamic> map) {
    return VitalEvent(
      eventId: map['event_id'],
      patientId: map['patient_id'],
      eventType: map['event_type'],
      eventDate: map['event_date'],
      reportedToPhc: map['reported_to_phc'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
