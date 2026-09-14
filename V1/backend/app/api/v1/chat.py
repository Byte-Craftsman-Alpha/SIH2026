from typing import Optional
import uuid
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.visit import Visit
from app.models.chat_message import ChatMessage
from app.models.user import User
from app.models.alert import Alert
from app.database import get_db
from app.dependencies import get_current_user
from app.schemas.chat import (
    ChatSessionCreate, ChatSessionResponse, AnswerRequest,
    AnswerResponse, VoiceUploadResponse, RedFlagResponse
)
from app.services.chat_service import (
    create_chat_session, record_answer, submit_chat_session
)
from app.chat.engine import next_interview_step
from app.gemini.schemas import Question

router = APIRouter()

def format_interview_question(q: Question, lang: str = "hi") -> dict:
    text = q.text if lang == "hi" else (q.text_en or q.text)
    return {
        "id": q.id,
        "text": text,
        "text_en": q.text_en or q.text,
        "text_hi": q.text,
        "input": q.input_type,
        "input_type": q.input_type,
        "options": q.options,
        "tts_audio_url": f"/api/v1/tts/{q.id}.{lang}.mp3",
        "section": q.section,
        "progress": q.progress or {"done": 1, "total": 10}
    }

def extract_answer_text(answer: Any) -> str:
    if isinstance(answer, dict):
        return str(
            answer.get("label_hi") or 
            answer.get("label_en") or 
            answer.get("label") or 
            answer.get("text") or 
            answer.get("option") or 
            answer.get("key") or 
            answer
        )
    return str(answer)

@router.post("/sessions", response_model=ChatSessionResponse)
async def create_session(req: ChatSessionCreate, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = await create_chat_session(db, user_id=user.id, mode=req.mode or "general", complaint=req.complaint)
    
    # Generate initial question via next_interview_step
    step_idx = 1 if req.complaint else 0
    step = await next_interview_step(
        user_id=user.id,
        visit_id=visit.id,
        user_answer_text=req.complaint or "",
        db=db,
        mode=visit.mode,
        step_index=step_idx
    )
    
    first_q = None
    if step.type == "question" and step.question:
        first_q = format_interview_question(step.question, lang=req.language or "hi")
        sys_msg = ChatMessage(
            id=f"msg_{uuid.uuid4().hex[:8]}",
            visit_id=visit.id,
            sender="system",
            input_type=step.question.input_type,
            question_id=step.question.id,
            question_text=first_q["text"],
            answer_json=None,
            language=req.language or "hi"
        )
        db.add(sys_msg)
        await db.commit()

    return ChatSessionResponse(
        session_id=visit.id,
        mode=visit.mode,
        status=visit.status,
        first_question=first_q
    )

@router.get("/sessions/{id}")
async def get_session(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == id, Visit.user_id == user.id))).scalar_one_or_none()
    if not visit:
        raise HTTPException(status_code=404, detail="Chat session not found")

    messages_res = await db.execute(select(ChatMessage).where(ChatMessage.visit_id == id).order_by(ChatMessage.created_at))
    messages = messages_res.scalars().all()

    p_count = sum(1 for m in messages if m.sender == "patient")
    next_q = None
    if visit.status == "draft":
        step = await next_interview_step(
            user_id=user.id,
            visit_id=visit.id,
            db=db,
            mode=visit.mode,
            step_index=p_count
        )
        if step.question:
            next_q = format_interview_question(step.question, lang=user.language or "hi")

    return {
        "session_id": visit.id,
        "mode": visit.mode,
        "status": visit.status,
        "chief_complaint": visit.chief_complaint,
        "red_flag_code": visit.red_flag_code,
        "transcript": [
            {
                "id": m.id,
                "sender": m.sender,
                "question_id": m.question_id,
                "question_text": m.question_text,
                "answer": m.answer_json,
                "input_type": m.input_type
            } for m in messages
        ],
        "next_question": next_q
    }

@router.post("/sessions/{id}/answer", response_model=AnswerResponse)
async def post_answer(id: str, req: AnswerRequest, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == id, Visit.user_id == user.id))).scalar_one_or_none()
    if not visit:
        raise HTTPException(status_code=404, detail="Chat session not found")

    # Record the patient's answer
    await record_answer(db, visit, req.question_id, req.input_type, req.answer, req.session_lang or "hi")

    ans_text = extract_answer_text(req.answer)

    # Count how many patient answers have been recorded
    count_stmt = select(ChatMessage).where(ChatMessage.visit_id == id, ChatMessage.sender == "patient")
    p_msgs = (await db.execute(count_stmt)).scalars().all()
    step_index = len(p_msgs)

    # Invoke Grounded Interview Engine
    step = await next_interview_step(
        user_id=user.id,
        visit_id=visit.id,
        user_answer_text=ans_text,
        db=db,
        mode=visit.mode,
        step_index=step_index
    )

    if step.type == "red_flag" and step.red_flag:
        visit.status = "red_flag_pending"
        visit.red_flag_code = step.red_flag.code
        
        # Dispatch triage alert
        alert = Alert(
            id=f"alt_{uuid.uuid4().hex[:8]}",
            user_id=user.id,
            flag_code=step.red_flag.code,
            channel="triage",
            payload_hash=f"hash_{visit.id}",
            status="pending",
            acked_by=None
        )
        db.add(alert)
        await db.commit()

        return AnswerResponse(
            type="red_flag",
            question=None,
            red_flag=step.red_flag.model_dump(),
            session_status="red_flag_pending"
        )

    # If completed or turns threshold reached, wrap up
    if step.type == "complete" or step_index >= 10 or not step.question:
        summary_id = await submit_chat_session(db, visit, user)
        return AnswerResponse(
            type="complete",
            question=None,
            red_flag=None,
            session_status="submitted",
            summary_id=summary_id
        )

    formatted_q = format_interview_question(step.question, lang=req.session_lang or "hi")
    
    # Record system message in chat history
    sys_msg = ChatMessage(
        id=f"msg_{uuid.uuid4().hex[:8]}",
        visit_id=visit.id,
        sender="system",
        input_type=step.question.input_type,
        question_id=step.question.id,
        question_text=formatted_q["text"],
        answer_json=None,
        language=req.session_lang or "hi"
    )
    db.add(sys_msg)
    await db.commit()

    return AnswerResponse(
        type="question",
        question=formatted_q,
        red_flag=None,
        session_status="in_progress"
    )

from fastapi import UploadFile, File, Form
from app.services.bhashini_service import bhashini_service

@router.post("/sessions/{id}/voice", response_model=VoiceUploadResponse)
async def post_voice(
    id: str, 
    transcript: Optional[str] = Form(None), 
    file: Optional[UploadFile] = File(None),
    user: User = Depends(get_current_user)
):
    engine = "fallback"
    final_transcript = None
    
    if transcript:
        final_transcript = transcript
        engine = "device"
    elif file:
        audio_bytes = await file.read()
        res = bhashini_service.transcribe(audio_bytes)
        if res:
            final_transcript = res
            engine = "bhashini"
            
    return VoiceUploadResponse(
        transcript=final_transcript,
        engine=engine,
        mapped_option=None,
        confidence=0.91
    )

@router.post("/asr/test")
async def asr_test(
    lang: str = Form("hi"), 
    file: UploadFile = File(...)
):
    audio_bytes = await file.read()
    res = bhashini_service.transcribe(audio_bytes, source_lang=lang)
    if res:
        return {"transcript": res, "engine": "bhashini"}
    return {"transcript": None, "engine": "fallback"}

@router.post("/sessions/{id}/skip")
async def skip_q(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == id, Visit.user_id == user.id))).scalar_one_or_none()
    if not visit:
        raise HTTPException(status_code=404, detail="Chat session not found")

    count_stmt = select(ChatMessage).where(ChatMessage.visit_id == id, ChatMessage.sender == "patient")
    p_msgs = (await db.execute(count_stmt)).scalars().all()
    step_index = len(p_msgs)

    await record_answer(db, visit, f"SKIP_{step_index}", "skip", {"action": "skipped"})
    
    step = await next_interview_step(user_id=user.id, visit_id=visit.id, db=db, mode=visit.mode, step_index=step_index + 1)
    following_q = format_interview_question(step.question, lang=user.language or "hi") if step.question else None
    
    return {"status": "skipped", "next_question": following_q}

@router.post("/sessions/{id}/submit")
async def submit(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == id, Visit.user_id == user.id))).scalar_one_or_none()
    if not visit:
        raise HTTPException(status_code=404, detail="Chat session not found")

    summary_id = await submit_chat_session(db, visit, user)
    return {
        "status": "submitted",
        "visit_id": visit.id,
        "summary_id": summary_id,
        "message": "Intake completed. Clinical history delivered to physician console."
    }

@router.get("/sessions/{id}/redflag", response_model=RedFlagResponse)
async def get_redflag(id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    visit = (await db.execute(select(Visit).where(Visit.id == id, Visit.user_id == user.id))).scalar_one_or_none()
    if not visit or not visit.red_flag_code:
        return RedFlagResponse(is_flagged=False)

    return RedFlagResponse(
        is_flagged=True,
        code=visit.red_flag_code,
        severity="high",
        instruction="emergency_screen",
        message="Critical symptoms detected requiring immediate attention."
    )
