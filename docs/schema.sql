-- ====================================================================
-- AROGYASATHI OFFLINE-FIRST DATABASE SCHEMA (SQLite)
-- Note: UUIDs are stored as TEXT. Booleans are stored as INTEGER (0 or 1).
-- ====================================================================

-- 1. ASHA Worker Profile
CREATE TABLE ASHA_Worker (
    asha_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    village TEXT NOT NULL,
    phc_name TEXT NOT NULL,
    auth_token TEXT,
    session_expiry DATETIME,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0
);

-- 2. Household (Family Demographics)
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
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (asha_id) REFERENCES ASHA_Worker(asha_id)
);

-- 3. Patient (Individual Members & Surveys)
CREATE TABLE Patient (
    patient_id TEXT PRIMARY KEY,
    household_id TEXT NOT NULL,
    first_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    gender TEXT NOT NULL,
    citizen_category TEXT NOT NULL, -- 'Infant', 'Pregnant', 'Adult', 'Elderly'
    marital_status TEXT,
    contraceptive_method TEXT,
    migration_status TEXT DEFAULT 'Resident',
    is_high_risk INTEGER DEFAULT 0,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (household_id) REFERENCES Household(household_id)
);

-- 4. Health Visit (Routine, ANC, Postnatal)
CREATE TABLE Health_Visit (
    visit_id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    asha_id TEXT NOT NULL,
    visit_date DATETIME NOT NULL,
    visit_type TEXT NOT NULL, -- 'Routine', 'ANC', etc.
    health_observation TEXT,
    anc_trimester INTEGER,
    maternal_weight REAL,
    blood_pressure TEXT,
    supplements_given TEXT,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (asha_id) REFERENCES ASHA_Worker(asha_id)
);

-- 5. NCD Screening (For Citizens 30+)
CREATE TABLE NCD_Screening (
    screening_id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    screening_date DATE NOT NULL,
    hypertension_risk TEXT,
    diabetes_risk TEXT,
    cancer_screening_status TEXT,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

-- 6. Vital Events (Births and Deaths)
CREATE TABLE Vital_Events (
    event_id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    event_type TEXT NOT NULL, -- 'Birth' or 'Death'
    event_date DATE NOT NULL,
    reported_to_phc INTEGER DEFAULT 0,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

-- 7. Immunization Record
CREATE TABLE Immunization_Record (
    immunization_id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    vaccine_name TEXT NOT NULL,
    dose_number INTEGER NOT NULL,
    date_administered DATE,
    next_due_date DATE NOT NULL,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

-- 8. Camp Mobilization Event
CREATE TABLE Camp_Event (
    camp_id TEXT PRIMARY KEY,
    asha_id TEXT NOT NULL,
    camp_type TEXT NOT NULL,
    camp_date DATE NOT NULL,
    location TEXT NOT NULL,
    last_modified_at DATETIME NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (asha_id) REFERENCES ASHA_Worker(asha_id)
);

-- 9. Local Reminder (Push Notification Engine)
CREATE TABLE Local_Reminder (
    reminder_id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    reference_id TEXT, -- Links to specific Visit UUID or Vaccine UUID
    reminder_type TEXT NOT NULL,
    scheduled_date DATE NOT NULL,
    is_triggered INTEGER DEFAULT 0,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

-- 10. Sync Status (Offline Background Manager)
CREATE TABLE Sync_Status (
    sync_id TEXT PRIMARY KEY,
    entity_type TEXT NOT NULL, -- e.g., 'Patient', 'Household'
    entity_id TEXT NOT NULL, -- The UUID of the record
    operation TEXT NOT NULL, -- 'CREATE', 'UPDATE', 'SOFT_DELETE'
    sync_status TEXT NOT NULL -- 'PENDING' or 'SYNCED'
);

-- ====================================================================
-- AUTOMATION TRIGGERS
-- ====================================================================

-- Trigger: Automatically increase household total_members when a new patient is added
CREATE TRIGGER update_household_count_after_insert
AFTER INSERT ON Patient
FOR EACH ROW
BEGIN
    UPDATE Household 
    SET total_members = total_members + 1,
        last_modified_at = CURRENT_TIMESTAMP
    WHERE household_id = NEW.household_id;
END;

-- Trigger: Decrease household total_members if a patient is soft-deleted
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