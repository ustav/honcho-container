#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
DEPLOY_DIR="${DEPLOY_DIR:-${REPO_DIR}/deploy}"
ENV_FILE="${ENV_FILE:-${DEPLOY_DIR}/.env}"
COMPOSE_FILE="${COMPOSE_FILE:-${DEPLOY_DIR}/compose.yml}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy deploy/.env.example to deploy/.env and edit it." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "${ENV_FILE}"
set +a

: "${DATA_ROOT:?DATA_ROOT is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"

compose() {
  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" "$@"
}
