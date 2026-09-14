#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
preset="${1:-minimal}"
case "$preset" in minimal|python|web|cpp) ;; *) printf '[NIMOTE] ERROR: unsupported preset: %s\n' "$preset" >&2; exit 2;; esac
if [ -n "${NIMOTE_PROOT_RUNTIME_DIR:-}" ]; then
  : "${NIMOTE_PROOT_BIN:=$NIMOTE_PROOT_RUNTIME_DIR/bin/proot}"
  : "${NIMOTE_PROOT_ROOTFS:=$NIMOTE_PROOT_RUNTIME_DIR/rootfs}"
fi
: "${NIMOTE_PROOT_BIN:?set NIMOTE_PROOT_BIN to a host PRoot binary}"
: "${NIMOTE_PROOT_ROOTFS:?set NIMOTE_PROOT_ROOTFS to a fresh, matching-architecture rootfs}"
test -x "$NIMOTE_PROOT_BIN" || { printf '[NIMOTE] ERROR: PRoot is not executable\n' >&2; exit 2; }
test -d "$NIMOTE_PROOT_ROOTFS" || { printf '[NIMOTE] ERROR: rootfs is unavailable\n' >&2; exit 2; }
start="$(date +%s)"
guest() {
  "$NIMOTE_PROOT_BIN" -0 -r "$NIMOTE_PROOT_ROOTFS" -b /dev -b /proc -b /etc/resolv.conf -b "$root:/opt/nimotecode-linux-presets" -w /root /bin/bash -c "$1"
}
set +e
if [ "$preset" = minimal ]; then guest '/opt/nimotecode-linux-presets/presets/minimal/install.sh && /opt/nimotecode-linux-presets/presets/minimal/verify.sh'; else guest "/opt/nimotecode-linux-presets/presets/minimal/install.sh && /opt/nimotecode-linux-presets/presets/$preset/install.sh && /opt/nimotecode-linux-presets/presets/$preset/verify.sh"; fi
status=$?
set -e
mkdir -p "$root/test-results"
version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$root/presets/$preset/manifest.json")"
architecture="$(guest 'dpkg --print-architecture' 2>/dev/null || printf unknown)"
duration="$(( $(date +%s) - start ))"
commands="$(case "$preset" in
  minimal) guest 'git --version; curl --version | head -n1; wget --version | head -n1; jq --version; rg --version' 2>/dev/null || true;;
  python) guest 'python3 --version; pip3 --version' 2>/dev/null || true;;
  web) guest 'node --version; npm --version' 2>/dev/null || true;;
  cpp) guest 'gcc --version | head -n1; g++ --version | head -n1; cmake --version | head -n1; gdb --version | head -n1' 2>/dev/null || true;;
esac)"
python3 - "$root/test-results/$preset-proot-$architecture.json" "$preset" "$version" "$architecture" "$status" "$duration" "$commands" <<'PY'
import json, sys, datetime
path, preset, version, arch, status, duration, commands = sys.argv[1:]
result = {"preset":preset,"version":version,"architecture":arch,"distribution":"ubuntu","install":"pass" if status == "0" else "fail","verify":"pass" if status == "0" else "fail","duration":int(duration),"testedAt":datetime.datetime.now(datetime.timezone.utc).isoformat(),"commands":{"versions":commands}}
open(path, "w").write(json.dumps(result, indent=2) + "\n")
PY
exit "$status"
