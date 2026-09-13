import os

SYSTEM_INSTRUCTION_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "system_instruction.txt"
)

def get_interviewer_prompt(
    mode: str = "general",
    chief_complaint: str = "",
    history_summary: str = "",
    step_index: int = 1,
    total_steps: int = 6
) -> str:
    """Reads system_instruction.txt with dynamic clinical grounding, records history, and step constraints."""
    prompt = ""
    if os.path.exists(SYSTEM_INSTRUCTION_PATH):
        with open(SYSTEM_INSTRUCTION_PATH, "r", encoding="utf-8") as f:
            prompt = f.read()
    else:
        prompt = "You are MediKiosk's clinical history intake interviewer. Output JSON adhering to InterviewStep."

    prompt += f"\n\n[CURRENT INTERVIEW STEP: {step_index} / {total_steps}]\n"
    if step_index >= total_steps:
        prompt += (
            "This is the FINAL planned question (or conclusion step). "
            "If you have gathered enough clinical context (onset, pattern, associated sxs, severity), "
            "conclude by outputting {\"type\": \"complete\"}.\n"
        )

    if chief_complaint:
        prompt += (
            f"\n\n[CRITICAL CLINICAL GROUNDING: CHIEF COMPLAINT = '{chief_complaint}']\n"
            "You MUST ask questions that are strictly relevant and tailored to this chief complaint.\n"
            "- If the patient reports Fever (बुखार/ज्वर): Inquire about fever onset, temperature patterns, chills, sweating (Sweda), and appetite (Agni). NEVER ask abdominal pain site or unrelated physical locations.\n"
            "- If the patient reports Cough/Cold (खांसी/जुकाम): Ask about dry vs productive phlegm, wheezing, and duration.\n"
            "- If the patient reports Headache (सिरदर्द): Ask about headache location (frontal/migraine), triggers, and sleep.\n"
            "- If the patient reports Abdominal/Digestive issues: Ask about epigastric vs lower abdomen, meal relations, acidity, and bowel habit."
        )

    if history_summary and history_summary.strip():
        prompt += (
            f"\n\n[PATIENT'S UPLOADED MEDICAL RECORDS & HISTORY]:\n{history_summary}\n"
            "INSTRUCTION: Clinically connect the current inquiry with the patient's existing history where relevant. "
            "For example, if they have Diabetes/Hypertension on file and have fever/weakness, inquire whether they took their regular medicines or if their readings are elevated."
        )

    if mode == "ayush":
        prompt += (
            "\n\n[MODE: AYUSH INTAKE ACTIVE]\n"
            "Emphasize Ayurvedic Ashtavidha & Dashavidha assessment: examine Agni (Mandagni/Tikshnagni/Vishamagni/Samagni), "
            "Koshtha (Krura/Mrudu/Madhyama), Ahara-Vihara (diet & seasonal regimen), and sleep quality (Nidra)."
        )

    return prompt
