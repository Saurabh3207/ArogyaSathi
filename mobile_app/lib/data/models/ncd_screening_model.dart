import 'package:uuid/uuid.dart';

class NCDScreening {
  final String screeningId;
  final String patientId;
  final String screeningDate;
  final String? hypertensionRisk;
  final String? diabetesRisk;
  final String? cancerScreeningStatus;
  final String lastModifiedAt;
  final int isDeleted;

  NCDScreening({
    String? screeningId,
    required this.patientId,
    required this.screeningDate,
    this.hypertensionRisk,
    this.diabetesRisk,
    this.cancerScreeningStatus,
    required this.lastModifiedAt,
    this.isDeleted = 0,
  }) : screeningId = screeningId ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'screening_id': screeningId,
      'patient_id': patientId,
      'screening_date': screeningDate,
      'hypertension_risk': hypertensionRisk,
      'diabetes_risk': diabetesRisk,
      'cancer_screening_status': cancerScreeningStatus,
      'last_modified_at': lastModifiedAt,
      'is_deleted': isDeleted,
    };
  }

  factory NCDScreening.fromMap(Map<String, dynamic> map) {
    return NCDScreening(
      screeningId: map['screening_id'],
      patientId: map['patient_id'],
      screeningDate: map['screening_date'],
      hypertensionRisk: map['hypertension_risk'],
      diabetesRisk: map['diabetes_risk'],
      cancerScreeningStatus: map['cancer_screening_status'],
      lastModifiedAt: map['last_modified_at'],
      isDeleted: map['is_deleted'],
    );
  }
}
