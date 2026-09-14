import pytest
from unittest.mock import patch
from app.api.v1.fhir import build_fhir_bundle
from app.api.v1.appointments import notify_his_status_change
from app.config import settings

@pytest.fixture
def mock_his_env(monkeypatch):
    monkeypatch.setattr("app.config.settings.HIS_PUSH_URL", "http://test-his/fhir")

@patch("app.api.v1.fhir.requests.post")
@pytest.mark.asyncio
async def test_fhir_push_success(mock_post, mock_his_env, monkeypatch):
    # Mock db and dependencies
    mock_db = type("MockDB", (), {"execute": lambda *args: type("Scalar", (), {"scalar_one_or_none": lambda: None, "scalars": lambda: type("First", (), {"first": lambda: None})()})(), "add": lambda *args: None, "commit": lambda *args: None})()
    
    res = await build_fhir_bundle({"summary_id": "test"}, db=mock_db)
    
    assert res["status"] == "success"
    assert res["abdm_gateway"] == "delivered_to_his"
    mock_post.assert_called_once()

@patch("app.api.v1.fhir.requests.post")
@pytest.mark.asyncio
async def test_fhir_push_timeout_fallback(mock_post, mock_his_env, monkeypatch):
    import requests
    mock_post.side_effect = requests.exceptions.Timeout("Timeout")
    
    mock_db = type("MockDB", (), {"execute": lambda *args: type("Scalar", (), {"scalar_one_or_none": lambda: None, "scalars": lambda: type("First", (), {"first": lambda: None})()})(), "add": lambda *args: None, "commit": lambda *args: None})()
    
    res = await build_fhir_bundle({"summary_id": "test"}, db=mock_db)
    
    assert res["status"] == "success"
    assert res["abdm_gateway"] == "his_timeout_fallback"

@patch("app.api.v1.appointments.requests.post")
def test_notify_his_status_change_success(mock_post, mock_his_env):
    notify_his_status_change("appt_1", "cancelled", None)
    mock_post.assert_called_once()

