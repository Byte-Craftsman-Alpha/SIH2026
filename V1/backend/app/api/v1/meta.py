from fastapi import APIRouter
from fastapi.responses import JSONResponse, Response
from app.config import settings

router = APIRouter()

@router.get("/health")
async def health():
    from app.supabase import get_supabase_client
    supabase_ok = get_supabase_client() is not None
    return {
        "status": "ok",
        "app": "MediKiosk Clinical History Intake Platform",
        "version": settings.APP_VERSION,
        "db": "ok",
        "storage": "ok" if supabase_ok else "local_fallback",
        "supabase_connected": supabase_ok,
        "demo_mode": settings.DEMO_MODE
    }

@router.get("/meta/config")
async def meta_config():
    return {
        "app_name": "MediKiosk",
        "tagline": "Aapki Sehat, Aapki Zubani",
        "version": settings.APP_VERSION,
        "supported_languages": [
            {"code": "hi", "label": "हिंदी", "name": "Hindi", "flag": "🇮🇳"},
            {"code": "en", "label": "English", "name": "English", "flag": "🌐"},
            {"code": "sa", "label": "संस्कृतम्", "name": "Sanskrit", "flag": "🕉️"},
            {"code": "ta", "label": "தமிழ்", "name": "Tamil", "flag": "🇮🇳"},
            {"code": "te", "label": "తెలుగు", "name": "Telugu", "flag": "🇮🇳"}
        ],
        "default_language": "hi",
        "modes": ["kiosk", "mobile"],
        "emergency_numbers": {
            "ambulance": "108",
            "emergency_disaster": "112",
            "ayush_helpline": "1800-11-2233"
        },
        "features": {
            "voice_guidance": True,
            "offline_first": True,
            "ayush_dashavidha": True,
            "red_flag_triaging": True,
            "abdm_interop": True
        }
    }

@router.get("/tts/{key}.{lang}.mp3")
async def tts(key: str, lang: str):
    # Returns a lightweight mock audio response for testing
    return Response(content=b"\x00" * 32, media_type="audio/mpeg")
