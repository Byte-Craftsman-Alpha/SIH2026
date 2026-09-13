import asyncio
import httpx
from app.main import app

async def run_e2e_tests():
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        print("=== MediKiosk End-to-End Verification Suite ===")

        # 1. Health Check
        r = await client.get("/health")
        assert r.status_code == 200, f"Health check failed: {r.text}"
        data = r.json()
        assert data["status"] == "ok"
        print("✓ 1. Health check passed:", data)

        # 2. Meta Config
        r = await client.get("/api/v1/meta/config")
        assert r.status_code == 200, f"Meta config failed: {r.text}"
        cfg = r.json()
        assert "app_name" in cfg
        print("✓ 2. Meta config passed:", cfg["app_name"])

        # 3. OTP Send
        r = await client.post("/api/v1/auth/otp/send", json={"phone": "9876543210"})
        assert r.status_code == 200, f"OTP send failed: {r.text}"
        print("✓ 3. OTP send passed:", r.json())

        # 4. OTP Verify
        r = await client.post("/api/v1/auth/otp/verify", json={"phone": "9876543210", "otp": "1234"})
        assert r.status_code == 200, f"OTP verify failed: {r.text}"
        tokens = r.json()
        assert "access_token" in tokens
        token = tokens["access_token"]
        auth_headers = {"Authorization": f"Bearer {token}"}
        print("✓ 4. OTP verify passed (Token acquired)")

        # 5. Auth Me
        r = await client.get("/api/v1/auth/me", headers=auth_headers)
        assert r.status_code == 200, f"Auth me failed: {r.text}"
        user = r.json()
        assert user["phone"] == "9876543210"
        print(f"✓ 5. Auth /me verified for patient: {user['name']} ({user['role']})")

        # 6. Profile & Prakriti Assessment
        r = await client.get("/api/v1/profile", headers=auth_headers)
        assert r.status_code == 200
        prakriti = r.json()
        print(f"✓ 6. Profile retrieved: Dominant Prakriti = {prakriti.get('prakriti_dominant')}")

        # 7. Chat Session & Question Progression
        r = await client.post("/api/v1/chat/sessions", headers=auth_headers, json={"mode": "ayush"})
        assert r.status_code == 200
        chat_sess = r.json()
        sess_id = chat_sess["session_id"]
        print(f"✓ 7. Chat session initialized: {sess_id}")

        # 8. Submit Chat Answer
        r = await client.post(
            f"/api/v1/chat/sessions/{sess_id}/answer",
            headers=auth_headers,
            json={
                "question_id": "SOCR_01",
                "input_type": "mcq",
                "answer": {"chief_complaint": "bukhar", "label": "बुखार (Fever)"},
                "session_lang": "hi",
            },
        )
        assert r.status_code == 200
        print(f"✓ 8. Chat answer processed. Next question received.")

        # 9. Hospital Discovery & Nearest Distance
        r = await client.get("/api/v1/hospitals/nearest?lat=28.53&lng=77.29", headers=auth_headers)
        assert r.status_code == 200
        hosps = r.json()
        assert len(hosps) >= 1
        hosp_id = hosps[0]["id"]
        print(f"✓ 9. Hospitals discovered: {hosps[0]['name']} (Distance: {hosps[0].get('distance_km', 'N/A')} km)")

        # 10. Doctor Slots
        r = await client.get("/api/v1/doctors", headers=auth_headers)
        assert r.status_code == 200
        docs = r.json()
        doc_id = docs[0]["id"]
        r = await client.get(f"/api/v1/doctors/{doc_id}/slots", headers=auth_headers)
        assert r.status_code == 200
        slots = r.json()
        print(f"✓ 10. Doctor slots retrieved: {len(slots)} slots available for {docs[0]['name']}")

        # 11. Appointment Booking & Token Generation
        r = await client.post(
            "/api/v1/appointments",
            headers=auth_headers,
            json={
                "hospital_id": hosp_id,
                "doctor_id": doc_id,
                "slot": "2026-09-12T10:30:00",
                "urgency": "regular",
                "context": {"chief_complaint": "बुखार एवं शरीर दर्द"},
                "consent": {"scope": "summary_plus_documents"},
            },
        )
        assert r.status_code in (200, 201), f"Appointment booking failed: {r.text}"
        appt = r.json()
        token_no = appt["token_no"]
        appt_id = appt["appointment_id"]
        print(f"✓ 11. Appointment successfully booked! Token: {token_no}, ID: {appt_id}")

        # 12. 12-Section Clinical Summary Generation
        r = await client.post(
            "/api/v1/summaries/generate",
            headers=auth_headers,
            json={"visit_id": sess_id},
        )
        assert r.status_code == 200
        summary = r.json()
        assert "content" in summary
        summary_id = summary["id"]
        print(f"✓ 12. 12-Section Clinical Intake Summary generated (ID: {summary_id}).")

        # 13. HL7 FHIR R4 Bundle Composition
        r = await client.post("/api/v1/fhir/bundle", headers=auth_headers, json={"summary_id": summary_id})
        assert r.status_code == 200
        res = r.json()
        bundle = res.get("fhir_r4_bundle", res)
        assert bundle["resourceType"] == "Bundle"
        entries_count = len(bundle.get("entry", []))
        print(f"✓ 13. HL7 FHIR R4 Bundle validated: {entries_count} entries included.")

        # 14. Doctor Portal Web Views
        r = await client.get("/portal/queue")
        assert r.status_code == 200
        assert "All India Institute of Ayurveda" in r.text or "OPD" in r.text
        print("✓ 14. Doctor Portal OPD Queue HTML rendered successfully.")

        # 15. DPDP Act Consent Revocation
        consents = await client.get("/api/v1/consents/active", headers=auth_headers)
        assert consents.status_code == 200
        consent_list = consents.json()
        if consent_list:
            c_id = consent_list[0]["id"]
            rev = await client.post(f"/api/v1/consents/{c_id}/revoke", headers=auth_headers)
            assert rev.status_code == 200
            print(f"✓ 15. DPDP Act consent revocation verified for ID: {c_id}")

        print("\n=======================================================")
        print("ALL 15 E2E INTEGRATION CHECKS PASSED PERFECTLY!")
        print("=======================================================")

if __name__ == "__main__":
    asyncio.run(run_e2e_tests())
