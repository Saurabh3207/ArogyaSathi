import 'package:uuid/uuid.dart';

class ImmunizationRecord {
  final String immunizationId;
  final String patientId;
  final String vaccineName;
  final int doseNumber;
  final String? dateAdministered;
  final String nextDueDate;
  final String lastModifiedAt;
  final int isDeleted;

  ImmunizationRecord({
    String? immunizationId,
    required this.patientId,
    required this.vaccineName,
    required this.doseNumber,
    this.dateAdministered,
    required this.nextDueDate,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : immunizationId = immunizationId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'immunization_id': immunizationId,
      'patient_id': patientId,
      'vaccine_name': vaccineName,
      'dose_number': doseNumber,
      'date_administered': dateAdministered,
      'next_due_date': nextDueDate,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory ImmunizationRecord.fromMap(Map<String, dynamic> map) {
    return ImmunizationRecord(
      immunizationId: map['immunization_id'],
      patientId: map['patient_id'],
      vaccineName: map['vaccine_name'],
      doseNumber: map['dose_number'],
      dateAdministered: map['date_administered'],
      nextDueDate: map['next_due_date'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
