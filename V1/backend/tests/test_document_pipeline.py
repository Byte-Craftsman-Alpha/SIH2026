import pytest
from app.documents.schemas import PrescriptionData, LabReportData, MedicineItem, LabTestItem
from app.documents.pipeline import (
    apply_deterministic_lab_flags,
    detect_drug_interactions,
    flatten_extracted_data
)

def test_parse_prescription_flattening():
    data = PrescriptionData(
        doctor_name="Dr. Rajesh Sharma",
        medicines=[
            MedicineItem(
                name="Avipattikar Churna",
                dosage="3g",
                frequency="Twice daily",
                duration="14 days",
                confidence=0.95,
                source_quote="Avipattikar Churna 3g BD"
            ),
            MedicineItem(
                name="Sutshekhar Ras",
                dosage="250mg",
                frequency="BD",
                confidence=0.55,
                source_quote="Sutshekhar Ras 250mg"
            )
        ],
        diagnosis_hints=[{"text": "Amlapitta", "confidence": 0.88, "source_quote": "Dx: Amlapitta"}]
    )

    items = flatten_extracted_data(data, "prescription")
    assert len(items) == 3
    
    # First item verified
    assert items[0]["category"] == "medicine"
    assert items[0]["label"] == "Avipattikar Churna"
    assert items[0]["verified"] is True
    assert items[0]["source_quote"] == "Avipattikar Churna 3g BD"
    
    # Second item below 0.7 confidence -> unverified
    assert items[1]["verified"] is False

def test_lab_flags_deterministic():
    items = [
        {
            "category": "lab_value",
            "label": "Fasting Blood Sugar",
            "value": "420 mg/dL",
            "ref_range": "70 - 100 mg/dL",
            "flag": "normal"
        },
        {
            "category": "lab_value",
            "label": "Serum Potassium",
            "value": "2.2 mEq/L",
            "ref_range": "3.5 - 5.0 mEq/L",
            "flag": "normal"
        },
        {
            "category": "lab_value",
            "label": "Hemoglobin",
            "value": "11.2 g/dL",
            "ref_range": "12.0 - 15.5 g/dL",
            "flag": "normal"
        },
        {
            "category": "lab_value",
            "label": "Serum Bilirubin",
            "value": "0.8 mg/dL",
            "ref_range": "0.2 - 1.2 mg/dL",
            "flag": "normal"
        }
    ]

    processed = apply_deterministic_lab_flags(items)

    # Glucose 420 is critical
    assert processed[0]["flag"] == "critical"
    # Potassium 2.2 is critical
    assert processed[1]["flag"] == "critical"
    # Hemoglobin 11.2 vs 12-15.5 is low
    assert processed[2]["flag"] == "low"
    # Bilirubin 0.8 vs 0.2-1.2 is normal
    assert processed[3]["flag"] == "normal"

def test_drug_interactions_deterministic():
    meds = ["Ecosprin 75 (Aspirin)", "Warfarin 5mg", "Pantoprazole"]
    interactions = detect_drug_interactions(meds)
    assert len(interactions) >= 1
    assert "bleeding risk" in interactions[0].lower()

