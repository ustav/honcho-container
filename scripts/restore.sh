#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"

backup_file="${1:-}"
if [[ -z "${backup_file}" || ! -f "${backup_file}" ]]; then
  echo "Usage: $0 /absolute/path/to/backup.dump" >&2
  exit 2
fi

compose exec -T database pg_restore --list < "${backup_file}" >/dev/null

if [[ "${CONFIRM_RESTORE:-}" != "YES" ]]; then
  echo "This replaces database '${POSTGRES_DB}'." >&2
  echo "Run with CONFIRM_RESTORE=YES after creating a current backup." >&2
  exit 3
fi

compose stop api deriver || true
compose exec -T database psql --username "${POSTGRES_USER}" --dbname postgres \
  --set ON_ERROR_STOP=1 \
  --command "DROP DATABASE IF EXISTS \"${POSTGRES_DB}\" WITH (FORCE);"
compose exec -T database psql --username "${POSTGRES_USER}" --dbname postgres \
  --set ON_ERROR_STOP=1 \
  --command "CREATE DATABASE \"${POSTGRES_DB}\" OWNER \"${POSTGRES_USER}\";"
compose exec -T database psql --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" \
  --set ON_ERROR_STOP=1 \
  --command "CREATE EXTENSION IF NOT EXISTS vector;"
compose exec -T database pg_restore \
  --username "${POSTGRES_USER}" \
  --dbname "${POSTGRES_DB}" \
  --no-owner \
  --no-privileges \
  --exit-on-error < "${backup_file}"
compose up -d api deriver

echo "Restore completed from ${backup_file}"
