from fastapi import APIRouter
from . import auth, profile, chat, documents, appointments, summaries, consents, alerts, doctor, admin, meta, fhir

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(profile.router, prefix="/profile", tags=["profile"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
api_router.include_router(documents.router, prefix="/documents", tags=["documents"])
api_router.include_router(appointments.router, tags=["appointments"])
api_router.include_router(summaries.router, prefix="/summaries", tags=["summaries"])
api_router.include_router(consents.router, prefix="/consents", tags=["consents"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["alerts"])
api_router.include_router(doctor.router, prefix="/doctor", tags=["doctor"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(meta.router, tags=["meta"])
api_router.include_router(fhir.router, prefix="/fhir", tags=["fhir"])
