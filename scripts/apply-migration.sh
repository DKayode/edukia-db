#!/bin/bash
set -euo pipefail

MIGRATION_FILE=$1
COUNTRY=$2

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Validate input
if [ -z "$MIGRATION_FILE" ] || [ -z "$COUNTRY" ]; then
    echo "❌ Usage: $0 <migration_file.sql> <country_code>"
    echo "   Example: $0 007_add_report_index.sql benin"
    exit 1
fi

if [ ! -f "./migrations/$MIGRATION_FILE" ]; then
    echo "❌ Migration not found: ./migrations/$MIGRATION_FILE"
    exit 1
fi

if [ -z "${NEON_USER:-}" ] || [ -z "${NEON_PASSWORD:-}" ] || [ -z "${NEON_HOST:-}" ]; then
    echo "❌ Missing: NEON_USER, NEON_PASSWORD, NEON_HOST"
    exit 1
fi

# ── Apply to specific country ──
DB_URL="postgresql://${NEON_USER}:${NEON_PASSWORD}@${NEON_HOST}/${COUNTRY}?sslmode=require"

echo "Applying $(basename "$MIGRATION_FILE") to $COUNTRY..."

psql "$DB_URL" -v ON_ERROR_STOP=1 -f "./migrations/$MIGRATION_FILE"

# ── Verify ──
# Extract index name using sed (portable, no -P needed)
INDEX_NAME=$(sed -n 's/.*CREATE INDEX CONCURRENTLY IF NOT EXISTS \([a-zA-Z0-9_]*\).*/\1/p' "./migrations/$MIGRATION_FILE" | head -1)

if [ -n "$INDEX_NAME" ]; then
    if psql "$DB_URL" -t -c "SELECT 1 FROM pg_indexes WHERE indexname = '$INDEX_NAME';" | grep -q "1"; then
        echo "  ✅ Index '$INDEX_NAME' created"
    else
        echo "  ⚠️  Index '$INDEX_NAME' not found — check manually"
    fi
fi

echo "✅ $COUNTRY done"