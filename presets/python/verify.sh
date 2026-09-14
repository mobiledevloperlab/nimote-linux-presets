#!/usr/bin/env bash
set -euo pipefail
log() { printf '[NIMOTE] %s\n' "$*"; }
fail() { printf '[NIMOTE] ERROR: %s\n' "$*" >&2; exit 1; }
on_error() { printf '[NIMOTE] ERROR: verification failed (exit %s)\n' "$1" >&2; exit "$1"; }
trap 'on_error $?' ERR
log "Verifying Python Development..."
command -v python3 >/dev/null 2>&1 || fail "python3 is unavailable"
command -v pip3 >/dev/null 2>&1 || fail "pip3 is unavailable"
python3 --version
pip3 --version
project=/tmp/nimote-test-python
mkdir -p "$project"
printf 'print("NIMOTE_PYTHON_OK")\n' > "$project/main.py"
output="$(python3 "$project/main.py")"
[ "$output" = NIMOTE_PYTHON_OK ] || fail "Python sample output was: $output"
(cd "$project" && python3 -m venv .venv)
venv_version="$("$project/.venv/bin/python" --version)"
case "$venv_version" in Python\ *) ;; *) fail "venv interpreter did not execute: $venv_version";; esac
log "SUCCESS"
