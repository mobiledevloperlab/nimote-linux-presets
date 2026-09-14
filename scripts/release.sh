#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
: "${GITHUB_REF_NAME:?release requires an immutable version tag}"
[[ "$GITHUB_REF_NAME" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { printf 'release tag must be vMAJOR.MINOR.PATCH\n' >&2; exit 2; }
"$root/scripts/lint.sh"
python3 - "$root" <<'PY'
import json, pathlib, sys
root = pathlib.Path(sys.argv[1])
for manifest in root.glob("presets/*/manifest.json"):
    data = json.loads(manifest.read_text())
    if data["status"] != "stable": raise SystemExit(f"stable release requires status=stable: {manifest}")
    for architecture in ("arm64", "amd64"):
        reports = list((root / "test-results").rglob(f"{data['id']}-proot-{architecture}.json"))
        if len(reports) != 1: raise SystemExit(f"missing unique {architecture} PRoot report for {data['id']}")
        result = json.loads(reports[0].read_text())
        if result.get("architecture") != architecture or result.get("install") != "pass" or result.get("verify") != "pass": raise SystemExit(f"release gate failed: {reports[0]}")
PY
"$root/scripts/package-release.sh" "$GITHUB_REF_NAME"
printf 'release gate passed for %s\n' "$GITHUB_REF_NAME"
