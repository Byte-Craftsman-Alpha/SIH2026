from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.abdm_service import abdm_service
from app.config import settings

router = APIRouter(prefix="/abdm", tags=["ABDM"])

class OtpSendRequest(BaseModel):
    mobile: str

class OtpVerifyRequest(BaseModel):
    txnId: str
    otp: str

@router.post("/abha/otp/send")
async def send_otp(req: OtpSendRequest):
    res = abdm_service.send_login_otp(req.mobile)
    if not res:
        raise HTTPException(status_code=400, detail="Failed to send ABHA OTP")
    return res

@router.post("/abha/otp/verify")
async def verify_otp(req: OtpVerifyRequest):
    res = abdm_service.verify_login_otp(req.txnId, req.otp)
    if not res:
        raise HTTPException(status_code=400, detail={"code": "ABHA_OTP_INVALID", "message": "Invalid OTP"})
    
    # Return masked profile + mock info
    res["mock_mode"] = settings.ABHA_MOCK_MODE
    return res

@router.get("/status")
async def get_status():
    return {
        "sandbox_reachable": not settings.ABHA_MOCK_MODE and abdm_service._enabled(),
        "mock_mode": settings.ABHA_MOCK_MODE
    }

