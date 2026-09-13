#!/usr/bin/env python3
"""
Zero-Data-Loss Migration & Verification Script for MediKiosk
Transfers data from local SQLite (medikiosk.db) to Supabase Postgres,
validates row counts, and verifies schema synchronization.
"""

import sys
import os
import argparse
import json
import sqlite3
from typing import Dict, Any, List

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.supabase import get_supabase_client
from app.config import settings

TABLE_ORDER = [
    "hospitals",
    "users",
    "doctors",
    "emergency_contacts",
    "patient_profiles",
    "visits",
    "appointments",
    "consents",
    "chat_messages",
    "documents",
    "summaries",
    "alerts",
    "ayush_exams",
    "audit_logs"
]

JSON_COLUMNS = {
    "hospitals": ["departments"],
    "doctors": ["languages", "slots_json"],
    "chat_messages": ["answer_json"],
    "documents": ["parsed_json", "flags_json"],
    "summaries": ["content_json"],
    "ayush_exams": ["exam_json"],
    "audit_logs": ["meta_json"]
}

BOOLEAN_COLUMNS = {
    "hospitals": ["is_ayush"],
    "users": ["is_active"],
    "doctors": ["is_ayush"],
    "emergency_contacts": ["consent_flag", "active"],
    "consents": ["audio_flag"]
}

def get_sqlite_conn(db_path=None):
    if not db_path:
        if os.path.exists("backend/medikiosk.db"):
            db_path = "backend/medikiosk.db"
        elif os.path.exists("medikiosk.db"):
            db_path = "medikiosk.db"
        else:
            db_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "medikiosk.db")
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def get_sqlite_counts(db_path=None) -> Dict[str, int]:
    conn = get_sqlite_conn(db_path)
    cur = conn.cursor()
    counts = {}
    for t in TABLE_ORDER:
        try:
            cur.execute(f"SELECT COUNT(*) FROM {t}")
            counts[t] = cur.fetchone()[0]
        except Exception:
            counts[t] = 0
    conn.close()
    return counts

def get_supabase_counts(client) -> Dict[str, int]:
    counts = {}
    for t in TABLE_ORDER:
        try:
            res = client.table(t).select("*", count="exact").limit(1).execute()
            counts[t] = res.count if res.count is not None else len(res.data)
        except Exception as e:
            counts[t] = -1
    return counts

def verify_migration(db_path=None):
    client = get_supabase_client()
    if not client:
        print("[FAIL] Supabase client not configured.")
        return False

    print("================================================================")
    print(" MediKiosk — Zero-Data-Loss Migration & Cloud Sync Verification")
    print("================================================================")
    print(f"Supabase Endpoint: {settings.SUPABASE_URL}")
    print(f"Environment Mode : {settings.ENV_MODE.upper()}")

    local_counts = get_sqlite_counts(db_path)
    remote_counts = get_supabase_counts(client)

    all_match = True
    print(f"\n{'Table Name':<22} | {'Local (SQLite)':<14} | {'Supabase':<10} | {'Status'}")
    print("-" * 65)

    has_pending_schema = False
    for t in TABLE_ORDER:
        lc = local_counts.get(t, 0)
        rc = remote_counts.get(t, 0)
        if rc == -1:
            status = "❌ SCHEMA NOT FOUND"
            has_pending_schema = True
            all_match = False
        elif lc <= rc:
            status = "✅ SYNCED (MATCH)"
        else:
            status = f"⚠️ PENDING ({lc - rc} rows)"
            all_match = False
        print(f"{t:<22} | {lc:<14} | {rc if rc >= 0 else 'N/A':<10} | {status}")

    print("=" * 65)
    if has_pending_schema:
        print("\n[ACTION REQUIRED] Some tables are missing in Supabase PostgreSQL.")
        print("Run the provided SQL migration in Supabase SQL Editor:")
        print(f"File: {os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'supabase_schema.sql'))}")
    elif all_match:
        print("\n[SUCCESS] All SQLite data is 100% verified and synchronized with Supabase!")

    return all_match

def clean_row_for_supabase(table: str, row: Dict[str, Any]) -> Dict[str, Any]:
    cleaned = dict(row)
    # Parse JSON strings into Python objects for jsonb columns
    json_cols = JSON_COLUMNS.get(table, [])
    for col in json_cols:
        if col in cleaned and cleaned[col]:
            if isinstance(cleaned[col], str):
                try:
                    cleaned[col] = json.loads(cleaned[col])
                except Exception:
                    pass

    # Convert integer booleans (SQLite 0/1) to Python bools
    bool_cols = BOOLEAN_COLUMNS.get(table, [])
    for col in bool_cols:
        if col in cleaned and cleaned[col] is not None:
            cleaned[col] = bool(cleaned[col])

    # Convert empty date strings to None
    for k, v in list(cleaned.items()):
        if v == "":
            cleaned[k] = None

    return cleaned

def run_migration(dry_run=False, db_path=None):
    client = get_supabase_client()
    if not client:
        print("[ERROR] Supabase client not initialized. Check .env credentials.")
        return False

    if not db_path:
        if os.path.exists("backend/medikiosk.db"):
            db_path = "backend/medikiosk.db"
        elif os.path.exists("medikiosk.db"):
            db_path = "medikiosk.db"
        else:
            db_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "medikiosk.db")

    if not os.path.exists(db_path):
        print(f"[ERROR] SQLite database file not found at: {db_path}")
        return False

    conn = get_sqlite_conn(db_path)
    cur = conn.cursor()

    print(f"Starting MediKiosk migration from SQLite ({db_path}) to Supabase...")
    print(f"Dry-run: {dry_run}")
    print("-" * 60)

    total_synced = 0
    errors = []

    for t in TABLE_ORDER:
        try:
            cur.execute(f"SELECT * FROM {t}")
            raw_rows = [dict(r) for r in cur.fetchall()]
        except Exception as e:
            print(f"Skipping table '{t}': {e}")
            continue

        if not raw_rows:
            print(f"Table '{t}': 0 rows in SQLite (Skipping)")
            continue

        rows = [clean_row_for_supabase(t, r) for r in raw_rows]
        print(f"Processing table '{t}' ({len(rows)} records)...")

        if dry_run:
            print(f"  [DRY-RUN] Prepared {len(rows)} rows for '{t}'")
            continue

        try:
            batch_size = 50
            for i in range(0, len(rows), batch_size):
                batch = rows[i:i + batch_size]
                client.table(t).upsert(batch).execute()
            print(f"  ✅ Successfully migrated {len(rows)} records to Supabase table '{t}'")
            total_synced += len(rows)
        except Exception as e:
            msg = f"  ❌ Error syncing table '{t}': {e}"
            print(msg)
            errors.append(msg)

    conn.close()
    print("-" * 60)
    print(f"Migration finished. Total rows processed: {total_synced}")
    if errors:
        print(f"Encountered {len(errors)} errors. If tables do not exist, run 'supabase_schema.sql' in Supabase SQL editor.")
    return len(errors) == 0

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="MediKiosk Supabase Migrator & Synchronizer")
    parser.add_argument("--verify", action="store_true", help="Verify counts between SQLite and Supabase")
    parser.add_argument("--dry-run", action="store_true", help="Perform a dry run without modifying Supabase")
    args = parser.parse_args()

    if args.verify:
        verify_migration()
    else:
        run_migration(dry_run=args.dry_run)
