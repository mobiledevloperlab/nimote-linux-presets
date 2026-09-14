#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
preset="${1:?usage: test-preset.sh <preset>}"
case "$preset" in minimal|python|web|cpp) ;; *) printf 'unknown preset: %s\n' "$preset" >&2; exit 2;; esac
test -x "$root/presets/$preset/install.sh" || { printf 'unknown preset: %s\n' "$preset" >&2; exit 2; }
"$root/presets/$preset/install.sh"
"$root/presets/$preset/verify.sh"
