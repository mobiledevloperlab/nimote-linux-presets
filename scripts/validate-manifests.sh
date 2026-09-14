#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$root" <<'PY'
import hashlib, json, pathlib, sys
try:
    import jsonschema
except ImportError as exc:
    raise SystemExit("jsonschema is required (install python3-jsonschema)") from exc
root = pathlib.Path(sys.argv[1])
def load(path):
    with path.open() as f: return json.load(f)
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
jsonschema.validate(load(root / "manifest.json"), load(root / "schemas/manifest.schema.json"))
manifest = load(root / "manifest.json")
for item in manifest["presets"]:
    path = root / item["manifest"]
    if digest(path) != item["sha256"]:
        raise SystemExit(f"root manifest hash mismatch: {path}")
    preset = load(path)
    jsonschema.validate(preset, load(root / "schemas/preset.schema.json"))
    if item["id"] != preset["id"]:
        raise SystemExit(f"preset ID mismatch: {path}")
    for script, expected in preset["sha256"].items():
        script_path = path.parent / script
        if digest(script_path) != expected:
            raise SystemExit(f"preset script hash mismatch: {script_path}")
expected_files = [root / "manifest.json"]
for item in manifest["presets"]:
    path = root / item["manifest"]
    preset = load(path)
    expected_files.append(path)
    expected_files.extend(path.parent / script for script in preset["sha256"])
expected = {str(path.relative_to(root)): digest(path) for path in expected_files}
checksums = {}
for line in (root / "checksums.sha256").read_text().splitlines():
    value, separator, relative = line.partition("  ")
    if not separator or len(value) != 64 or any(c not in "0123456789abcdef" for c in value) or not relative:
        raise SystemExit(f"invalid checksums entry: {line!r}")
    if relative in checksums:
        raise SystemExit(f"duplicate checksums entry: {relative}")
    checksums[relative] = value
if checksums != expected:
    raise SystemExit("checksums.sha256 does not match the declared release files")
print("manifest validation passed")
PY
