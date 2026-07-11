#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"

current_image="$(compose config | awk '/image: ghcr.io.*\/honcho:/{print $2; exit}')"
echo "Configured image: ${current_image:-unknown}"

"${SCRIPT_DIR}/backup.sh" pre-upgrade
compose pull api deriver
compose up -d --remove-orphans

for _ in {1..30}; do
  status="$(compose ps --format json api 2>/dev/null || true)"
  if grep -q '"Health":"healthy"' <<<"${status}"; then
    echo "Honcho update completed; API is healthy."
    exit 0
  fi
  sleep 5
done

compose ps
echo "Update started, but API did not become healthy in time. Review logs." >&2
exit 1
