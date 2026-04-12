import 'package:uuid/uuid.dart';

class Patient {
  final String patientId;
  final String householdId;
  final String firstName;
  final String dateOfBirth;
  final String gender;
  final String citizenCategory;
  final String? maritalStatus;
  final String? contraceptiveMethod;
  final String migrationStatus;
  final int isHighRisk;
  final String lastModifiedAt;
  final int isDeleted;

  Patient({
    String? patientId,
    required this.householdId,
    required this.firstName,
    required this.dateOfBirth,
    required this.gender,
    required this.citizenCategory,
    this.maritalStatus,
    this.contraceptiveMethod,
    this.migrationStatus = 'Resident',
    this.isHighRisk = 0,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : patientId = patientId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'household_id': householdId,
      'first_name': firstName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'citizen_category': citizenCategory,
      'marital_status': maritalStatus,
      'contraceptive_method': contraceptiveMethod,
      'migration_status': migrationStatus,
      'is_high_risk': isHighRisk,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patient_id'],
      householdId: map['household_id'],
      firstName: map['first_name'],
      dateOfBirth: map['date_of_birth'],
      gender: map['gender'],
      citizenCategory: map['citizen_category'],
      maritalStatus: map['marital_status'],
      contraceptiveMethod: map['contraceptive_method'],
      migrationStatus: map['migration_status'],
      isHighRisk: map['is_high_risk'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
