#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
mode="${1:---check}"
case "$mode" in --check|--verify) ;; *) printf 'usage: %s [--check|--verify]\n' "$0" >&2; exit 2;; esac
missing=()
for command in bash python3 shellcheck; do command -v "$command" >/dev/null 2>&1 || missing+=("$command"); done
python3 -c 'import jsonschema' >/dev/null 2>&1 || missing+=("python3-jsonschema")
if [ "${#missing[@]}" -gt 0 ]; then
  printf 'missing development prerequisites: %s\n' "${missing[*]}" >&2
  printf 'Install Bash, ShellCheck and Python jsonschema with your system package manager, then retry.\n' >&2
  exit 1
fi
printf 'development prerequisites available\n'
if [ "$mode" = --verify ]; then "$root/scripts/test-all.sh"; fi
