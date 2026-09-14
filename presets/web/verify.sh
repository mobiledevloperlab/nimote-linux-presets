#!/usr/bin/env bash
set -euo pipefail
log() { printf '[NIMOTE] %s\n' "$*"; }
fail() { printf '[NIMOTE] ERROR: %s\n' "$*" >&2; exit 1; }
on_error() { printf '[NIMOTE] ERROR: verification failed (exit %s)\n' "$1" >&2; exit "$1"; }
trap 'on_error $?' ERR
log "Verifying Web Development..."
command -v node >/dev/null 2>&1 || fail "node is unavailable"
command -v npm >/dev/null 2>&1 || fail "npm is unavailable"
node --version
npm --version
project=/tmp/nimote-test-web
mkdir -p "$project"
(cd "$project" && npm init -y >/dev/null)
printf 'console.log("NIMOTE_WEB_OK");\n' > "$project/main.js"
output="$(node "$project/main.js")"
[ "$output" = NIMOTE_WEB_OK ] || fail "Node sample output was: $output"
log "SUCCESS"
