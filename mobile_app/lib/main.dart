import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'data/services/sync_manager.dart';
import 'data/services/notification_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/household_registration_screen.dart';
import 'presentation/screens/patient_registration_screen.dart';
import 'presentation/screens/household_list_screen.dart';
import 'presentation/screens/maternal_health_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/visits_schedule_screen.dart';
import 'presentation/screens/patient_list_screen.dart';
import 'presentation/screens/ncd_screening_form_screen.dart';
import 'presentation/screens/camp_management_screen.dart';
import 'presentation/screens/maternal_visit_form_screen.dart';
import 'presentation/screens/sync_center_screen.dart';
import 'generated/app_localizations.dart';

void main() async {
  // Use a runZonedGuarded to catch all hidden async errors
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Notifications with a fallback icon
  try {
    await AwesomeNotifications().initialize(
      null, // This uses the default app icon
      [
        NotificationChannel(
          channelGroupKey: 'arogyasathi_group',
          channelKey: 'alerts',
          channelName: 'Health Alerts',
          channelDescription: 'Notification channel for patient follow-ups',
          defaultColor: const Color(0xFFD35400),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'arogyasathi_group',
          channelGroupName: 'General Alerts',
        )
      ],
      debug: false,
    );
  } catch (e) {
    debugPrint("Notification Initialization Error: $e");
  }

  // 2. Initialize Sync Manager (Lazy Init)
  SyncManager().init();

  runApp(const ArogyaSathiApp());
}

class ArogyaSathiApp extends StatefulWidget {
  const ArogyaSathiApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _ArogyaSathiAppState? state = context.findAncestorStateOfType<_ArogyaSathiAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<ArogyaSathiApp> createState() => _ArogyaSathiAppState();
}

class _ArogyaSathiAppState extends State<ArogyaSathiApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArogyaSathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD35400),
          primary: const Color(0xFFD35400),
          secondary: const Color(0xFF27AE60),
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF4F7F6),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A252F), letterSpacing: -1.0),
          headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1A252F)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          bodyLarge: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(color: Color(0xFF566573), fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD35400), width: 2.5)),
          labelStyle: const TextStyle(color: Color(0xFF566573), fontWeight: FontWeight.w500),
          prefixIconColor: const Color(0xFFD35400),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD35400),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 8,
            shadowColor: const Color(0xFFD35400).withValues(alpha: 0.5),
          ),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('mr', ''),
      ],
      locale: _locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/household_registration': (context) => const HouseholdRegistrationScreen(),
        '/patient_registration': (context) => const PatientRegistrationScreen(),
        '/household_list': (context) => const HouseholdListScreen(),
        '/maternal_health': (context) => const MaternalHealthScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/schedule': (context) => const VisitsScheduleScreen(),
        '/camps': (context) => const CampManagementScreen(),
        '/maternal-visit': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MaternalVisitFormScreen(patientId: args['patientId'], patientName: args['patientName']);
        },
        '/sync-center': (context) => const SyncCenterScreen(),
        '/ncd_screening': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return NCDScreeningFormScreen(patientId: args['patientId'], patientName: args['patientName']);
        },
        '/patient_list': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PatientListScreen(householdId: args['householdId'], householdName: args['householdName']);
        },
      },
    );
  }
}
