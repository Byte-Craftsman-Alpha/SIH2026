import pytest
from unittest.mock import patch, MagicMock
from app.services.abdm_service import abdm_service
from app.seed.seed_data import MOCK_PATIENT_ABHA_PROFILE

@pytest.fixture
def mock_abdm_env(monkeypatch):
    monkeypatch.setenv("ABDM_CLIENT_ID", "test_id")
    monkeypatch.setenv("ABDM_CLIENT_SECRET", "test_secret")
    monkeypatch.setenv("ABHA_MOCK_MODE", "false")
    monkeypatch.setattr("app.config.settings.ABHA_MOCK_MODE", False)
    monkeypatch.setattr("app.config.settings.ABDM_CLIENT_ID", "test_id")
    monkeypatch.setattr("app.config.settings.ABDM_CLIENT_SECRET", "test_secret")

def test_disabled_returns_none(monkeypatch):
    monkeypatch.setattr("app.config.settings.ABDM_CLIENT_ID", "")
    res = abdm_service.session_token()
    assert res is None

@patch("app.services.abdm_service.requests.post")
def test_session_token_mocked(mock_post, mock_abdm_env):
    mock_resp = MagicMock()
    mock_resp.json.return_value = {"accessToken": "fake_token"}
    mock_post.return_value = mock_resp
    
    token = abdm_service.session_token()
    assert token == "fake_token"
    
    headers = mock_post.call_args[1]["headers"]
    assert "REQUEST-ID" in headers
    assert "TIMESTAMP" in headers
    assert "X-CM-ID" in headers

def test_mock_mode_returns_seeded_profile(monkeypatch):
    monkeypatch.setattr("app.config.settings.ABHA_MOCK_MODE", True)
    res = abdm_service.verify_login_otp("txn123", "123456")
    assert res == MOCK_PATIENT_ABHA_PROFILE

