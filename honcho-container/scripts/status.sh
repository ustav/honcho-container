#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
compose ps
compose exec -T database pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
