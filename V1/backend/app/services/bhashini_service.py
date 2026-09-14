import base64
import os
import logging
import requests
from typing import Optional
from app.config import settings

logger = logging.getLogger("medikiosk.bhashini")

AUTH_URL = "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/compute"
INFER_URL = "https://dhruva-api.bhashini.gov.in/services/inference/pipeline"

class BhashiniService:
    """Hindi ASR via Bhashini ULCA. Returns None on ANY failure (caller falls back).
    Never raises to the caller. Never logs audio content."""

    def _enabled(self) -> bool:
        return bool(settings.BHASHINI_USER_ID and
                    settings.BHASHINI_ULCA_API_KEY and
                    settings.BHASHINI_ASR_PIPELINE_ID)

    def transcribe(self, audio_bytes: bytes, source_lang: str = "hi",
                   audio_format: str = "wav", sample_rate: int = 16000) -> Optional[str]:
        if not self._enabled():
            logger.info("Bhashini disabled (missing creds).")
            return None
        try:
            r = requests.post(AUTH_URL, timeout=10, headers={
                "userID": settings.BHASHINI_USER_ID,
                "ulcaApiKey": settings.BHASHINI_ULCA_API_KEY,
                "Content-Type": "application/json"},
                json={"pipelineTasks": [
                          {"taskType": "asr",
                           "config": {"language": {"sourceLanguage": source_lang}}}],
                      "pipelineRequestConfig": {"pipelineId": settings.BHASHINI_ASR_PIPELINE_ID}})
            r.raise_for_status()
            data = r.json()
            service_id = data["pipelineResponseConfig"][0]["config"][0]["serviceId"]
            infer_key = data["pipelineInferenceAPIEndPoint"]["callbackUrl"]

            r2 = requests.post(INFER_URL, timeout=30, headers={
                "Authorization": infer_key, "Content-Type": "application/json"},
                json={"pipelineTasks": [{
                        "taskType": "asr", "serviceId": service_id,
                        "config": {"language": {"sourceLanguage": source_lang},
                                   "audioFormat": audio_format,
                                   "samplingRate": sample_rate}}],
                      "inputData": {"audio": [
                          {"audioContent": base64.b64encode(audio_bytes).decode()}]}})
            r2.raise_for_status()
            transcript = r2.json()["pipelineResponse"][0]["output"][0]["source"]
            logger.info(f"Bhashini transcript OK ({len(transcript)} chars).")
            return transcript
        except Exception as exc:
            logger.warning(f"Bhashini failed ({type(exc).__name__}); caller will fall back.")
            return None

bhashini_service = BhashiniService()

