#!/bin/sh
set -e

echo "Initializing database..."
python - <<'PY'
from app.database import engine, Base

# Create all tables
Base.metadata.create_all(bind=engine)
print("Database tables created successfully")
PY

if [ "${RUN_UPDATECATALOG_ON_STARTUP:-false}" = "true" ]; then
  echo "Updating Gutenberg catalog (this can take several minutes)..."
  python catalog/updatecatalog.py
fi

echo "Starting FastAPI server..."
UVICORN_WORKERS="${UVICORN_WORKERS:-2}"
UVICORN_LIMIT_MAX_REQUESTS="${UVICORN_LIMIT_MAX_REQUESTS:-2000}"

exec uvicorn app.main:app \
  --host 0.0.0.0 \
  --port 8000 \
  --workers "${UVICORN_WORKERS}" \
  --limit-max-requests "${UVICORN_LIMIT_MAX_REQUESTS}"
