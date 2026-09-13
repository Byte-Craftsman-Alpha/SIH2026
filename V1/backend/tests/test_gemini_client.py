import pytest
import os
from unittest.mock import MagicMock
from app.gemini.client import GeminiClient
from app.gemini.schemas import InterviewStep, Verdict

def test_mock_mode():
    client = GeminiClient()
    client.mock = True
    res = client.structured("system", {"input": "test"}, InterviewStep)
    assert isinstance(res, InterviewStep)
    assert res.type in ["question", "complete", "red_flag"]
    assert res.question is not None
    assert "भोजन" in res.question.text or "Discomfort" in res.question.text_en or res.question.id

def test_structured_returns_valid_schema(monkeypatch):
    client = GeminiClient()
    client.mock = False
    
    mock_response = MagicMock()
    mock_response.text = '{"valid": true, "reason": "Consistent with inputs"}'
    
    mock_models = MagicMock()
    mock_models.generate_content.return_value = mock_response
    
    client.client = MagicMock()
    client.client.models = mock_models
    
    result = client.structured("Check safety", {"foo": "bar"}, Verdict)
    assert isinstance(result, Verdict)
    assert result.valid is True
    assert result.reason == "Consistent with inputs"

def test_verified_rejects_bad_proposal(monkeypatch):
    client = GeminiClient()
    client.mock = False
    
    # Simulate verifier returning invalid
    mock_response = MagicMock()
    mock_response.text = '{"valid": false, "reason": "Asserts ungrounded diabetes diagnosis"}'
    
    mock_models = MagicMock()
    mock_models.generate_content.return_value = mock_response
    
    client.client = MagicMock()
    client.client.models = mock_models
    
    proposal = {"type": "question", "question": {"id": "BAD_Q", "text": "Are you taking insulin?"}}
    verdict = client.verified("system", "verifier_prompt", {"sources": []}, proposal, InterviewStep)
    assert verdict is None

def test_no_key_leak():
    fake_key = "AIzaSySecretFakeKey1234567890"
    client = GeminiClient(api_key=fake_key)
    client.mock = False
    
    mock_models = MagicMock()
    mock_models.generate_content.side_effect = ConnectionError("Upstream timeout")
    
    client.client = MagicMock()
    client.client.models = mock_models
    
    try:
        # Force structured call to fail without mock
        client.structured("sys", {}, Verdict, max_retries=1)
    except Exception as exc:
        msg = str(exc)
        assert fake_key not in msg

