import 'package:uuid/uuid.dart';

class HealthVisit {
  final String visitId;
  final String patientId;
  final String ashaId;
  final String visitDate;
  final String visitType;
  final String? healthObservation;
  final int? ancTrimester;
  final double? maternalWeight;
  final String? bloodPressure;
  final String? supplementsGiven;
  final String lastModifiedAt;
  final int isDeleted;

  HealthVisit({
    String? visitId,
    required this.patientId,
    required this.ashaId,
    required this.visitDate,
    required this.visitType,
    this.healthObservation,
    this.ancTrimester,
    this.maternalWeight,
    this.bloodPressure,
    this.supplementsGiven,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : visitId = visitId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'visit_id': visitId,
      'patient_id': patientId,
      'asha_id': ashaId,
      'visit_date': visitDate,
      'visit_type': visitType,
      'health_observation': healthObservation,
      'anc_trimester': ancTrimester,
      'maternal_weight': maternalWeight,
      'blood_pressure': bloodPressure,
      'supplements_given': supplementsGiven,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory HealthVisit.fromMap(Map<String, dynamic> map) {
    return HealthVisit(
      visitId: map['visit_id'],
      patientId: map['patient_id'],
      ashaId: map['asha_id'],
      visitDate: map['visit_date'],
      visitType: map['visit_type'],
      healthObservation: map['health_observation'],
      ancTrimester: map['anc_trimester'],
      maternalWeight: map['maternal_weight'],
      bloodPressure: map['blood_pressure'],
      supplementsGiven: map['supplements_given'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
