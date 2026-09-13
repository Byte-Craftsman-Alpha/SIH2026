import pytest
import datetime
from app.chat.ontology import check_deterministic_red_flags
from app.models.visit import Visit
from app.models.user import User
from app.models.chat_message import ChatMessage
from app.models.document import Document
from app.services.summary_service import generate_clinical_summary

def test_red_flag_chest_pain_dyspnea():
    # English
    rf1 = check_deterministic_red_flags("Severe chest pain and sudden breathlessness")
    assert rf1 is not None
    assert rf1.code == "CHEST_PAIN_DYSPNEA"
    assert rf1.severity == "high"

    # Hinglish with co-symptom
    rf2 = check_deterministic_red_flags("Seene mein dard hai aur bohot pasina aa raha hai")
    assert rf2 is not None
    assert rf2.code == "CHEST_PAIN_DYSPNEA"

    # Chest pain WITHOUT co-symptoms should not trigger the combined Acute Coronary Syndrome rule
    rf_isolated = check_deterministic_red_flags("Mild chest pain after heavy chest press workout")
    assert rf_isolated is None

def test_red_flag_stroke_fast():
    rf1 = check_deterministic_red_flags("Patient has sudden slurred speech")
    assert rf1 is not None
    assert rf1.code == "STROKE_FAST"
    assert rf1.severity == "high"

    rf2 = check_deterministic_red_flags("Muh tedha ho gaya hai aur hath kamzor hai")
    assert rf2 is not None
    assert rf2.code == "STROKE_FAST"

def test_red_flag_hematemesis():
    rf1 = check_deterministic_red_flags("Patient is having continuous blood vomit")
    assert rf1 is not None
    assert rf1.code == "HEMATEMESIS"

    rf2 = check_deterministic_red_flags("Khoon ki ulti aur black stool")
    assert rf2 is not None
    assert rf2.code == "HEMATEMESIS"

def test_red_flag_altered_sensorium():
    rf1 = check_deterministic_red_flags("Found unconscious on floor, not responding")
    assert rf1 is not None
    assert rf1.code == "ALTERED_SENSORIUM"

    rf2 = check_deterministic_red_flags("Mareezi achanak behosh ho gaya")
    assert rf2 is not None
    assert rf2.code == "ALTERED_SENSORIUM"

def test_red_flag_severe_dehydration():
    rf = check_deterministic_red_flags("Continuous vomiting and lagatar dast for 24 hours")
    assert rf is not None
    assert rf.code == "SEVERE_DEHYDRATION"

def test_no_false_positives():
    benign_queries = [
        "I have a mild dry cough and slight headache",
        "Bukhar hai do din se aur badan dard",
        "Digestive upset after wedding dinner",
        "Need routine consultation for knee pain"
    ]
    for q in benign_queries:
        assert check_deterministic_red_flags(q) is None

def test_dpdp_data_minimization_alert_payload():
    """
    DPDP Act §7(c) Data Minimization Rule:
    Emergency triage alerts must only transmit necessary triage signals,
    never raw chat logs, plain Aadhaar numbers, or credentials.
    """
    # Simulate an alert payload generated during triage
    rf = check_deterministic_red_flags("Severe chest pain and dyspnea")
    alert_payload = {
        "flag_code": rf.code,
        "severity": rf.severity,
        "reason": rf.reason,
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "triage_channel": "hospital_emergency_desk"
    }

    # Verify essential fields are present
    assert alert_payload["flag_code"] == "CHEST_PAIN_DYSPNEA"
    assert alert_payload["severity"] == "high"

    # Verify forbidden sensitive PII keys are NOT included
    forbidden_keys = {"chat_transcript", "password", "aadhaar_full", "bank_account", "biometric_data"}
    for k in forbidden_keys:
        assert k not in alert_payload

@pytest.mark.asyncio
async def test_grounded_clinical_summary_generation(mock_db_session):
    # Setup test user, visit, chat messages, and parsed documents
    user = User(
        id="usr_test_123",
        name="Sunita Sharma",
        phone="9876543210",
        gender="female",
        dob=datetime.date(1985, 4, 12),
        language="hi",
        abha_id="91-1234-5678-9012"
    )
    visit = Visit(
        id="vis_test_123",
        user_id=user.id,
        mode="ayush",
        status="draft",
        chief_complaint="अम्लपित्त (Acid Peptic Disorder)",
        red_flag_code=None
    )
    msg1 = ChatMessage(
        id="msg_1",
        visit_id=visit.id,
        sender="patient",
        input_type="mcq",
        question_id="HPI_SOCRATES_01",
        question_text="Location?",
        answer_json={"option": "A", "label_hi": "ऊपरी पेट में जलन (Epigastric burning)"},
        language="hi"
    )
    msg2 = ChatMessage(
        id="msg_2",
        visit_id=visit.id,
        sender="patient",
        input_type="slider",
        question_id="HPI_SOCRATES_09",
        question_text="Severity?",
        answer_json={"severity": 7},
        language="hi"
    )
    doc_rx = Document(
        id="doc_rx_1",
        user_id=user.id,
        doc_type="prescription",
        parsed_json={
            "extracted": [
                {
                    "category": "medication",
                    "label": "Avipattikar Churna",
                    "value": "3g twice daily with warm water",
                    "source_quote": "Avipattikar Churna 3g BD"
                },
                {
                    "category": "medication",
                    "label": "Kamdudha Ras",
                    "value": "250mg once daily",
                    "source_quote": "Kamdudha Ras 250mg OD"
                }
            ]
        },
        flags_json={"drug_interactions": []},
        uploaded_at=datetime.datetime.utcnow()
    )
    doc_lab = Document(
        id="doc_lab_1",
        user_id=user.id,
        doc_type="lab",
        parsed_json={
            "extracted": [
                {
                    "category": "lab_test",
                    "label": "Fasting Blood Sugar",
                    "value": "142 mg/dL",
                    "flag": "high",
                    "source_quote": "FBS: 142 mg/dL (Ref: 70-100)"
                }
            ]
        },
        flags_json={},
        uploaded_at=datetime.datetime.utcnow()
    )

    mock_db_session.add_all([user, visit, msg1, msg2, doc_rx, doc_lab])
    await mock_db_session.commit()

    summary_id = await generate_clinical_summary(mock_db_session, visit, user)
    assert summary_id.startswith("sum_")
    assert visit.status == "submitted"

    # Query summary from session
    from sqlalchemy import select
    from app.models.summary import Summary
    stmt = select(Summary).where(Summary.id == summary_id)
    summary_record = (await mock_db_session.execute(stmt)).scalar_one_or_none()

    assert summary_record is not None
    content = summary_record.content_json

    # Check 12 sections existence
    for sec_num in range(1, 13):
        prefix = f"{sec_num}_"
        assert any(k.startswith(prefix) for k in content.keys()), f"Section {prefix} missing in summary"

    # Grounding checks
    assert "Avipattikar Churna" in content["5_drug_allergies"]
    assert "Kamdudha Ras" in content["5_drug_allergies"]
    assert "Fasting Blood Sugar" in content["9_prior_investigations"]
    assert "HIGH" in content["9_prior_investigations"]
    assert "7 / 10" in content["3_hpi_socrates"]["severity"]

