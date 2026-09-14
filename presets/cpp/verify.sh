#!/usr/bin/env bash
set -euo pipefail
log() { printf '[NIMOTE] %s\n' "$*"; }
fail() { printf '[NIMOTE] ERROR: %s\n' "$*" >&2; exit 1; }
on_error() { printf '[NIMOTE] ERROR: verification failed (exit %s)\n' "$1" >&2; exit "$1"; }
trap 'on_error $?' ERR
log "Verifying C/C++ Development..."
for command in gcc g++ cmake gdb; do command -v "$command" >/dev/null 2>&1 || fail "$command is unavailable"; done
project=/tmp/nimote-test-cpp
mkdir -p "$project"
printf '#include <stdio.h>\nint main(void) { printf("NIMOTE_CPP_OK\\n"); return 0; }\n' > "$project/main.c"
gcc "$project/main.c" -o "$project/main"
output="$("$project/main")"
[ "$output" = NIMOTE_CPP_OK ] || fail "C sample output was: $output"
g++ --version
cmake --version
gdb --version
log "SUCCESS"
