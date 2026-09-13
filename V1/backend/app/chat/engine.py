import logging
import re
from typing import Dict, Any, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.visit import Visit
from app.models.chat_message import ChatMessage
from app.models.profile import PatientProfile
from app.models.document import Document
from app.gemini.client import gemini_client
from app.gemini.schemas import InterviewStep, Question, RedFlag, Verdict, QuestionOptionItem, ProgressInfo
from app.prompts.interviewer import get_interviewer_prompt
from app.prompts.verifier import VERIFIER_PROMPT
from app.chat.ontology import (
    check_deterministic_red_flags,
    get_deterministic_fallback_question,
    detect_complaint_key
)

logger = logging.getLogger("medikiosk.chat_engine")

DEFAULT_TOTAL_STEPS = 6

def sanitize_option_item(opt: QuestionOptionItem, index: int) -> QuestionOptionItem:
    """Ensures option has a single-letter key, valid Hindi & English labels, and a visual icon."""
    letters = ["A", "B", "C", "D", "E", "F", "G"]
    # 1. Single letter key
    if not opt.key or len(opt.key) > 2 or opt.key not in letters:
        opt.key = letters[index % len(letters)]

    # 2. Hindi label validation
    has_devanagari = any('\u0900' <= char <= '\u097f' for char in opt.label_hi)
    if not opt.label_hi or not has_devanagari:
        if any('\u0900' <= char <= '\u097f' for char in opt.label):
            opt.label_hi = opt.label
        else:
            lower_lbl = (opt.label or opt.label_en).lower()
            if "morning" in lower_lbl:
                opt.label_hi = "सुबह के समय (Increases in morning)"
            elif "evening" in lower_lbl or "night" in lower_lbl:
                opt.label_hi = "शाम या रात को (Increases in evening)"
            elif "constant" in lower_lbl or "throughout" in lower_lbl or "all day" in lower_lbl:
                opt.label_hi = "पूरे दिन एक जैसा / लगातार (Constant throughout day)"
            elif "intermittent" in lower_lbl or "comes and goes" in lower_lbl:
                opt.label_hi = "रुक-रुक कर आता है (Intermittent)"
            elif "today" in lower_lbl:
                opt.label_hi = "आज ही शुरू हुआ (Since today)"
            elif "2-3 day" in lower_lbl:
                opt.label_hi = "पिछले 2-3 दिनों से (Past 2-3 days)"
            elif "week" in lower_lbl:
                opt.label_hi = "लगभग 1 हफ्ते से (Past 1 week)"
            elif "chill" in lower_lbl or "shiver" in lower_lbl:
                opt.label_hi = "ठंड और कंपकंपी के साथ (With chills & rigors)"
            elif "sweat" in lower_lbl:
                opt.label_hi = "बहुत पसीना आता है (Profuse sweating)"
            elif "both" in lower_lbl:
                opt.label_hi = "दोनों महसूस होते हैं (Both chills & sweating)"
            elif "none" in lower_lbl:
                opt.label_hi = "इनमें से कुछ नहीं (None of these)"
            elif "yes" in lower_lbl:
                opt.label_hi = "हाँ (Yes)"
            elif "no" in lower_lbl:
                opt.label_hi = "नहीं (No)"
            elif "unsure" in lower_lbl:
                opt.label_hi = "मालूम नहीं (Unsure)"
            else:
                opt.label_hi = opt.label or opt.label_en or f"विकल्प {opt.key}"

    if not opt.label_en:
        opt.label_en = opt.label or opt.label_hi
    if not opt.label:
        opt.label = opt.label_hi

    # 3. Visual icon resolution
    valid_icons = [
        "sun", "moon", "clock", "calendar", "thermostat", "chills",
        "sweat", "pain", "medicine", "food", "breath", "warning",
        "check", "cross", "help", "body"
    ]
    if not opt.icon or opt.icon not in valid_icons:
        combined_txt = f"{opt.label_hi} {opt.label_en} {opt.label}".lower()
        if any(w in combined_txt for w in ["सुबह", "morning", "sun"]):
            opt.icon = "sun"
        elif any(w in combined_txt for w in ["शाम", "रात", "evening", "night", "moon"]):
            opt.icon = "moon"
        elif any(w in combined_txt for w in ["लगातार", "पूरे दिन", "दिनभर", "constant", "throughout", "clock", "time"]):
            opt.icon = "clock"
        elif any(w in combined_txt for w in ["दिन", "हफ्ते", "हफ़्ते", "महीने", "calendar", "today", "days", "week", "month"]):
            opt.icon = "calendar"
        elif any(w in combined_txt for w in ["बुखार", "तापमान", "fever", "temperature", "hot", "garam"]):
            opt.icon = "thermostat"
        elif any(w in combined_txt for w in ["ठंड", "कंपकंपी", "chill", "cold", "shiver", "kaanp"]):
            opt.icon = "chills"
        elif any(w in combined_txt for w in ["पसीना", "sweat", "perspiration"]):
            opt.icon = "sweat"
        elif any(w in combined_txt for w in ["दर्द", "सिर", "pain", "headache", "ache"]):
            opt.icon = "pain"
        elif any(w in combined_txt for w in ["दवा", "गोली", "medicine", "tablet", "pill", "syrup"]):
            opt.icon = "medicine"
        elif any(w in combined_txt for w in ["भूख", "खाना", "पाचन", "food", "appetite", "digestion", "agni"]):
            opt.icon = "food"
        elif any(w in combined_txt for w in ["सांस", "खांसी", "cough", "breath", "lungs", "gala"]):
            opt.icon = "breath"
        elif any(w in combined_txt for w in ["हाँ", "yes", "theek", "sahimat"]):
            opt.icon = "check"
        elif any(w in combined_txt for w in ["नहीं", "no", "nahin"]):
            opt.icon = "cross"
        elif any(w in combined_txt for w in ["मालूम नहीं", "पता नहीं", "unsure", "unknown", "help"]):
            opt.icon = "help"
        else:
            opt.icon = "body"

    return opt

async def assemble_context(
    user_id: str,
    visit_id: str,
    db: Optional[AsyncSession] = None
) -> Dict[str, Any]:
    """
    Assembles grounded clinical context from patient profile,
    parsed document items (prescriptions, labs, discharges), and recent conversation turns.
    All data is treated as UNTRUSTED DATA inside JSON payload.
    """
    recent_messages: List[Dict[str, Any]] = []
    profile_summary: Dict[str, Any] = {}
    parsed_sources: List[Dict[str, Any]] = []
    answers_so_far: List[Dict[str, Any]] = []
    chief_complaint: str = ""

    if db:
        try:
            # 0. Visit details (chief complaint)
            vstmt = select(Visit).where(Visit.id == visit_id)
            vis = (await db.execute(vstmt)).scalar_one_or_none()
            if vis and vis.chief_complaint and vis.chief_complaint != "Unspecified complaint":
                chief_complaint = vis.chief_complaint

            # 1. Recent conversation (last 8 messages)
            stmt = select(ChatMessage).where(ChatMessage.visit_id == visit_id).order_by(ChatMessage.created_at.desc()).limit(8)
            res = await db.execute(stmt)
            msgs = res.scalars().all()
            for m in reversed(msgs):
                recent_messages.append({
                    "sender": m.sender,
                    "question_id": m.question_id,
                    "text": m.question_text if m.sender == "system" else str(m.answer_json or ""),
                    "input_type": m.input_type
                })
                if m.sender == "patient" and m.answer_json:
                    answers_so_far.append(m.answer_json)

            # 2. Patient Profile
            pstmt = select(PatientProfile).where(PatientProfile.user_id == user_id)
            prof = (await db.execute(pstmt)).scalar_one_or_none()
            if prof:
                profile_summary = {
                    "prakriti_dominant": prof.prakriti_dominant,
                    "prakriti_scores": {
                        "vata": prof.prakriti_vata,
                        "pitta": prof.prakriti_pitta,
                        "kapha": prof.prakriti_kapha
                    },
                    "sattva": prof.sattva,
                    "samhanana": prof.samhanana
                }

            # 3. Parsed medical documents (Prescriptions, Labs, Discharges)
            dstmt = select(Document).where(Document.user_id == user_id).order_by(Document.uploaded_at.desc()).limit(5)
            docs = (await db.execute(dstmt)).scalars().all()
            for d in docs:
                if not d.parsed_json:
                    continue
                extracted = d.parsed_json.get("extracted", {})

                # If extracted is list
                if isinstance(extracted, list):
                    for item in extracted[:6]:
                        parsed_sources.append({
                            "ref_id": f"{d.id}_{item.get('label', item.get('name', ''))}",
                            "doc_type": d.doc_type,
                            "category": item.get("category", "General"),
                            "label": item.get("label", item.get("name", "")),
                            "value": item.get("value", ""),
                            "flag": item.get("flag", "normal"),
                            "source_quote": item.get("source_quote", "")
                        })

                # If extracted is dict
                elif isinstance(extracted, dict):
                    # Active medicines from prescriptions
                    for med in extracted.get("medicines", []):
                        parsed_sources.append({
                            "ref_id": f"{d.id}_{med.get('name', '')}",
                            "doc_type": d.doc_type,
                            "category": "Medication (चालू दवा)",
                            "label": med.get("name", ""),
                            "value": f"{med.get('dosage', '')} {med.get('frequency', '')} ({med.get('instructions', '')})",
                            "flag": "active_medication",
                            "source_quote": f"{med.get('name', '')} {med.get('instructions', '')}"
                        })

                    # Lab tests & abnormal values
                    for test in extracted.get("tests", []):
                        parsed_sources.append({
                            "ref_id": f"{d.id}_{test.get('name', '')}",
                            "doc_type": d.doc_type,
                            "category": "Lab Test (जांच रिपोर्ट)",
                            "label": test.get("name", ""),
                            "value": f"{test.get('value', '')} {test.get('unit', '')} (Ref: {test.get('ref_range', '')})",
                            "flag": "abnormal" if test.get("is_abnormal") else "normal",
                            "source_quote": f"{test.get('name', '')}: {test.get('value', '')}"
                        })

                    # Chronic diagnosis hints
                    for diag in extracted.get("diagnosis_hints", []):
                        diag_text = diag.get("text", "") if isinstance(diag, dict) else str(diag)
                        parsed_sources.append({
                            "ref_id": f"{d.id}_diag",
                            "doc_type": d.doc_type,
                            "category": "Diagnosis (पूर्व निदान)",
                            "label": diag_text,
                            "value": "Chronic diagnosis in history",
                            "flag": "chronic_history",
                            "source_quote": diag_text
                        })

                    # Discharge summary diagnoses
                    for diag in extracted.get("diagnosis", []):
                        parsed_sources.append({
                            "ref_id": f"{d.id}_discharge_diag",
                            "doc_type": d.doc_type,
                            "category": "Hospitalization History (पिछला अस्पताल दाखिला)",
                            "label": str(diag),
                            "value": "Past hospital discharge diagnosis",
                            "flag": "past_discharge",
                            "source_quote": str(diag)
                        })

        except Exception as exc:
            logger.warning(f"Error reading DB context: {exc}")

    # Build readable history summary string
    history_lines = []
    for src in parsed_sources:
        history_lines.append(f"- [{src['category']}] {src['label']}: {src['value']} ({src.get('flag', '')})")
    history_summary = "\n".join(history_lines) if history_lines else "No previous medical records uploaded."

    return {
        "chief_complaint": chief_complaint,
        "recent_conversation": recent_messages,
        "profile": profile_summary,
        "answers_so_far": answers_so_far,
        "sources": parsed_sources,
        "patient_history_summary": history_summary
    }

async def next_interview_step(
    user_id: str,
    visit_id: str,
    user_answer_text: str = "",
    db: Optional[AsyncSession] = None,
    mode: str = "general",
    step_index: int = 1
) -> InterviewStep:
    """
    Executes an intelligent, verified interview step:
    1. Deterministic red-flag scan on patient input.
    2. Context assembly from DB records.
    3. Handles question bounds and consent extensions.
    4. Call #1: Gemini structured proposal.
    5. Call #2: Safety Verifier (Verdict).
    6. Sanitization of options (single letter keys, Hindi labels, visual icons).
    7. Safe fallback to deterministic ontology graph upon failure or rejection.
    """
    # 1. Deterministic emergency rule check (Offline Safe, instant)
    if user_answer_text:
        direct_rf = check_deterministic_red_flags(user_answer_text)
        if direct_rf:
            logger.warning(f"Deterministic RED FLAG fired: {direct_rf.code}")
            return InterviewStep(type="red_flag", red_flag=direct_rf)

    # 2. Check if user responded to Consent Extension
    ans_lower = user_answer_text.lower()
    if any(w in ans_lower for w in ["नहीं, यहीं समाप्त करें", "finish now", "समाप्त करें", "no, finish"]):
        return InterviewStep(type="complete")

    total_steps = DEFAULT_TOTAL_STEPS
    # If user agreed to extend
    if any(w in ans_lower for w in ["हाँ, 2 प्रश्न और", "yes, continue", "हाँ, 2 प्रश्न"]):
        total_steps = 8

    # If beyond total allowed questions, conclude immediately
    if step_index > total_steps:
        return InterviewStep(type="complete")

    # 3. Context assembly
    context = await assemble_context(user_id=user_id, visit_id=visit_id, db=db)
    active_complaint = context.get("chief_complaint") or (user_answer_text if step_index <= 1 else "")
    complaint_key = detect_complaint_key(active_complaint or user_answer_text)
    history_summary = context.get("patient_history_summary", "")

    # If step_index == total_steps (e.g. step 6) and this is standard intake conclusion:
    if step_index == total_steps and total_steps == DEFAULT_TOTAL_STEPS:
        # Check if conversation is rich enough
        if len(context.get("answers_so_far", [])) >= 4:
            return InterviewStep(type="complete")

    payload = {
        **context,
        "chief_complaint": active_complaint or complaint_key,
        "latest_patient_input": user_answer_text,
        "mode": mode,
        "step_index": step_index,
        "total_steps": total_steps
    }

    # 4. Call #1: Gemini Structured Proposal
    system_prompt = get_interviewer_prompt(
        mode=mode,
        chief_complaint=active_complaint,
        history_summary=history_summary,
        step_index=step_index,
        total_steps=total_steps
    )

    try:
        proposal = gemini_client.structured(
            system=system_prompt,
            payload=payload,
            schema=InterviewStep
        )
    except Exception as exc:
        logger.warning(f"Call #1 failed ({exc}). Falling back to ontology.")
        fallback = get_deterministic_fallback_question(
            step_index=step_index,
            complaint_key=complaint_key,
            user_answer_text=user_answer_text
        )
        if fallback.question:
            fallback.question.progress = ProgressInfo(done=step_index, total=total_steps)
            fallback.question.options = [
                sanitize_option_item(opt, i) for i, opt in enumerate(fallback.question.options)
            ]
        return fallback

    # If proposal itself identified a red flag
    if proposal.type == "red_flag" and proposal.red_flag:
        return proposal

    if proposal.type == "complete":
        return proposal

    # 5. Call #2: Two-Call Safety Verifier
    verified_data = gemini_client.verified(
        system=system_prompt,
        verifier_prompt=VERIFIER_PROMPT,
        payload=payload,
        proposal=proposal.model_dump(),
        schema=InterviewStep
    )

    if verified_data is None:
        logger.info(f"Using deterministic fallback question for step {step_index} ({complaint_key})")
        fallback = get_deterministic_fallback_question(
            step_index=step_index,
            complaint_key=complaint_key,
            user_answer_text=user_answer_text
        )
        if fallback.question:
            fallback.question.progress = ProgressInfo(done=step_index, total=total_steps)
            fallback.question.options = [
                sanitize_option_item(opt, i) for i, opt in enumerate(fallback.question.options)
            ]
        return fallback

    res_step = InterviewStep.model_validate(verified_data)

    # 6. Post-process: Guarantee deterministic progress bounds & sanitized visual options
    if res_step.type == "question" and res_step.question:
        res_step.question.progress = ProgressInfo(done=step_index, total=total_steps)
        res_step.question.options = [
            sanitize_option_item(opt, i) for i, opt in enumerate(res_step.question.options)
        ]

    return res_step
