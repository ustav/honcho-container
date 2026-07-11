#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"

mkdir -p \
  "${DATA_ROOT}/postgres" \
  "${DATA_ROOT}/redis" \
  "${DATA_ROOT}/backups/daily" \
  "${DATA_ROOT}/backups/pre-upgrade" \
  "${DATA_ROOT}/logs"

chmod 700 "${DATA_ROOT}/backups"
echo "Created persistent directories under ${DATA_ROOT}"
