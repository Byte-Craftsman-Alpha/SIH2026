import pytest
from unittest.mock import patch, MagicMock
from app.services.bhashini_service import bhashini_service
import os

@pytest.fixture
def mock_bhashini_env(monkeypatch):
    monkeypatch.setenv("BHASHINI_USER_ID", "test_user")
    monkeypatch.setenv("BHASHINI_ULCA_API_KEY", "test_key")
    monkeypatch.setenv("BHASHINI_ASR_PIPELINE_ID", "test_pipeline")
    # Reload settings in bhashini_service
    monkeypatch.setattr(bhashini_service, "_enabled", lambda: True)

def test_disabled_without_creds(monkeypatch):
    monkeypatch.setattr(bhashini_service, "_enabled", lambda: False)
    res = bhashini_service.transcribe(b"dummy")
    assert res is None

@patch("app.services.bhashini_service.requests.post")
def test_success_returns_transcript(mock_post, mock_bhashini_env):
    mock_resp1 = MagicMock()
    mock_resp1.json.return_value = {
        "pipelineResponseConfig": [{"config": [{"serviceId": "srv1"}]}],
        "pipelineInferenceAPIEndPoint": {"callbackUrl": "https://callback"}
    }
    
    mock_resp2 = MagicMock()
    mock_resp2.json.return_value = {
        "pipelineResponse": [{"output": [{"source": "hello"}]}]
    }
    
    mock_post.side_effect = [mock_resp1, mock_resp2]
    
    res = bhashini_service.transcribe(b"dummy")
    assert res == "hello"

@patch("app.services.bhashini_service.requests.post")
def test_compute_failure_returns_none(mock_post, mock_bhashini_env):
    mock_post.side_effect = Exception("Network error")
    res = bhashini_service.transcribe(b"dummy")
    assert res is None

