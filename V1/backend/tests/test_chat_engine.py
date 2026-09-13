import pytest
import asyncio
from app.gemini.schemas import InterviewStep, Question, RedFlag
from app.chat.ontology import check_deterministic_red_flags, get_deterministic_fallback_question
from app.chat.engine import next_interview_step

def test_deterministic_red_flag_detection():
    # Chest pain + dyspnea / sweating
    rf1 = check_deterministic_red_flags("Mujhe seene mein dard aur saans lene mein takleef hai")
    assert rf1 is not None
    assert rf1.code == "CHEST_PAIN_DYSPNEA"
    assert rf1.severity == "high"

    # Stroke FAST
    rf2 = check_deterministic_red_flags("Achanak se bolne mein awaz ladkhadana shuru ho gayi")
    assert rf2 is not None
    assert rf2.code == "STROKE_FAST"

    # Vomiting blood
    rf3 = check_deterministic_red_flags("Patient ko khoon ki ulti hui hai")
    assert rf3 is not None
    assert rf3.code == "HEMATEMESIS"

    # Normal complaint
    normal = check_deterministic_red_flags("Kal se sar mein thoda dard hai")
    assert normal is None

def test_deterministic_fallback_graph():
    # Step 0 -> Chief Complaint
    step0 = get_deterministic_fallback_question(0)
    assert step0.type == "question"
    assert step0.question.id == "CC_01"
    assert step0.question.input_type == "mcq"
    assert len(step0.question.options) >= 4

    # Step 1 -> HPI Onset
    step1 = get_deterministic_fallback_question(1)
    assert step1.type == "question"
    assert step1.question.id == "HPI_ONSET"

    # Step 2 -> HPI Severity (slider)
    step2 = get_deterministic_fallback_question(2)
    assert step2.question.input_type == "slider"

@pytest.mark.asyncio
async def test_red_flag_priority_over_chat():
    step = await next_interview_step(
        user_id="test_user",
        visit_id="test_visit",
        user_answer_text="Bohot tez chhati mein dard ho raha hai aur pasina aa raha hai"
    )
    assert step.type == "red_flag"
    assert step.red_flag.code == "CHEST_PAIN_DYSPNEA"

