import os
import logging
from typing import Optional
from supabase import create_client, Client
from app.config import settings

logger = logging.getLogger("medikiosk.supabase")

_supabase_client: Optional[Client] = None

def get_supabase_client() -> Optional[Client]:
    """
    Returns the Supabase Client singleton initialized with service role key
    for backend privileged access. Returns None if credentials not configured.
    """
    global _supabase_client
    if _supabase_client is not None:
        return _supabase_client

    url = settings.SUPABASE_URL or os.environ.get("SUPABASE_URL", "")
    key = settings.SERVICE_ROLE or settings.SUPABASE_KEY or os.environ.get("SERVICE_ROLE", "")

    if not url or not key:
        logger.warning("Supabase URL or Key not set. Supabase client will be disabled.")
        return None

    try:
        _supabase_client = create_client(url, key)
        logger.info("Supabase client initialized successfully.")
    except Exception as e:
        logger.error(f"Failed to initialize Supabase client: {e}")
        _supabase_client = None

    return _supabase_client

def ensure_storage_bucket(bucket_name: str = "medical-documents") -> bool:
    """
    Ensures that the private storage bucket exists for medical documents.
    """
    client = get_supabase_client()
    if not client:
        return False

    try:
        buckets = client.storage.list_buckets()
        existing = [b.name for b in buckets if hasattr(b, "name")]
        if bucket_name not in existing:
            client.storage.create_bucket(bucket_name, options={"public": False, "file_size_limit": 52428800})
            logger.info(f"Created private Supabase storage bucket: '{bucket_name}'")
        return True
    except Exception as e:
        logger.warning(f"Could not verify/create Supabase bucket '{bucket_name}': {e}")
        return False

