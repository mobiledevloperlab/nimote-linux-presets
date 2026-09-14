#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$root" <<'PY'
import hashlib, json, pathlib, sys
root = pathlib.Path(sys.argv[1])
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
manifest_path = root / "manifest.json"
root_manifest = json.loads(manifest_path.read_text())
for item in root_manifest["presets"]:
    path = root / item["manifest"]
    preset = json.loads(path.read_text())
    preset["sha256"] = {name: digest(path.parent / name) for name in ("install.sh", "verify.sh")}
    path.write_text(json.dumps(preset, indent=2) + "\n")
    item["sha256"] = digest(path)
manifest_path.write_text(json.dumps(root_manifest, indent=2) + "\n")
files = [manifest_path]
for item in root_manifest["presets"]:
    path = root / item["manifest"]
    files += [path, path.parent / "install.sh", path.parent / "verify.sh"]
(root / "checksums.sha256").write_text("".join(f"{digest(path)}  {path.relative_to(root)}\n" for path in files))
PY
printf 'checksums generated\n'

