-- ==============================================================================
-- MediKiosk Clinical History Intake Platform - Supabase PostgreSQL Schema
-- Compatible with Supabase SQL Editor and PostgREST API
-- ==============================================================================

-- 1. Create Enum Types
DO $$ BEGIN
    CREATE TYPE roleenum AS ENUM ('patient', 'doctor', 'triage', 'admin');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- 2. Audit Logs Table (Append-Only)
CREATE TABLE IF NOT EXISTS audit_logs (
    id VARCHAR(128) PRIMARY KEY,
    actor_type VARCHAR(64),
    actor_id VARCHAR(128),
    action VARCHAR(128),
    target_type VARCHAR(64),
    target_id VARCHAR(128),
    meta_json JSONB,
    ip VARCHAR(64),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 3. Hospitals Table
CREATE TABLE IF NOT EXISTS hospitals (
    id VARCHAR(128) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    lat FLOAT,
    lng FLOAT,
    is_ayush BOOLEAN DEFAULT FALSE,
    departments JSONB,
    queue_load VARCHAR(32) DEFAULT 'normal',
    phone VARCHAR(32),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 4. Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(128) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    dob DATE,
    gender VARCHAR(32),
    phone VARCHAR(32) UNIQUE NOT NULL,
    email VARCHAR(255),
    language VARCHAR(16) DEFAULT 'hi',
    abha_id VARCHAR(64),
    role roleenum DEFAULT 'patient',
    hashed_password VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 5. Doctors Table
CREATE TABLE IF NOT EXISTS doctors (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE SET NULL,
    hospital_id VARCHAR(128) REFERENCES hospitals(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    specialty VARCHAR(128),
    languages JSONB,
    is_ayush BOOLEAN DEFAULT FALSE,
    slots_json JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 6. Emergency Contacts Table
CREATE TABLE IF NOT EXISTS emergency_contacts (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    contact_type VARCHAR(32) DEFAULT 'family',
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    relation VARCHAR(64),
    consent_flag BOOLEAN DEFAULT TRUE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 7. Patient Profiles (Prakriti / Health Profile) Table
CREATE TABLE IF NOT EXISTS patient_profiles (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    prakriti_vata FLOAT DEFAULT 0.0,
    prakriti_pitta FLOAT DEFAULT 0.0,
    prakriti_kapha FLOAT DEFAULT 0.0,
    prakriti_dominant VARCHAR(64),
    sattva VARCHAR(64),
    samhanana VARCHAR(64),
    assessment_version INTEGER DEFAULT 1,
    assessed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    last_delta_check_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 8. Clinical Visits Table
CREATE TABLE IF NOT EXISTS visits (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    mode VARCHAR(32) DEFAULT 'general',
    status VARCHAR(32) DEFAULT 'draft',
    started_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    submitted_at TIMESTAMP WITHOUT TIME ZONE,
    chief_complaint TEXT,
    red_flag_code VARCHAR(64),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 9. Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    hospital_id VARCHAR(128) REFERENCES hospitals(id) ON DELETE SET NULL,
    doctor_id VARCHAR(128) REFERENCES doctors(id) ON DELETE SET NULL,
    slot_start TIMESTAMP WITHOUT TIME ZONE,
    slot_end TIMESTAMP WITHOUT TIME ZONE,
    urgency VARCHAR(32) DEFAULT 'regular',
    status VARCHAR(32) DEFAULT 'booked',
    summary_version_id VARCHAR(128),
    consent_id VARCHAR(128),
    token_no VARCHAR(32),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 10. Consents (DPDP Act Compliance) Table
CREATE TABLE IF NOT EXISTS consents (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    scope VARCHAR(128) NOT NULL,
    purpose TEXT NOT NULL,
    target_type VARCHAR(64),
    target_id VARCHAR(128),
    appointment_id VARCHAR(128) REFERENCES appointments(id) ON DELETE SET NULL,
    granted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITHOUT TIME ZONE,
    revoked_at TIMESTAMP WITHOUT TIME ZONE,
    consent_version INTEGER DEFAULT 1,
    audio_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 11. Chat Messages Table
CREATE TABLE IF NOT EXISTS chat_messages (
    id VARCHAR(128) PRIMARY KEY,
    visit_id VARCHAR(128) REFERENCES visits(id) ON DELETE CASCADE,
    sender VARCHAR(32) DEFAULT 'system',
    input_type VARCHAR(32) DEFAULT 'mcq',
    question_id VARCHAR(64),
    question_text TEXT,
    answer_json JSONB,
    language VARCHAR(16) DEFAULT 'hi',
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 12. Documents Table (OCR / Scans / Lab Reports)
CREATE TABLE IF NOT EXISTS documents (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    doc_type VARCHAR(64) DEFAULT 'prescription',
    original_path TEXT,
    parsed_json JSONB,
    confidence FLOAT DEFAULT 0.9,
    verify_status VARCHAR(32) DEFAULT 'verified',
    doc_date TIMESTAMP WITHOUT TIME ZONE,
    uploaded_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    flags_json JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 13. Summaries Table (12-Section Intake Summary)
CREATE TABLE IF NOT EXISTS summaries (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    visit_id VARCHAR(128) REFERENCES visits(id) ON DELETE CASCADE,
    appointment_id VARCHAR(128) REFERENCES appointments(id) ON DELETE SET NULL,
    content_json JSONB,
    lang VARCHAR(16) DEFAULT 'hi',
    status VARCHAR(32) DEFAULT 'draft',
    doctor_id VARCHAR(128) REFERENCES doctors(id) ON DELETE SET NULL,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 14. Alerts Table
CREATE TABLE IF NOT EXISTS alerts (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    flag_code VARCHAR(64) NOT NULL,
    channel VARCHAR(64) DEFAULT 'triage',
    payload_hash VARCHAR(128),
    status VARCHAR(32) DEFAULT 'pending',
    acked_by VARCHAR(128),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- 15. AYUSH Exams Table
CREATE TABLE IF NOT EXISTS ayush_exams (
    id VARCHAR(128) PRIMARY KEY,
    visit_id VARCHAR(128) REFERENCES visits(id) ON DELETE CASCADE,
    doctor_id VARCHAR(128) REFERENCES doctors(id) ON DELETE SET NULL,
    exam_json JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- Indexes for Fast Querying & PostgREST Filtering
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_visits_user_id ON visits(user_id);
CREATE INDEX IF NOT EXISTS idx_visits_status ON visits(status);
CREATE INDEX IF NOT EXISTS idx_chat_messages_visit_id ON chat_messages(visit_id);
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);
CREATE INDEX IF NOT EXISTS idx_consents_user_id ON consents(user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);

