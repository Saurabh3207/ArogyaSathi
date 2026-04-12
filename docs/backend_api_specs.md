# ArogyaSathi Backend API Specifications

## 1. Authentication (Demo Mode)
Current authentication uses a simulated OTP for rapid development.
- **Endpoint**: `/api/auth/send-otp`
- **Logic**: Any valid 10-digit mobile number + password triggers a "Demo OTP".
- **Demo OTP**: `123456`

## 2. Synchronization Protocol
The app uses an "Upsert" strategy for offline-first data integrity.
- **Push Endpoint**: `/api/sync/push` (POST)
- **Pull Endpoint**: `/api/sync/pull` (GET)

## 3. Data Entities
- **Household**: `{household_id, head_name, phone, village}`
- **Patient**: `{patient_id, household_id, first_name, gender, dob, is_high_risk}`
- **Health_Visit**: `{visit_id, patient_id, visit_date, visit_type, observations}`

## 4. Future Scope & Security Roadmap
This section outlines the transition from the current Demo Mode (Universal OTP) to a production-grade system.

### Phase 1: Production Security
- **Real SMS Gateway Integration**: Replace demo logic with Twilio/Msg91 for secure mobile authentication.
- **JWT Authentication**: Transition to stateless token-based auth for all API requests.
- **Biometric Logins**: Integrate Fingerprint/FaceID for faster field access.

### Phase 2: Advanced Features
- **Advanced Data Merging**: Implement Vector Clocks to handle complex synchronization conflicts.
- **Media Sync**: Add support for capturing and syncing photos (wound care) and voice memos.
- **Offline Maps**: Integration for plotting household locations without internet.

### Phase 3: PHC Analytics
- **Doctor's Dashboard**: A web portal for PHC doctors to monitor ASHA performance and patient trends.
- **Predictive Alerts**: AI-driven alerts for upcoming high-risk ANC visits.

---
*ArogyaSathi - Empowering Field Health Workers*
