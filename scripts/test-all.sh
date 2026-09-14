#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
"$root/scripts/lint.sh"
for test in "$root"/tests/shell/*.sh; do "$test"; done
printf 'static tests passed\n'

