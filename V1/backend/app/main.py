import os
import contextlib
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.api.v1.router import api_router
from app.portal_router import portal_router
from app.core.exceptions import MediKioskException, medikiosk_exception_handler
from app.database import init_db, AsyncSessionLocal
from app.seed.seed_data import seed_demo_data
from app.config import settings

logger = logging.getLogger("medikiosk.main")

@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        await init_db()
        async with AsyncSessionLocal() as session:
            await seed_demo_data(session)
    except Exception as e:
        logger.warning(f"Lifespan initialization notice: {e}")
    yield

app = FastAPI(
    title="MediKiosk Clinical History Intake Platform",
    description="AI-powered clinical history intake platform with AYUSH, Supabase, and ABDM interoperability",
    version=settings.APP_VERSION,
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_exception_handler(MediKioskException, medikiosk_exception_handler)

# Mount REST API
app.include_router(api_router, prefix="/api/v1")

# Mount Doctor Portal
app.include_router(portal_router, prefix="/portal", tags=["portal"])

# Static files & uploads directory handling (Serverless safe)
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
static_dir = os.path.join(base_dir, "app", "static")

if os.environ.get("VERCEL"):
    uploads_dir = "/tmp/uploads"
else:
    uploads_dir = os.path.join(base_dir, "uploads")

try:
    os.makedirs(os.path.join(static_dir, "css"), exist_ok=True)
    os.makedirs(os.path.join(static_dir, "js"), exist_ok=True)
    os.makedirs(uploads_dir, exist_ok=True)
except Exception as e:
    logger.warning(f"Could not create static/upload folders: {e}")

if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")

if os.path.exists(uploads_dir):
    app.mount("/uploads", StaticFiles(directory=uploads_dir), name="uploads")

@app.get("/")
async def root():
    return {
        "message": "MediKiosk Clinical History Intake Platform is running",
        "api_docs": "/docs",
        "doctor_portal": "/portal",
        "health_check": "/health",
        "config": "/api/v1/meta/config",
        "env_mode": settings.ENV_MODE,
        "database_type": "supabase_postgres" if "postgres" in settings.DATABASE_URL else "sqlite",
        "deployment_target": "vercel" if os.environ.get("VERCEL") else "local"
    }

@app.get("/health")
async def health():
    from app.supabase import get_supabase_client
    supabase_ok = get_supabase_client() is not None
    is_postgres = "postgres" in settings.DATABASE_URL
    return {
        "status": "ok",
        "app": "MediKiosk",
        "version": settings.APP_VERSION,
        "env_mode": settings.ENV_MODE,
        "database_type": "supabase_postgres" if is_postgres else "sqlite",
        "db": "ok",
        "storage": "supabase_cloud" if supabase_ok else "local_fallback",
        "supabase_connected": supabase_ok,
        "deployment_target": "vercel" if os.environ.get("VERCEL") else "local"
    }
