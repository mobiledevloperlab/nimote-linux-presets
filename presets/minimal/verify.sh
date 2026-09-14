#!/usr/bin/env bash
set -euo pipefail

log() { printf '[NIMOTE] %s\n' "$*"; }
fail() { printf '[NIMOTE] ERROR: %s\n' "$*" >&2; exit 1; }
on_error() { printf '[NIMOTE] ERROR: verification failed (exit %s)\n' "$1" >&2; exit "$1"; }
trap 'on_error $?' ERR

log "Verifying Minimal Development Tools..."
for command in git curl wget jq rg; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is unavailable"
done
git --version
curl --version
wget --version
jq --version
rg --version
log "SUCCESS"
