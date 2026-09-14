import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.hospital import Hospital
from app.models.doctor import Doctor
from app.models.user import User, RoleEnum
from app.models.profile import PatientProfile
from app.models.emergency_contact import EmergencyContact
from app.models.document import Document
from app.models.visit import Visit
from app.models.summary import Summary
from app.models.appointment import Appointment
from app.models.consent import Consent
from app.core.security import hash_password
from app.core.question_bank import DEMO_PARSED_PRESCRIPTION, DEMO_PARSED_LAB_REPORT

async def seed_demo_data(db: AsyncSession):
    # Check if already seeded
    existing_user = await db.execute(select(User).where(User.phone == "9876543210"))
    if existing_user.scalar_one_or_none():
        return

    # 1. Hospitals
    hospitals_data = [
        {
            "id": "hosp_aiia",
            "name": "All India Institute of Ayurveda (AIIA)",
            "address": "Mathura Road, Gautam Puri, Sarita Vihar, New Delhi - 110076",
            "lat": 28.5283,
            "lng": 77.2941,
            "is_ayush": True,
            "departments": ["Kayachikitsa (Internal Medicine)", "Panchakarma", "Shalya Tantra (Surgery)", "Prasuti & Stri Roga", "Kaumarbhritya (Pediatrics)"],
            "queue_load": "Moderate (15 min wait)",
            "phone": "011-26950401"
        },
        {
            "id": "hosp_aiims",
            "name": "All India Institute of Medical Sciences (AIIMS)",
            "address": "Sri Aurobindo Marg, Ansari Nagar, New Delhi - 110029",
            "lat": 28.5672,
            "lng": 77.2100,
            "is_ayush": False,
            "departments": ["General Medicine", "Cardiology", "Neurology", "Endocrinology", "Gastroenterology"],
            "queue_load": "Heavy (45 min wait)",
            "phone": "011-26588500"
        },
        {
            "id": "hosp_safdarjung",
            "name": "Vardhman Mahavir Medical College & Safdarjung Hospital",
            "address": "Ring Road, opposite AIIMS, New Delhi - 110029",
            "lat": 28.5700,
            "lng": 77.2065,
            "is_ayush": False,
            "departments": ["General Medicine", "Orthopedics", "Pulmonary Medicine", "Emergency & Trauma"],
            "queue_load": "High (35 min wait)",
            "phone": "011-26165060"
        },
        {
            "id": "hosp_rml",
            "name": "Dr. Ram Manohar Lohia Hospital",
            "address": "Baba Kharak Singh Marg, Connaught Place, New Delhi - 110001",
            "lat": 28.6256,
            "lng": 77.2008,
            "is_ayush": False,
            "departments": ["Internal Medicine", "Ayush Integrated Wing", "Dermatology", "ENT"],
            "queue_load": "Moderate (20 min wait)",
            "phone": "011-23365525"
        },
        {
            "id": "hosp_charak",
            "name": "Charak Palika Ayurvedic Hospital",
            "address": "Moti Bagh I, New Delhi - 110021",
            "lat": 28.5833,
            "lng": 77.1667,
            "is_ayush": True,
            "departments": ["Kayachikitsa", "Panchakarma", "Swasthavritta", "Dravyaguna"],
            "queue_load": "Low (5 min wait)",
            "phone": "011-24672620"
        }
    ]

    for h in hospitals_data:
        hosp = Hospital(**h)
        db.add(hosp)

    # 2. Staff Users (Doctor & Admin)
    doc_user = User(
        id="user_doc_sharma",
        name="Dr. Rajesh Sharma",
        dob=datetime.date(1978, 5, 14),
        gender="male",
        phone="9999990001",
        email="doctor@aiia.gov.in",
        language="hi",
        abha_id="91-4455-6677-8899",
        role=RoleEnum.doctor,
        hashed_password=hash_password("demo123"),
        is_active=True
    )
    db.add(doc_user)

    admin_user = User(
        id="user_admin",
        name="Admin AIIA",
        dob=datetime.date(1985, 1, 1),
        gender="other",
        phone="9999990002",
        email="admin@aiia.gov.in",
        language="en",
        abha_id="91-0000-0000-0001",
        role=RoleEnum.admin,
        hashed_password=hash_password("admin123"),
        is_active=True
    )
    db.add(admin_user)

    # 3. Doctors
    doctors_data = [
        {
            "id": "doc_sharma",
            "user_id": "user_doc_sharma",
            "hospital_id": "hosp_aiia",
            "name": "Dr. Rajesh Sharma (MD Ayu)",
            "specialty": "Kayachikitsa (Internal Medicine & Diabetes)",
            "languages": ["hi", "en", "sa"],
            "is_ayush": True,
            "slots_json": [
                "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM",
                "11:30 AM", "12:00 PM", "02:00 PM", "02:30 PM", "03:00 PM"
            ]
        },
        {
            "id": "doc_priya",
            "user_id": None,
            "hospital_id": "hosp_aiia",
            "name": "Dr. Priya Nair (MD Ayu)",
            "specialty": "Panchakarma & Chronic Pain",
            "languages": ["hi", "en", "ml"],
            "is_ayush": True,
            "slots_json": ["09:00 AM", "10:00 AM", "11:00 AM", "02:00 PM", "03:00 PM"]
        },
        {
            "id": "doc_kapoor",
            "user_id": None,
            "hospital_id": "hosp_aiims",
            "name": "Dr. Amit Kapoor (MD, DM)",
            "specialty": "Cardiology",
            "languages": ["hi", "en"],
            "is_ayush": False,
            "slots_json": ["10:00 AM", "11:00 AM", "12:00 PM", "03:00 PM"]
        },
        {
            "id": "doc_ananya",
            "user_id": None,
            "hospital_id": "hosp_aiims",
            "name": "Dr. Ananya Roy (MD)",
            "specialty": "General Medicine",
            "languages": ["hi", "en", "bn"],
            "is_ayush": False,
            "slots_json": ["09:30 AM", "10:30 AM", "11:30 AM", "02:30 PM"]
        },
        {
            "id": "doc_verma",
            "user_id": None,
            "hospital_id": "hosp_charak",
            "name": "Dr. A. Verma (BAMS, MD)",
            "specialty": "Kayachikitsa & Lifestyle Disorders",
            "languages": ["hi", "en"],
            "is_ayush": True,
            "slots_json": ["09:00 AM", "09:45 AM", "10:30 AM", "11:15 AM", "02:00 PM"]
        }
    ]

    for d in doctors_data:
        doc = Doctor(**d)
        db.add(doc)

    # 4. Demo Patient 1: Ramesh Kumar
    patient1 = User(
        id="user_ramesh",
        name="Ramesh Kumar",
        dob=datetime.date(1962, 4, 11),
        gender="male",
        phone="9876543210",
        email="ramesh.kumar@example.com",
        language="hi",
        abha_id="91-1234-5678-9012",
        role=RoleEnum.patient,
        hashed_password=None,
        is_active=True
    )
    db.add(patient1)

    # Emergency Contacts for Ramesh
    ec1 = EmergencyContact(
        id="ec_1",
        user_id="user_ramesh",
        contact_type="family",
        name="Sita Devi",
        phone="9876543299",
        relation="Wife (पत्नी)",
        consent_flag=True,
        active=True
    )
    ec2 = EmergencyContact(
        id="ec_2",
        user_id="user_ramesh",
        contact_type="doctor",
        name="Dr. Mehta (Family Physician)",
        phone="9876543288",
        relation="Family Doctor",
        consent_flag=True,
        active=True
    )
    db.add(ec1)
    db.add(ec2)

    # Prakriti Profile for Ramesh
    prof1 = PatientProfile(
        user_id="user_ramesh",
        prakriti_vata=0.55,
        prakriti_pitta=0.30,
        prakriti_kapha=0.15,
        prakriti_dominant="Vata-Pitta",
        sattva="Pravara (Strong)",
        samhanana="Madhyama (Medium)",
        assessment_version=1,
        assessed_at=datetime.datetime.utcnow() - datetime.timedelta(days=30),
        last_delta_check_at=datetime.datetime.utcnow() - datetime.timedelta(days=2)
    )
    db.add(prof1)

    # Seeded Documents for Ramesh
    doc1 = Document(
        id="doc_presc_01",
        user_id="user_ramesh",
        doc_type="prescription",
        original_path="/uploads/demo_prescription_01.jpg",
        parsed_json=DEMO_PARSED_PRESCRIPTION,
        confidence=0.86,
        verify_status="verified",
        doc_date=datetime.datetime(2026, 2, 14),
        uploaded_at=datetime.datetime(2026, 2, 15),
        flags_json=DEMO_PARSED_PRESCRIPTION["flags"]
    )
    doc2 = Document(
        id="doc_lab_01",
        user_id="user_ramesh",
        doc_type="lab_report",
        original_path="/uploads/demo_lab_01.pdf",
        parsed_json=DEMO_PARSED_LAB_REPORT,
        confidence=0.92,
        verify_status="verified",
        doc_date=datetime.datetime(2026, 8, 20),
        uploaded_at=datetime.datetime(2026, 8, 21),
        flags_json=DEMO_PARSED_LAB_REPORT["flags"]
    )
    db.add(doc1)
    db.add(doc2)

    # Active Visit for Ramesh
    visit1 = Visit(
        id="visit_ramesh_01",
        user_id="user_ramesh",
        mode="ayush",
        status="submitted",
        started_at=datetime.datetime.utcnow() - datetime.timedelta(hours=2),
        submitted_at=datetime.datetime.utcnow() - datetime.timedelta(hours=1),
        chief_complaint="पेट में जलन और भारीपन (Stomach burning & heaviness)",
        red_flag_code=None
    )
    db.add(visit1)

    # 12-section summary for Ramesh
    summary_content = {
        "1_patient_identity": {
            "name": "Ramesh Kumar", "age": 64, "gender": "Male",
            "phone_masked": "+91 98765-XXXXX", "abha_masked": "91-XXXX-XXXX-9012"
        },
        "2_chief_complaint": "Epigastric burning and heaviness after meals for past 2 weeks (भोजनोपरांत विदाह व गौरव).",
        "3_hpi_socrates": {
            "site": "Epigastric region (Upper abdomen)",
            "onset": "2 weeks ago, gradual onset",
            "character": "Burning sensation with post-prandial fullness",
            "radiation": "None",
            "associations": ["Mild sour belching (Amlodgara)", "Disturbed sleep"],
            "timing": "Aggravates 1-2 hours after lunch/dinner",
            "exacerbating": "Spicy food, tea, lying down immediately after eating",
            "relieving": "Cold milk, sitting upright",
            "severity": "6 / 10"
        },
        "4_past_medical_surgical": "Known case of Type 2 Diabetes Mellitus (8 years), Hypertension (5 years). No prior surgeries.",
        "5_drug_allergies": "Metformin 500mg BD, Amlodipine 5mg OD. Triphala Churna 5g at bedtime. No known drug allergies.",
        "6_family_history": "Mother had Type 2 Diabetes; Father had Hypertension.",
        "7_personal_habits": "Non-smoker, non-alcoholic. Sedentary routine. Irregular meal timings. Sleeps 5-6 hours.",
        "8_review_of_systems": "GI: Acidity, bloating. CVS: No chest pain/palpitations. Resp: No dyspnea. CNS: Normal.",
        "9_prior_investigations": {
            "fbs": "186 mg/dL (HIGH)",
            "hba1c": "8.2 % (HIGH)",
            "total_cholesterol": "220 mg/dL (BORDERLINE HIGH)",
            "creatinine": "0.9 mg/dL (NORMAL)"
        },
        "10_ayush_profile": {
            "prakriti_baseline": "Vata-Pitta (V: 55%, P: 30%, K: 15%)",
            "current_vikriti": "Pitta-Vata Pradhana (Pitta aggravation with Vata blockage)",
            "agni": "Mandagni transitioning to Tikshnagni (Irregular/slow digestion)",
            "koshtha": "Krura Koshtha (Mild constipation tendency)",
            "ahara_vihara": "Ushna-Tikshna Ahara (Spicy foods), Ratrijagarana (Late sleeping)",
            "nidana": "Aharaja (Viruddha Ahara / irregular food timings) + Manasika (Work stress)"
        },
        "11_red_flags": "None detected during current intake.",
        "12_ai_disclaimer": "AI-generated intake draft — not a clinical diagnosis. Kindly verify with patient examination."
    }

    sum1 = Summary(
        id="sum_ramesh_01",
        user_id="user_ramesh",
        visit_id="visit_ramesh_01",
        appointment_id="appt_ramesh_01",
        content_json=summary_content,
        lang="hi",
        status="draft",
        doctor_id="doc_sharma",
        version=1
    )
    db.add(sum1)

    # Consent for Doctor Sharma
    now = datetime.datetime.utcnow()
    cons1 = Consent(
        id="cons_ramesh_01",
        user_id="user_ramesh",
        scope="summary_plus_documents",
        purpose="consultation",
        target_type="doctor",
        target_id="doc_sharma",
        appointment_id="appt_ramesh_01",
        granted_at=now,
        expires_at=now + datetime.timedelta(hours=4),
        revoked_at=None,
        consent_version=1,
        audio_flag=True
    )
    db.add(cons1)

    # Appointment for Ramesh with Dr. Sharma today
    appt1 = Appointment(
        id="appt_ramesh_01",
        user_id="user_ramesh",
        hospital_id="hosp_aiia",
        doctor_id="doc_sharma",
        slot_start=now.replace(hour=10, minute=30, second=0, microsecond=0),
        slot_end=now.replace(hour=11, minute=0, second=0, microsecond=0),
        urgency="regular",
        status="booked",
        summary_version_id="sum_ramesh_01",
        consent_id="cons_ramesh_01",
        token_no="A-042"
    )
    db.add(appt1)

    # Demo Patient 2: Sunita Devi (Urgent case)
    patient2 = User(
        id="user_sunita",
        name="Sunita Devi",
        dob=datetime.date(1981, 8, 25),
        gender="female",
        phone="9876543211",
        email="sunita@example.com",
        language="hi",
        abha_id="91-9876-5432-1098",
        role=RoleEnum.patient,
        hashed_password=None,
        is_active=True
    )
    db.add(patient2)

    prof2 = PatientProfile(
        user_id="user_sunita",
        prakriti_vata=0.20,
        prakriti_pitta=0.50,
        prakriti_kapha=0.30,
        prakriti_dominant="Pitta-Kapha",
        sattva="Madhyama",
        samhanana="Pravara",
        assessment_version=1,
        assessed_at=datetime.datetime.utcnow() - datetime.timedelta(days=10),
        last_delta_check_at=datetime.datetime.utcnow() - datetime.timedelta(days=1)
    )
    db.add(prof2)

    appt2 = Appointment(
        id="appt_sunita_02",
        user_id="user_sunita",
        hospital_id="hosp_aiia",
        doctor_id="doc_sharma",
        slot_start=now.replace(hour=11, minute=0, second=0, microsecond=0),
        slot_end=now.replace(hour=11, minute=30, second=0, microsecond=0),
        urgency="urgent",
        status="booked",
        summary_version_id=None,
        consent_id=None,
        token_no="U-007"
    )
    db.add(appt2)

    await db.commit()

MOCK_PATIENT_ABHA_PROFILE = {
    "abhaNumber": "91-3422-9844-1234",
    "name": "Ramesh Kumar",
    "gender": "M",
    "yearOfBirth": "1960",
    "monthOfBirth": "05",
    "dayOfBirth": "12",
    "mobile": "9876543210",
    "phrAddress": ["ramesh1960@abdm"]
}
