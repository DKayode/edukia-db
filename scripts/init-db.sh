#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Validate required env vars
if [ -z "$NEON_USER" ] || [ -z "$NEON_PASSWORD" ] || [ -z "$NEON_HOST" ]; then
    echo "❌ Missing required environment variables:"
    echo "   NEON_USER, NEON_PASSWORD, NEON_HOST"
    exit 1
fi

DB_URL="postgresql://${NEON_USER}:${NEON_PASSWORD}@${NEON_HOST}/edukia?sslmode=require"

echo "Initializing Edukia database..."
echo "Host: $NEON_HOST"

# 1. Apply schema from repo
echo "Applying schema..."
psql "$DB_URL" -f "./schemas/base_schema.sql"
if [ $? -ne 0 ]; then
    echo "❌ Schema application failed"
    exit 1
fi

# 2. Seed admin user
echo "Seeding admin user..."
psql "$DB_URL" -f "./scripts/seed-admin.sql"
if [ $? -ne 0 ]; then
    echo "❌ Admin seeding failed"
    exit 1
fi

echo "✅ Edukia database initialized"