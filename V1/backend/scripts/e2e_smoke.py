#!/usr/bin/env python3
"""
MediKiosk End-to-End Smoke Test Suite
Validates the complete 10-step patient, clinical, and safety lifecycle:
1. Health & Supabase Check
2. Patient Registration / Authentication (OTP & JWT)
3. Prakriti Assessment (Tridosha calculation)
4. Grounded Conversational Interviewer (SOCRATES dialogue)
5. Document Upload to Supabase Storage & Vision Pipeline
6. Patient Review & Verification of Extracted Data
7. Emergency Red Flag Detection & High-Priority Triage Alert
8. 12-Section Grounded Clinical Intake Summary Generation
9. Doctor Review & Decision Workflow
10. DPDP Consent Lifecycle (Grant, Inspect, Revoke)
"""

import sys
import os
import io
import asyncio
from datetime import date
from PIL import Image, ImageDraw

# Ensure backend root is on sys.path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

import httpx
from app.main import app
from app.database import init_db
from app.seed.seed_data import seed_demo_data
from app.database import AsyncSessionLocal

GREEN = "\033[92m"
RED = "\033[91m"
BLUE = "\033[94m"
BOLD = "\033[1m"
RESET = "\033[0m"

def log_step(step_no: int, name: str):
    print(f"\n{BOLD}{BLUE}============================================================{RESET}")
    print(f"{BOLD}{BLUE}STEP {step_no}: {name}{RESET}")
    print(f"{BOLD}{BLUE}============================================================{RESET}")

def log_success(msg: str):
    print(f"{GREEN}✓ {msg}{RESET}")

def log_fail(msg: str):
    print(f"{RED}✗ {msg}{RESET}")
    raise AssertionError(msg)

def generate_sample_prescription_image() -> bytes:
    """Generates a synthetic prescription image in memory with realistic text."""
    img = Image.new("RGB", (700, 450), color=(255, 255, 255))
    draw = ImageDraw.Draw(img)
    draw.text((30, 30), "ALL INDIA INSTITUTE OF AYURVEDA - OPD", fill=(0, 0, 0))
    draw.text((30, 60), "Patient: Ramesh Kumar | Age: 42 | Gender: M", fill=(50, 50, 50))
    draw.text((30, 90), "Date: 12-Sep-2026 | Dr. Rajesh Sharma (MD Ayu)", fill=(50, 50, 50))
    draw.line([(30, 115), (670, 115)], fill=(150, 150, 150), width=2)
    draw.text((30, 130), "Rx / Advise:", fill=(0, 0, 0))
    draw.text((50, 160), "1. Tab Ecosprin 75mg - 1 OD after dinner", fill=(0, 0, 0))
    draw.text((50, 190), "2. Tab Metformin 500mg - 1 BD before meals", fill=(0, 0, 0))
    draw.text((50, 220), "3. Avipattikar Churna - 3g BD with warm water", fill=(0, 0, 0))
    draw.text((30, 300), "Advice: Light bland diet, avoid oily/spicy foods.", fill=(50, 50, 50))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()

async def run_e2e_smoke():
    print(f"{BOLD}Starting MediKiosk E2E Smoke Test Suite...{RESET}")

    # Initialize DB & Seed Demo Data
    await init_db()
    async with AsyncSessionLocal() as session:
        await seed_demo_data(session)

    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test", timeout=30.0) as client:
        # -------------------------------------------------------------
        # 1. Health & Supabase Check
        # -------------------------------------------------------------
        log_step(1, "Health & Supabase Storage Verification")
        res = await client.get("/health")
        if res.status_code != 200:
            log_fail(f"Health check failed: {res.text}")
        data = res.json()
        assert data.get("db") == "ok", "Database health is not ok"
        assert data.get("supabase_connected") is True, "Supabase connection is false"
        log_success(f"Health check PASSED: db=ok, storage={data.get('storage')}, supabase_connected={data.get('supabase_connected')}")

        # -------------------------------------------------------------
        # 2. Patient Registration / Authentication
        # -------------------------------------------------------------
        log_step(2, "Patient Registration & JWT Authentication")
        phone = "9876543299"
        # Send OTP
        res = await client.post("/api/v1/auth/otp/send", json={"phone": phone})
        assert res.status_code == 200, f"OTP Send failed: {res.text}"
        
        # Verify OTP
        res = await client.post("/api/v1/auth/otp/verify", json={"phone": phone, "otp": "1234"})
        assert res.status_code == 200, f"OTP Verify failed: {res.text}"

        # Register User
        reg_payload = {
            "name": "Kavita Verma",
            "phone": phone,
            "gender": "female",
            "dob": "1992-06-15",
            "language": "hi",
            "abha_id": "91-8899-7766-5544",
            "emergency_contacts": [
                {"name": "Suresh Verma", "phone": "9876500001", "relation": "Spouse", "type": "family"}
            ],
            "consent": {
                "general_consent": True,
                "data_sharing": True,
                "audio_consent_flag": True
            }
        }
        res = await client.post("/api/v1/auth/register", json=reg_payload)
        assert res.status_code in (200, 201), f"Registration failed: {res.text}"
        reg_data = res.json()
        patient_token = reg_data["jwt"]["access_token"]
        patient_id = reg_data["user_id"]
        patient_headers = {"Authorization": f"Bearer {patient_token}"}
        log_success(f"Patient registered: ID={patient_id}, Token acquired.")

        # -------------------------------------------------------------
        # 3. Prakriti Assessment Flow
        # -------------------------------------------------------------
        log_step(3, "AYUSH Prakriti Assessment")
        prakriti_payload = {
            "answers": [
                {"qid": "PR_01", "option": "B", "mode": "mcq"},
                {"qid": "PR_02", "option": "B", "mode": "mcq"},
                {"qid": "PR_03", "option": "A", "mode": "mcq"},
                {"qid": "PR_04", "option": "B", "mode": "mcq"},
                {"qid": "PR_05", "option": "C", "mode": "mcq"},
                {"qid": "PR_06", "option": "B", "mode": "mcq"}
            ]
        }
        res = await client.post("/api/v1/profile/prakriti/assessment", json=prakriti_payload, headers=patient_headers)
        assert res.status_code == 200, f"Prakriti Assessment failed: {res.text}"
        prak_data = res.json()
        prak = prak_data["prakriti"]
        assert "dominant" in prak, "Dominant prakriti missing"
        log_success(f"Prakriti assessed: Dominant={prak['dominant']}, Vata={prak['vata']}, Pitta={prak['pitta']}, Kapha={prak['kapha']}")

        # -------------------------------------------------------------
        # 4. Grounded Conversational Interview Turns
        # -------------------------------------------------------------
        log_step(4, "Grounded Clinical Interview Session")
        chat_init_payload = {
            "mode": "ayush",
            "complaint": "पेट में जलन और खट्टी डकारें (Acid reflux and epigastric burning)",
            "language": "hi"
        }
        res = await client.post("/api/v1/chat/sessions", json=chat_init_payload, headers=patient_headers)
        assert res.status_code == 200, f"Chat session creation failed: {res.text}"
        session_data = res.json()
        session_id = session_data["session_id"]
        first_q = session_data["first_question"]
        assert first_q is not None, "Initial question is None"
        log_success(f"Session started: {session_id}, First Question ID={first_q['id']}: '{first_q['text'][:50]}...'")

        # Answer Question Turn 1
        ans1_payload = {
            "question_id": first_q["id"],
            "input_type": first_q.get("input", "mcq"),
            "answer": {"key": "A", "label": "ऊपरी पेट (Epigastric region)", "option": "A"},
            "session_lang": "hi"
        }
        res = await client.post(f"/api/v1/chat/sessions/{session_id}/answer", json=ans1_payload, headers=patient_headers)
        assert res.status_code == 200, f"Answer turn 1 failed: {res.text}"
        ans1_data = res.json()
        assert ans1_data["type"] == "question", f"Expected question type, got {ans1_data['type']}"
        next_q1 = ans1_data["question"]
        log_success(f"Turn 1 completed. Next Question ID={next_q1['id']}: '{next_q1['text'][:50]}...'")

        # Answer Question Turn 2 (Severity)
        ans2_payload = {
            "question_id": next_q1["id"],
            "input_type": "slider",
            "answer": {"severity": 6},
            "session_lang": "hi"
        }
        res = await client.post(f"/api/v1/chat/sessions/{session_id}/answer", json=ans2_payload, headers=patient_headers)
        assert res.status_code == 200, f"Answer turn 2 failed: {res.text}"
        ans2_data = res.json()
        log_success(f"Turn 2 completed. Received response type={ans2_data['type']}")

        # -------------------------------------------------------------
        # 5. Document Upload to Supabase Storage & Vision Pipeline
        # -------------------------------------------------------------
        log_step(5, "Document Upload & Vision Pipeline Extraction")
        img_bytes = generate_sample_prescription_image()
        files = {
            "file": ("prescription_sample.png", img_bytes, "image/png")
        }
        data = {
            "doc_type": "prescription",
            "notes": "Previous AIIA OPD prescription"
        }
        res = await client.post("/api/v1/documents", data=data, files=files, headers=patient_headers)
        assert res.status_code in (200, 201), f"Document upload failed: {res.text}"
        doc_data = res.json()
        doc_id = doc_data["document_id"]
        
        # Get parsed document items
        parsed_res = await client.get(f"/api/v1/documents/{doc_id}/parsed", headers=patient_headers)
        assert parsed_res.status_code == 200, f"Get parsed doc failed: {parsed_res.text}"
        parsed_data = parsed_res.json()
        extracted_items = parsed_data.get("extracted", [])
        log_success(f"Document uploaded: ID={doc_id}, Status={doc_data['status']}, Extracted Items Count={len(extracted_items)}")

        # -------------------------------------------------------------
        # 6. Patient Review & Verification of Extracted Items
        # -------------------------------------------------------------
        log_step(6, "Patient Verification of Extracted Medical Items")
        verify_payload = {
            "status": "verified",
            "edits": []
        }
        res = await client.post(f"/api/v1/documents/{doc_id}/verify", json=verify_payload, headers=patient_headers)
        assert res.status_code == 200, f"Document verify failed: {res.text}"
        verify_res = res.json()
        assert verify_res["status"] == "verified", f"Expected verified, got {verify_res.get('status')}"
        log_success(f"Document items verified by patient: Status={verify_res['status']}")

        # -------------------------------------------------------------
        # 7. Red Flag Emergency Trigger & Triage Alert
        # -------------------------------------------------------------
        log_step(7, "Red Flag Emergency Safety Trigger")
        emergency_ans = {
            "question_id": "HPI_SYMPTOMS",
            "input_type": "text",
            "answer": {"text": "Achanak seene mein bohot tez dard hai aur saans lene mein taklif ho rahi hai, bohot pasina aa raha hai"},
            "session_lang": "hi"
        }
        res = await client.post(f"/api/v1/chat/sessions/{session_id}/answer", json=emergency_ans, headers=patient_headers)
        assert res.status_code == 200, f"Emergency answer post failed: {res.text}"
        rf_data = res.json()
        assert rf_data["type"] == "red_flag", f"Expected red_flag type, got {rf_data['type']}"
        assert rf_data["session_status"] == "red_flag_pending", f"Expected red_flag_pending status, got {rf_data['session_status']}"
        flag_code = rf_data["red_flag"]["code"]
        assert flag_code == "CHEST_PAIN_DYSPNEA", f"Expected CHEST_PAIN_DYSPNEA, got {flag_code}"
        log_success(f"Emergency Trigger FIRED: Code={flag_code}, Severity={rf_data['red_flag']['severity']}, Status={rf_data['session_status']}")

        # -------------------------------------------------------------
        # 8. Clinical Intake Summary Generation (12 Sections Grounded)
        # -------------------------------------------------------------
        log_step(8, "12-Section Grounded Clinical Summary Generation")
        res = await client.post("/api/v1/summaries/generate", json={"visit_id": session_id}, headers=patient_headers)
        assert res.status_code == 200, f"Summary generation failed: {res.text}"
        summary_data = res.json()
        summary_id = summary_data["id"]
        content = summary_data["content"]
        
        # Verify all 12 clinical intake sections
        for s in range(1, 13):
            prefix = f"{s}_"
            assert any(k.startswith(prefix) for k in content.keys()), f"Section {prefix} missing in clinical summary"

        # Verify grounding with chat answers and documents
        assert "CHEST_PAIN_DYSPNEA" in content["11_red_flags"]
        assert content["1_patient_identity"]["name"] == "Kavita Verma"
        log_success(f"Clinical Summary generated: ID={summary_id}, 12 sections verified & grounded.")

        # -------------------------------------------------------------
        # 9. Doctor Review & Decision Workflow
        # -------------------------------------------------------------
        log_step(9, "Doctor Portal Review & Clinical Decision")
        # Doctor Login
        doc_login_res = await client.post("/api/v1/auth/login", json={"email": "doctor@aiia.gov.in", "password": "demo123"})
        assert doc_login_res.status_code == 200, f"Doctor login failed: {doc_login_res.text}"
        doc_token = doc_login_res.json()["access_token"]
        doc_headers = {"Authorization": f"Bearer {doc_token}"}

        # Doctor reads summary
        doc_view_res = await client.get(f"/api/v1/summaries/{summary_id}", headers=doc_headers)
        assert doc_view_res.status_code == 200, f"Doctor summary fetch failed: {doc_view_res.text}"

        # Doctor records decision: "accepted"
        decision_payload = {
            "decision": "accepted",
            "edits": [],
            "reason": "Reviewed clinical intake history, Ashtavidha pariksha ordered."
        }
        res = await client.post(f"/api/v1/summaries/{summary_id}/doctor-decision", json=decision_payload, headers=doc_headers)
        assert res.status_code == 200, f"Doctor decision failed: {res.text}"
        dec_data = res.json()
        assert dec_data["decision"] == "accepted", f"Expected decision accepted, got {dec_data['decision']}"
        log_success(f"Doctor decision recorded: Status={dec_data['status']}, Decision={dec_data['decision']}")

        # -------------------------------------------------------------
        # 10. DPDP Consent Lifecycle (Grant -> Verify -> Revoke)
        # -------------------------------------------------------------
        log_step(10, "DPDP Consent Lifecycle (Grant -> Verify Active -> Revoke)")
        consent_grant_payload = {
            "scope": "opd_consultation",
            "purpose": "Clinical consultation and Ashtavidha examination",
            "target_type": "doctor",
            "target_id": "doc_sharma",
            "appointment_id": None,
            "expires_at": None,
            "audio_flag": True
        }
        res = await client.post("/api/v1/consents", json=consent_grant_payload, headers=patient_headers)
        assert res.status_code == 201, f"Consent grant failed: {res.text}"
        consent_id = res.json()["id"]

        # Verify active consents list
        res = await client.get("/api/v1/consents/active", headers=patient_headers)
        assert res.status_code == 200, f"Active consents get failed: {res.text}"
        active_list = res.json()
        assert any(c["id"] == consent_id for c in active_list), "Granted consent not found in active list"
        log_success(f"Consent granted & active: ID={consent_id}")

        # Patient Revokes Consent
        res = await client.post(f"/api/v1/consents/{consent_id}/revoke", headers=patient_headers)
        assert res.status_code == 200, f"Consent revoke failed: {res.text}"
        assert res.json()["status"] == "revoked", "Consent status is not revoked"

        # Verify it is no longer in active list
        res = await client.get("/api/v1/consents/active", headers=patient_headers)
        assert res.status_code == 200
        active_after = res.json()
        assert not any(c["id"] == consent_id for c in active_after), "Revoked consent still appeared in active list"
        log_success(f"Consent successfully revoked: ID={consent_id}. Terminated from active authorizations.")

    print(f"\n{BOLD}{GREEN}============================================================{RESET}")
    print(f"{BOLD}{GREEN}ALL 10 STEPS OF MEDIKIOSK E2E SMOKE TEST PASSED PERFECTLY!{RESET}")
    print(f"{BOLD}{GREEN}============================================================{RESET}\n")

if __name__ == "__main__":
    asyncio.run(run_e2e_smoke())
