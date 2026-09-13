import uuid
import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.visit import Visit
from app.models.chat_message import ChatMessage
from app.models.summary import Summary
from app.models.alert import Alert
from app.models.user import User
from app.models.profile import PatientProfile
from app.core.question_bank import GENERAL_QUESTIONS, AYUSH_QUESTIONS, RED_FLAG_RULES

def get_questions_for_mode(mode: str) -> list[dict]:
    if mode == "ayush":
        # General HPI questions followed by AYUSH specific sections
        return GENERAL_QUESTIONS[:10] + AYUSH_QUESTIONS
    return GENERAL_QUESTIONS

async def create_chat_session(db: AsyncSession, user_id: str, mode: str = "general", complaint: str = None) -> Visit:
    visit_id = f"vis_{uuid.uuid4().hex[:8]}"
    visit = Visit(
        id=visit_id,
        user_id=user_id,
        mode=mode,
        status="draft",
        started_at=datetime.datetime.utcnow(),
        submitted_at=None,
        chief_complaint=complaint or "Unspecified complaint",
        red_flag_code=None
    )
    db.add(visit)
    await db.commit()
    return visit

async def get_next_question(db: AsyncSession, visit: Visit, lang: str = "hi") -> dict:
    questions = get_questions_for_mode(visit.mode)
    
    # Get answered questions
    stmt = select(ChatMessage.question_id).where(
        ChatMessage.visit_id == visit.id,
        ChatMessage.sender == "patient"
    )
    answered_ids = set((await db.execute(stmt)).scalars().all())

    # Find first unanswered
    unanswered = None
    done_count = 0
    for q in questions:
        if q["id"] in answered_ids:
            done_count += 1
        elif unanswered is None:
            unanswered = q

    if unanswered is None:
        return None  # All questions answered

    text = unanswered.get("text_hi") if lang == "hi" else unanswered.get("text_en", unanswered.get("text"))
    if not text:
        text = unanswered.get("text_en", "")

    # Format options for the target language
    formatted_options = []
    for opt in unanswered.get("options", []):
        if isinstance(opt, dict):
            label = opt.get(f"label_{lang}", opt.get("label_en", opt.get("label", "")))
            formatted_options.append({
                "key": opt.get("key", ""),
                "label": label,
                "label_en": opt.get("label_en", ""),
                "label_hi": opt.get("label_hi", ""),
                "icon": opt.get("icon", ""),
                "dosha": opt.get("dosha", "")
            })
        else:
            formatted_options.append({"key": str(opt), "label": str(opt)})

    return {
        "id": unanswered["id"],
        "text": text,
        "text_en": unanswered.get("text_en", ""),
        "text_hi": unanswered.get("text_hi", ""),
        "input": unanswered.get("input_type", "mcq"),
        "options": formatted_options,
        "tts_audio_url": f"/api/v1/tts/{unanswered.get('tts_key', unanswered['id'])}.{lang}.mp3",
        "section": unanswered.get("section", "HPI"),
        "progress": {
            "done": done_count + 1,
            "total": len(questions)
        }
    }

def evaluate_red_flag(question_id: str, answer: dict) -> dict:
    # Check if answer contains red flag triggers
    answer_str = str(answer).lower()
    
    # Check chest pain
    if "chest_pain" in answer_str or "सीने में दर्द" in answer_str:
        return RED_FLAG_RULES[0]
    # Check severe stroke symptoms
    if "speech_slur" in answer_str or "लकवा" in answer_str:
        return RED_FLAG_RULES[1]
    # Check blood in vomit/stool
    if "blood" in answer_str or "खून" in answer_str:
        return RED_FLAG_RULES[2]
    # Check unconsciousness
    if "unconscious" in answer_str or "behosh" in answer_str or "बेहोश" in answer_str:
        return RED_FLAG_RULES[3]

    return None

async def record_answer(db: AsyncSession, visit: Visit, question_id: str, input_type: str, answer: dict, lang: str = "hi"):
    # Store patient response
    msg = ChatMessage(
        id=f"msg_{uuid.uuid4().hex[:8]}",
        visit_id=visit.id,
        sender="patient",
        input_type=input_type,
        question_id=question_id,
        question_text=f"Question {question_id}",
        answer_json=answer,
        language=lang
    )
    db.add(msg)
    
    # If chief complaint question or unset, update visit.chief_complaint
    if question_id in ("GEN_CC_01", "CC_01", "CHIEF_COMPLAINT") or not visit.chief_complaint or visit.chief_complaint == "Unspecified complaint":
        if isinstance(answer, dict):
            val = answer.get("label_hi") or answer.get("label") or answer.get("text") or answer.get("option") or answer.get("key") or str(answer)
        else:
            val = str(answer)
        if val:
            visit.chief_complaint = str(val)

    await db.commit()

async def submit_chat_session(db: AsyncSession, visit: Visit, user: User) -> str:
    from app.services.summary_service import generate_clinical_summary
    return await generate_clinical_summary(db, visit, user)

