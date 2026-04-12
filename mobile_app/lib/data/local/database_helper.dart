import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'arogyasathi.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ASHA_Worker Table
    await db.execute('''
      CREATE TABLE ASHA_Worker (
        asha_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        village TEXT NOT NULL,
        phc_name TEXT NOT NULL,
        auth_token TEXT,
        session_expiry TEXT,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    // Household Table
    await db.execute('''
      CREATE TABLE Household (
        household_id TEXT PRIMARY KEY,
        asha_id TEXT NOT NULL,
        house_number TEXT,
        family_surname TEXT,
        head_of_family_name TEXT NOT NULL,
        address TEXT NOT NULL,
        ration_card_type TEXT,
        total_members INTEGER DEFAULT 0,
        total_adults INTEGER DEFAULT 0,
        total_children INTEGER DEFAULT 0,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (asha_id) REFERENCES ASHA_Worker(asha_id)
      )
    ''');

    // Patient Table
    await db.execute('''
      CREATE TABLE Patient (
        patient_id TEXT PRIMARY KEY,
        household_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        citizen_category TEXT NOT NULL,
        marital_status TEXT,
        contraceptive_method TEXT,
        migration_status TEXT DEFAULT 'Resident',
        is_high_risk INTEGER DEFAULT 0,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (household_id) REFERENCES Household(household_id)
      )
    ''');

    // Health_Visit Table
    await db.execute('''
      CREATE TABLE Health_Visit (
        visit_id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        asha_id TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        visit_type TEXT NOT NULL,
        health_observation TEXT,
        anc_trimester INTEGER,
        maternal_weight REAL,
        blood_pressure TEXT,
        supplements_given TEXT,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
        FOREIGN KEY (asha_id) REFERENCES ASHA_Worker(asha_id)
      )
    ''');

    // NCD_Screening Table
    await db.execute('''
      CREATE TABLE NCD_Screening (
        screening_id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        screening_date TEXT NOT NULL,
        hypertension_risk TEXT,
        diabetes_risk TEXT,
        cancer_screening_status TEXT,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
      )
    ''');

    // Vital_Events Table
    await db.execute('''
      CREATE TABLE Vital_Events (
        event_id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        event_date TEXT NOT NULL,
        reported_to_phc INTEGER DEFAULT 0,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
      )
    ''');

    // Immunization_Record Table
    await db.execute('''
      CREATE TABLE Immunization_Record (
        immunization_id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        dose_number INTEGER NOT NULL,
        date_administered TEXT,
        next_due_date TEXT NOT NULL,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
      )
    ''');

    // Camp_Event Table
    await db.execute('''
      CREATE TABLE Camp_Event (
        camp_id TEXT PRIMARY KEY,
        asha_id TEXT NOT NULL,
        camp_type TEXT NOT NULL,
        camp_date TEXT NOT NULL,
        location TEXT NOT NULL,
        last_modified_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (asha_id) REFERENCES ASHA_Worker(asha_id)
      )
    ''');

    // Local_Reminder Table
    await db.execute('''
      CREATE TABLE Local_Reminder (
        reminder_id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        reference_id TEXT,
        reminder_type TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        is_triggered INTEGER DEFAULT 0,
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
      )
    ''');

    // Sync_Status Table
    await db.execute('''
      CREATE TABLE Sync_Status (
        sync_id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');

    // TRIGGERS
    await db.execute('''
      CREATE TRIGGER update_household_count_after_insert
      AFTER INSERT ON Patient
      FOR EACH ROW
      BEGIN
        UPDATE Household 
        SET total_members = total_members + 1,
            last_modified_at = CURRENT_TIMESTAMP
        WHERE household_id = NEW.household_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER update_household_count_after_soft_delete
      AFTER UPDATE OF is_deleted ON Patient
      FOR EACH ROW
      WHEN NEW.is_deleted = 1 AND OLD.is_deleted = 0
      BEGIN
        UPDATE Household 
        SET total_members = total_members - 1,
            last_modified_at = CURRENT_TIMESTAMP
        WHERE household_id = NEW.household_id;
      END;
    ''');
  }
}
