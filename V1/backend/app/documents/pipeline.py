import os
import re
import logging
from typing import List, Dict, Any, Tuple, Optional
from app.gemini.client import gemini_client
from app.prompts.extractor import EXTRACTOR_PROMPTS
from app.documents.schemas import (
    PrescriptionData, LabReportData, DischargeData,
    MedicineItem, LabTestItem
)
from app.supabase import get_supabase_client

logger = logging.getLogger("medikiosk.document_pipeline")

SCHEMA_BY_TYPE = {
    "prescription": PrescriptionData,
    "lab_report": LabReportData,
    "lab": LabReportData,
    "discharge_summary": DischargeData,
    "discharge": DischargeData,
    "other": PrescriptionData
}

KNOWN_DRUG_INTERACTIONS = [
    ({"warfarin", "aspirin"}, "High bleeding risk (Warfarin + Aspirin)"),
    ({"clopidogrel", "omeprazole"}, "Reduced antiplatelet efficacy (Clopidogrel + Omeprazole)"),
    ({"methotrexate", "ibuprofen"}, "Increased methotrexate toxicity"),
    ({"amiodarone", "digoxin"}, "Increased digoxin toxicity")
]

def parse_numeric_range(range_str: str) -> Tuple[Optional[float], Optional[float]]:
    """Extracts min and max bounds from reference range strings like '70 - 110 mg/dL'."""
    nums = re.findall(r"[-+]?(?:\d*\.\d+|\d+)", range_str)
    if len(nums) >= 2:
        try:
            return float(nums[0]), float(nums[1])
        except ValueError:
            pass
    return None, None

def apply_deterministic_lab_flags(items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Evaluates lab values deterministically against reference intervals
    and absolute critical danger boundaries. Never relies on LLM speculation.
    """
    for item in items:
        if item.get("category") != "lab_value":
            continue
            
        val_str = str(item.get("value", ""))
        name = str(item.get("label", "")).lower()
        ref_str = str(item.get("ref_range", ""))
        
        # Try numeric parse
        match = re.search(r"[-+]?(?:\d*\.\d+|\d+)", val_str)
        if not match:
            continue
            
        try:
            val = float(match.group())
        except ValueError:
            continue

        # 1. Absolute critical thresholds
        if ("glucose" in name or "sugar" in name or "fbs" in name or "rbs" in name):
            if val > 400.0 or val < 50.0:
                item["flag"] = "critical"
                continue
        elif "potassium" in name or "k+" in name:
            if val < 2.5 or val > 6.2:
                item["flag"] = "critical"
                continue
        elif "hemoglobin" in name or "hb" in name:
            if val < 6.0:
                item["flag"] = "critical"
                continue

        # 2. Reference range comparison
        low, high = parse_numeric_range(ref_str)
        if low is not None and high is not None:
            if val < low:
                item["flag"] = "low"
            elif val > high:
                item["flag"] = "high"
            else:
                item["flag"] = "normal"

    return items

def detect_drug_interactions(med_names: List[str]) -> List[str]:
    """Detects dangerous known drug-drug pairs using normalized keyword matching."""
    norm_names = [m.strip().lower() for m in med_names]
    alerts = []
    for drug_pair, warning in KNOWN_DRUG_INTERACTIONS:
        # Check if every drug in pair matches at least one medication name
        pair_matched = True
        for drug in drug_pair:
            if not any(drug in name for name in norm_names):
                pair_matched = False
                break
        if pair_matched:
            alerts.append(warning)
    return alerts

def flatten_extracted_data(data: Any, doc_type: str) -> List[Dict[str, Any]]:
    """Converts structured Pydantic model into granular document_items."""
    items: List[Dict[str, Any]] = []

    if isinstance(data, PrescriptionData):
        for med in data.medicines:
            items.append({
                "category": "medicine",
                "label": med.name,
                "value": f"{med.dosage} {med.frequency} {med.duration}".strip(),
                "instructions": med.instructions,
                "confidence": med.confidence,
                "verified": med.confidence >= 0.7,
                "source_quote": med.source_quote
            })
        for hint in data.diagnosis_hints:
            h_text = hint.text if hasattr(hint, "text") else hint.get("text", "")
            h_conf = hint.confidence if hasattr(hint, "confidence") else hint.get("confidence", 0.8)
            h_quote = hint.source_quote if hasattr(hint, "source_quote") else hint.get("source_quote", "")
            items.append({
                "category": "diagnosis",
                "label": h_text,
                "value": "Hint from prescription",
                "confidence": h_conf,
                "verified": h_conf >= 0.7,
                "source_quote": h_quote
            })

    elif isinstance(data, LabReportData):
        for test in data.tests:
            items.append({
                "category": "lab_value",
                "label": test.name,
                "value": test.value,
                "unit": test.unit,
                "ref_range": test.ref_range,
                "flag": test.flag,
                "confidence": test.confidence,
                "verified": test.confidence >= 0.7,
                "source_quote": test.source_quote
            })

    elif isinstance(data, DischargeData):
        for diag in data.diagnoses:
            items.append({
                "category": "diagnosis",
                "label": diag.get("name", "Diagnosis"),
                "value": diag.get("details", ""),
                "confidence": diag.get("confidence", 0.85),
                "verified": True,
                "source_quote": diag.get("source_quote", "")
            })
        for med in data.medicines:
            items.append({
                "category": "medicine",
                "label": med.name,
                "value": f"{med.dosage} {med.frequency}".strip(),
                "instructions": med.instructions,
                "confidence": med.confidence,
                "verified": med.confidence >= 0.7,
                "source_quote": med.source_quote
            })

    return items

async def process_document_pipeline(
    doc_id: str,
    doc_type: str,
    image_bytes: Optional[bytes] = None,
    storage_path: Optional[str] = None
) -> Dict[str, Any]:
    """
    Core document processing routine:
    1. Retrieves bytes from Supabase storage or local file.
    2. Executes Gemini 2.5 Flash multimodal vision extraction with structured schema.
    3. Flattens data and applies deterministic flags and interaction checks.
    """
    norm_type = doc_type.lower() if doc_type else "prescription"
    schema = SCHEMA_BY_TYPE.get(norm_type, PrescriptionData)
    prompt = EXTRACTOR_PROMPTS.get(norm_type, EXTRACTOR_PROMPTS["prescription"])

    # If image_bytes not provided directly, download from storage or disk
    if not image_bytes:
        if storage_path and os.path.exists(storage_path):
            with open(storage_path, "rb") as f:
                image_bytes = f.read()
        else:
            supabase = get_supabase_client()
            if supabase and storage_path:
                try:
                    image_bytes = supabase.storage.from_("medical-documents").download(storage_path)
                except Exception as exc:
                    logger.warning(f"Could not download from Supabase storage: {exc}")

    # Fallback to empty bytes placeholder if no image exists
    images = [image_bytes] if image_bytes else None

    # Call Gemini Multimodal Structured Extraction
    extracted = gemini_client.structured(
        system=prompt,
        payload={"doc_type": norm_type},
        schema=schema,
        images=images
    )

    items = flatten_extracted_data(extracted, norm_type)
    items = apply_deterministic_lab_flags(items)

    # Check drug interactions if medicines present
    med_names = [item["label"] for item in items if item["category"] == "medicine"]
    interactions = detect_drug_interactions(med_names)

    flags: Dict[str, Any] = {
        "critical_values": [i for i in items if i.get("flag") == "critical"],
        "abnormal_values": [i for i in items if i.get("flag") in ["high", "low"]],
        "drug_interactions": interactions
    }

    confidences = [item.get("confidence", 0.8) for item in items]
    overall_conf = sum(confidences) / len(confidences) if confidences else 0.85

    return {
        "document_id": doc_id,
        "status": "ready",
        "parsed_json": extracted.model_dump(),
        "items": items,
        "flags": flags,
        "overall_confidence": round(overall_conf, 2)
    }
