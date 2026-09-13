import json
import time
import os
import logging
from typing import Optional, List, Dict, Any, Type, TypeVar
from pydantic import BaseModel
from google import genai
from google.genai import types

from .schemas import Verdict
from app.config import settings

logger = logging.getLogger("medikiosk.gemini")

T = TypeVar("T", bound=BaseModel)

class GeminiClient:
    def __init__(self, api_key: Optional[str] = None):
        key = api_key or settings.GOOGLE_API_KEY or os.environ.get("GOOGLE_API_KEY", "")
        self._api_key = key
        self.model = settings.GEMINI_MODEL
        self.mock = settings.MOCK_GEMINI or (os.environ.get("MOCK_GEMINI", "").lower() == "true")
        
        self.client: Optional[genai.Client] = None
        if key and not self.mock:
            try:
                self.client = genai.Client(api_key=key)
            except Exception as exc:
                logger.warning(f"Could not initialize genai.Client: {type(exc).__name__}. Running in fallback mode.")
                self.client = None

    def structured(
        self,
        system: str,
        payload: Dict[str, Any],
        schema: Type[T],
        images: Optional[List[bytes]] = None,
        max_retries: int = 2
    ) -> T:
        """
        Executes one structured generation call returning an instance of schema.
        Temperature is 0, output is JSON, and untrusted inputs remain in payload.
        Never leaks API keys or internal stack traces.
        """
        schema_name = getattr(schema, "__name__", str(schema))
        start_time = time.time()

        # Offline / Mock mode fallback
        if self.mock or self.client is None:
            mock_data = settings.MOCK_RESPONSES.get(schema_name)
            if mock_data:
                logger.info(f"Gemini mock structured returning {schema_name}")
                return schema.model_validate(mock_data)
            logger.warning(f"No mock response found for {schema_name}; attempting default instance.")
            return schema.model_construct()

        contents: List[Any] = []
        if images:
            for img_bytes in images:
                # Detect MIME type loosely
                mime = "image/jpeg"
                if img_bytes.startswith(b"\x89PNG"):
                    mime = "image/png"
                contents.append(types.Part.from_bytes(data=img_bytes, mime_type=mime))

        # Payload is untrusted DATA passed as JSON
        contents.append(json.dumps(payload, ensure_ascii=False))

        last_exc = None
        for attempt in range(max_retries + 1):
            try:
                resp = self.client.models.generate_content(
                    model=self.model,
                    contents=contents,
                    config=types.GenerateContentConfig(
                        system_instruction=system,
                        temperature=0.0,
                        response_mime_type="application/json",
                        response_schema=schema,
                    ),
                )
                duration = time.time() - start_time
                logger.info(f"Gemini structured call {schema_name} succeeded in {duration:.2f}s")
                return schema.model_validate_json(resp.text)
            except Exception as exc:
                last_exc = exc
                err_type = type(exc).__name__
                logger.warning(f"Gemini attempt {attempt + 1}/{max_retries + 1} failed: {err_type}: {exc}")
                if attempt < max_retries:
                    time.sleep(2 ** attempt)

        sanitized_err = f"Gemini failed after {max_retries} retries: {type(last_exc).__name__}"
        logger.error(sanitized_err)
        # Check if mock fallback can rescue the failure gracefully
        fallback_data = settings.MOCK_RESPONSES.get(schema_name)
        if fallback_data:
            logger.info(f"Using mock fallback for {schema_name} after retry exhaustion.")
            return schema.model_validate(fallback_data)

        raise RuntimeError(sanitized_err)

    def verified(
        self,
        system: str,
        verifier_prompt: str,
        payload: Dict[str, Any],
        proposal: Dict[str, Any],
        schema: Type[T]
    ) -> Optional[Dict[str, Any]]:
        """
        Notebook's two-call verification pattern:
        Call 1 proposal is audited by Call 2 verifier.
        Returns None if verifier flags any hallucination or protocol violation.
        """
        if not settings.VERIFY_ENABLED and os.environ.get("VERIFY_ENABLED", "").lower() != "true":
            return proposal

        verdict_payload = {
            "conversation_and_sources": payload,
            "proposed_step": proposal
        }

        try:
            verdict = self.structured(verifier_prompt, verdict_payload, Verdict)
            if not verdict.valid:
                logger.warning(f"Verifier REJECTED proposal: {verdict.reason}")
                return None
            logger.info("Verifier APPROVED proposal.")
            return proposal
        except Exception as exc:
            logger.warning(f"Verifier call failed ({type(exc).__name__}). Falling back to safe ontology.")
            return None

# Singleton instance
gemini_client = GeminiClient()

