import os
import uuid
import logging
import datetime
import requests
from typing import Optional
from app.config import settings
from app.seed.seed_data import MOCK_PATIENT_ABHA_PROFILE

logger = logging.getLogger("medikiosk.abdm")

class AbdmService:
    def _h(self, token=None):
        h = {
            "REQUEST-ID": str(uuid.uuid4()),
            "TIMESTAMP": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z"),
            "X-CM-ID": settings.ABDM_CM_ID
        }
        if token:
            h["X-token"] = f"Bearer {token}"
        return h

    def _enabled(self):
        return bool(settings.ABDM_CLIENT_ID and settings.ABDM_CLIENT_SECRET)

    def session_token(self) -> Optional[str]:
        if not self._enabled():
            return None
        try:
            r = requests.post(
                f"{settings.ABDM_BASE_URL}/gateway/v3/sessions", 
                headers=self._h(),
                json={
                    "clientId": settings.ABDM_CLIENT_ID,
                    "clientSecret": settings.ABDM_CLIENT_SECRET
                }, 
                timeout=10
            )
            r.raise_for_status()
            return r.json().get("accessToken")
        except Exception as exc:
            logger.warning(f"ABDM session failed ({type(exc).__name__}).")
            return None

    def send_login_otp(self, mobile: str) -> Optional[dict]:
        """ABHA mobile-OTP login (scope abha-login, otpSystem abdm). No RSA needed."""
        if settings.ABHA_MOCK_MODE:
            logger.info("ABHA Mock Mode: Returning mock txnId")
            return {"txnId": "mock_txn"}
            
        token = self.session_token()
        if not token:
            return None
        try:
            r = requests.post(
                f"{settings.ABHA_BASE_URL}/v3/profile/login/request/otp",
                headers=self._h(token), 
                timeout=10,
                json={
                    "scope": ["abha-login"], 
                    "loginHint": "mobile",
                    "loginId": mobile, 
                    "otpSystem": "abdm"
                }
            )
            r.raise_for_status()
            return {"txnId": r.json().get("txnId")}
        except Exception as exc:
            logger.warning(f"ABHA OTP send failed ({type(exc).__name__}).")
            return None

    def verify_login_otp(self, txn_id: str, otp: str) -> Optional[dict]:
        if settings.ABHA_MOCK_MODE:
            logger.info("ABHA Mock Mode: Returning seeded ABHA profile")
            return MOCK_PATIENT_ABHA_PROFILE
            
        token = self.session_token()
        if not token:
            return None
        try:
            r = requests.post(
                f"{settings.ABHA_BASE_URL}/v3/profile/login/verify",
                headers=self._h(token), 
                timeout=10,
                json={
                    "txnId": txn_id, 
                    "otp": otp, 
                    "scope": ["abha-login"],
                    "loginHint": "mobile", 
                    "otpSystem": "abdm"
                }
            )
            r.raise_for_status()
            user_token = r.json().get("token")
            pr = requests.get(
                f"{settings.ABHA_BASE_URL}/v3/profile/account/profile",
                headers=self._h(user_token), 
                timeout=10
            )
            pr.raise_for_status()
            return pr.json()
        except Exception as exc:
            logger.warning(f"ABHA OTP verify failed ({type(exc).__name__}).")
            return None

abdm_service = AbdmService()

