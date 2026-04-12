# 🩺 ArogyaSathi: The Ultimate Project Bible & Technical Handover

**Version:** 2.0 (Deep Audit Edition)  
**Date:** Current Dev Session  
**Objective:** To provide an absolute source of truth for the next AI/Developer to continue building the "ArogyaSathi" app with 100% consistency.

---

## 📖 1. Project Philosophy & User Persona
**The Vision:** To empower ASHA (Accredited Social Health Activists) workers with a "Premium" digital tool that works in zero-connectivity environments. This isn't just an app; it's a replacement for heavy paper registers.

**The Persona:** The ASHA worker is often on foot, in low-light conditions, and using mid-range Android devices. 
- **Requirement:** High contrast, large touch targets, offline-first reliability, and local language (Marathi) support.
- **Design Style:** "Premium Health" – using clean whites, soft shadows, and a professional Terracotta/Green palette to build trust during patient interactions.

---

## 📂 2. Folder Architecture & Responsibilities
```text
/ArogyaSathi
├── /mobile_app
│   ├── /assets
│   │   ├── /images         # Essential vectors (asha_vector.png) & logos.
│   │   └── /fonts          # Poppins (Google Fonts).
│   ├── /lib
│   │   ├── /data
│   │   │   ├── /local      # SQLite DatabaseHelper & Schema.
│   │   │   ├── /models     # PODOs (Patient, Household, etc.).
│   │   │   ├── /services   # SyncService, SyncManager, NotificationService.
│   │   │   └── /repositories # Abstraction layer for data access.
│   │   ├── /l10n           # .arb files for English (en) and Marathi (mr).
│   │   ├── /presentation
│   │   │   ├── /screens    # All UI screens (Refined & Audited).
│   │   │   └── /widgets    # Custom reusable components (Cards, Inputs).
│   │   └── main.dart       # App initialization & Provider setup.
├── /backend                # PENDING: To be built (Node.js/Express/FastAPI).
└── /docs                   # System architecture and overview markdown.
```

---

## 💾 3. The Data Dictionary (SQLite Schema)
**Database Name:** `arogyasathi.db` | **Version:** 1

### **Table 1: ASHA_Worker (The User)**
- `asha_id` (PK): UUID.
- `name`, `phone`, `village`, `phc_name`.
- `auth_token`: For API sync.
- `last_modified_at`: Timestamp.

### **Table 2: Household (The Container)**
- `household_id` (PK): UUID.
- `asha_id` (FK).
- `house_number`, `family_surname`, `head_of_family_name`, `address`.
- `total_members`, `total_adults`, `total_children`: (Managed by DB Triggers).

### **Table 3: Patient (The Core Entity)**
- `patient_id` (PK): UUID.
- `household_id` (FK).
- `first_name`, `date_of_birth` (Format: `dd/MM/yyyy`).
- `gender`, `citizen_category` (SC/ST/Gen/OBC).
- `is_high_risk`: 0/1 (Crucial for ANC/NCD).

### **Table 4: Sync_Status (The Engine Ledger)**
- `sync_id` (PK).
- `entity_type`: (Household, Patient, NCD_Screening, etc.).
- `entity_id`: The PK of the modified row.
- `operation`: 'CREATE' or 'UPDATE'.
- `sync_status`: 'PENDING' or 'SYNCED'.

### **Other Key Tables:**
- `NCD_Screening`: Vitals, BMI, BP, Sugar.
- `Immunization_Record`: Vaccine names, Doses, Next Due Dates.
- `Health_Visit`: ANC trimesters, observations.
- `Local_Reminder`: Queue for local push notifications.

---

## 🔄 4. The Sync Engine Deep Dive
### **Step-by-Step Logic:**
1. **Mutation:** When a user saves a form (e.g., `ncd_screening_form_screen.dart`), a transaction occurs.
2. **Local Write:** Data is saved to the specific table (`NCD_Screening`).
3. **Log Write:** An entry is added to `Sync_Status` with `sync_status = 'PENDING'`.
4. **Sync Trigger:** (Currently manual) `SyncService().syncData()` is called.
5. **Payload Prep:** The service fetches the row from the entity table using the `entity_id`.
6. **Network Call:** `POST` request to `https://arogyasathi-api.onrender.com/api/sync/{entity}`.
7. **Acknowledgement:** On `201 Created` or `200 OK`, local `Sync_Status` is updated to `'SYNCED'`.

---

## 🎨 5. The "Premium UI" Style Guide
Maintain these constants across all new screens:
- **Primary Color:** `Color(0xFFD35400)` (Terracotta).
- **Secondary Color:** `Color(0xFF27AE60)` (Healthy Green).
- **Background Color:** `Colors.white` (Clean look).
- **Card Background:** `Colors.white` with `Border.all(color: Color(0xFFEAECF0))`.
- **Input Style:**
    - `filled: true`, `fillColor: Color(0xFFF9FAFB)`.
    - `BorderRadius.circular(12)`.
    - `contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)`.
- **Date Picking:** Always use `DateFormat('dd/MM/yyyy')`. Never use ISO strings in the UI.

---

## ✅ 6. Audit Status (What is Done & Fixed)
- **Login:** [FIXED] Vector logo height, proper shadow inputs.
- **Dashboard:** [FIXED] Sliver layout bugs. Added drawer.
- **Household List:** [FIXED] Added population stats header.
- **Patient List:** [FIXED] Critical Age Calculation bug. Added age-based menus.
- **Maternal Health:** [FIXED] Status dashboard (Total/High Risk/Overdue).
- **NCD Form:** [FIXED] Chip-based symptom selection instead of long lists.
- **Immunization:** [FIXED] Full milestone-based child vaccination schedule.
- **Visits:** [FIXED] New Timeline View with "Call" shortcut.

---

## 🛠️ 7. The Roadmap (The "Next Session" Priority)

### **Priority 1: The Missing Backend**
The `backend` folder is empty. The mobile app is "talking to a wall".
- Need: Node.js/Express.
- Database: PostgreSQL (to mirror SQLite schema).
- Feature: Auth (JWT) and Sync Endpoints.

### **Priority 2: Local Notifications**
The `Local_Reminder` table exists, but the logic to trigger `awesome_notifications` is missing.
- Need: A `NotificationManager` class to check `Local_Reminder` and schedule local alerts.

### **Priority 3: Sync Center UI**
ASHA workers need a screen to see sync status.
- Need: Progress bar (e.g., "12/50 Records Synced").
- Need: "Manual Sync" button.

### **Priority 4: Data Validation**
Current forms are lax.
- Need: Aadhaar number validation (12 digits).
- Need: Phone number validation (10 digits).
- Need: Mandatory field checks before SQL `insert`.

---

## 📢 8. Final Instructions for the New AI
- **Do NOT** change the `DatabaseHelper.dart` structure without a migration plan.
- **Do NOT** use `withOpacity()` (deprecated in Flutter 3.22); use `withValues(alpha: ...)`.
- **DO** maintain the Marathi translation parity in `lib/l10n/app_mr.arb`.
- **DO** ensure all date parsing uses the `DateFormat('dd/MM/yyyy')` pattern to avoid crashing the age calculation logic.

**Source of Truth Confirmed. Sync complete. READY FOR BACKEND DEVELOPMENT.**
