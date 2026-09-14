#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
mapfile -t scripts < <(find "$root/presets" "$root/scripts" -type f -name '*.sh' -print | sort)
for script in "${scripts[@]}"; do
  bash -n "$script"
  head -n 2 "$script" | grep -qx 'set -euo pipefail' || { printf 'missing strict mode: %s\n' "$script" >&2; exit 1; }
done
command -v shellcheck >/dev/null 2>&1 || { printf 'shellcheck is required\n' >&2; exit 1; }
shellcheck -x "${scripts[@]}"
"$root/scripts/validate-manifests.sh"
printf 'lint passed\n'
