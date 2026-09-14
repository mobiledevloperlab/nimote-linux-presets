#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
if rg -n 'curl[^\n]*\|[[:space:]]*(ba)?sh|sudo|termux|/data/data|systemctl' "$root/presets" "$root/scripts"; then
  printf 'prohibited script construct found\n' >&2
  exit 1
fi
printf 'script policy passed\n'
