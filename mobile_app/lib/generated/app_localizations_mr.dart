// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'आरोग्यसाथी';

  @override
  String get tagline => 'आशा सेविकांचे सक्षमीकरण';

  @override
  String get loginTitle => 'पुन्हा स्वागत आहे';

  @override
  String get loginSubtitle => 'आरोग्य नोंदी सुरक्षितपणे उघडा';

  @override
  String get phoneLabel => 'फोन नंबर';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get loginButton => 'लॉगिन';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get dashboardTitle => 'डॅशबोर्ड';

  @override
  String get households => 'कुटुंबे';

  @override
  String get patients => 'रुग्ण';

  @override
  String get healthVisits => 'आरोग्य भेटी';

  @override
  String get immunization => 'लसीकरण';

  @override
  String get ncdScreening => 'NCD तपासणी';

  @override
  String get vitalEvents => 'महत्वाच्या घटना';

  @override
  String get camps => 'शिबिरे';

  @override
  String get reminders => 'स्मरणपत्रे';

  @override
  String get quickActions => 'त्वरित कृती';

  @override
  String get householdRegistration => 'कुटुंब नोंदणी';

  @override
  String get patientRegistration => 'रुग्ण नोंदणी';

  @override
  String get maternalHealth => 'माता आरोग्य';

  @override
  String get childHealth => 'बाल आरोग्य';

  @override
  String get syncRecords => 'रेकॉर्ड सिंक करा';

  @override
  String get summaryStats => 'सारांश सांख्यिकी';

  @override
  String get totalHouseholds => 'एकूण कुटुंबे';

  @override
  String get totalPatients => 'एकूण रुग्ण';

  @override
  String get ncdScreeningTitle => 'NCD तपासणी';

  @override
  String get bloodPressure => 'रक्तदाब';

  @override
  String get systolic => 'सिस्टोलिक';

  @override
  String get diastolic => 'डायस्टोलिक';

  @override
  String get bloodSugar => 'रक्त शर्करा (RBS)';

  @override
  String get height => 'उंची';

  @override
  String get weight => 'वजन';

  @override
  String get symptoms => 'लक्षणे';

  @override
  String get submitScreening => 'तपासणी सबमिट करा';

  @override
  String get screeningRecorded => 'तपासणी नोंदवली';

  @override
  String screeningSavedLocally(Object patientName) {
    return '$patientName साठी NCD तपासणी स्थानिक पातळीवर जतन केली आहे.';
  }

  @override
  String get childImmunization => 'बाल लसीकरण';

  @override
  String get vaccineName => 'लसीचे नाव';

  @override
  String get doseNumber => 'डोस क्रमांक';

  @override
  String get dateAdministered => 'लस दिल्याची तारीख';

  @override
  String get administer => 'लस द्या';

  @override
  String get totalDue => 'एकूण येणे';

  @override
  String get completed => 'पूर्ण झाले';

  @override
  String get overdue => 'थकीत';

  @override
  String get age => 'वय';

  @override
  String get vitalStatistics => 'महत्वाच्या सांख्यिकी';

  @override
  String get physicalMarkers => 'शारीरिक खुणा';

  @override
  String get riskIndicators => 'धोका निर्देशक';
}
