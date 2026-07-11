#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"

BACKUP_KIND="${1:-daily}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
case "${BACKUP_KIND}" in
  daily|pre-upgrade) ;;
  *) echo "Usage: $0 [daily|pre-upgrade]" >&2; exit 2 ;;
esac

backup_dir="${DATA_ROOT}/backups/${BACKUP_KIND}"
mkdir -p "${backup_dir}"
timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
backup_file="${backup_dir}/honcho_${POSTGRES_DB}_${timestamp}.dump"
tmp_file="${backup_file}.partial"

cleanup() { rm -f "${tmp_file}"; }
trap cleanup EXIT

compose exec -T database pg_dump \
  --username "${POSTGRES_USER}" \
  --dbname "${POSTGRES_DB}" \
  --format=custom \
  --no-owner \
  --no-privileges > "${tmp_file}"

[[ -s "${tmp_file}" ]] || { echo "Backup is empty" >&2; exit 1; }
compose exec -T database pg_restore --list < "${tmp_file}" >/dev/null
mv "${tmp_file}" "${backup_file}"
trap - EXIT

if [[ "${BACKUP_KIND}" == "daily" ]]; then
  find "${backup_dir}" -type f -name '*.dump' -mtime "+${RETENTION_DAYS}" -delete
fi

echo "Backup created and verified: ${backup_file}"
