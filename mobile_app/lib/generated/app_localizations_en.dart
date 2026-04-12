// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ArogyaSathi';

  @override
  String get tagline => 'Empowering ASHA Workers';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Securely access healthcare records';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get households => 'Households';

  @override
  String get patients => 'Patients';

  @override
  String get healthVisits => 'Health Visits';

  @override
  String get immunization => 'Immunization';

  @override
  String get ncdScreening => 'NCD Screening';

  @override
  String get vitalEvents => 'Vital Events';

  @override
  String get camps => 'Camps';

  @override
  String get reminders => 'Reminders';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get householdRegistration => 'Household Registration';

  @override
  String get patientRegistration => 'Patient Registration';

  @override
  String get maternalHealth => 'Maternal Health';

  @override
  String get childHealth => 'Child Health';

  @override
  String get syncRecords => 'Sync Records';

  @override
  String get summaryStats => 'Summary Statistics';

  @override
  String get totalHouseholds => 'Total Households';

  @override
  String get totalPatients => 'Total Patients';

  @override
  String get ncdScreeningTitle => 'NCD Screening';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get bloodSugar => 'Blood Sugar (RBS)';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get submitScreening => 'SUBMIT SCREENING';

  @override
  String get screeningRecorded => 'Screening Recorded';

  @override
  String screeningSavedLocally(Object patientName) {
    return 'NCD screening for $patientName has been saved locally.';
  }

  @override
  String get childImmunization => 'Child Immunization';

  @override
  String get vaccineName => 'Vaccine Name';

  @override
  String get doseNumber => 'Dose Number';

  @override
  String get dateAdministered => 'Date Administered';

  @override
  String get administer => 'ADMINISTER';

  @override
  String get totalDue => 'Total Due';

  @override
  String get completed => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get age => 'Age';

  @override
  String get vitalStatistics => 'Vital Statistics';

  @override
  String get physicalMarkers => 'Physical Markers';

  @override
  String get riskIndicators => 'Risk Indicators';
}
