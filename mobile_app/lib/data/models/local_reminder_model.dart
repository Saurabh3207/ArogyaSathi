import 'package:uuid/uuid.dart';

class LocalReminder {
  final String reminderId;
  final String patientId;
  final String? referenceId; // FK to specific visit/vaccine
  final String reminderType;
  final String scheduledDate;
  final int isTriggered;

  LocalReminder({
    String? reminderId,
    required this.patientId,
    this.referenceId,
    required this.reminderType,
    required this.scheduledDate,
    this.isTriggered = 0,
  }) : reminderId = reminderId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'reminder_id': reminderId,
      'patient_id': patientId,
      'reference_id': referenceId,
      'reminder_type': reminderType,
      'scheduled_date': scheduledDate,
      'is_triggered': isTriggered,
    };
  }

  factory LocalReminder.fromMap(Map<String, dynamic> map) {
    return LocalReminder(
      reminderId: map['reminder_id'],
      patientId: map['patient_id'],
      referenceId: map['reference_id'],
      reminderType: map['reminder_type'],
      scheduledDate: map['scheduled_date'],
      isTriggered: map['is_triggered'],
    );
  }
}
