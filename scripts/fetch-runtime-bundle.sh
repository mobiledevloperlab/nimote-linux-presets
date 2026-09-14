#!/usr/bin/env bash
set -euo pipefail
: "${NIMOTE_RUNTIME_URL:?set a fixed versioned runtime-bundle URL}"
: "${NIMOTE_RUNTIME_SHA256:?set the expected SHA-256}"
mode="${1:---download}"
case "$mode" in --download|--extract) ;; *) printf 'usage: %s [--download|--extract]\n' "$0" >&2; exit 2;; esac
case "$NIMOTE_RUNTIME_URL" in *'/current/'*|*'/latest/'*|*'localhost'*|*'placeholder'*) printf 'runtime URL must be fixed and public\n' >&2; exit 2;; esac
[[ "$NIMOTE_RUNTIME_SHA256" =~ ^[a-f0-9]{64}$ ]] || { printf 'runtime SHA-256 must be 64 lowercase hex characters\n' >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { printf 'curl is required\n' >&2; exit 1; }
root="$(cd "$(dirname "$0")/.." && pwd)"
destination="${NIMOTE_RUNTIME_OUTPUT:-$root/.cache/runtime/${NIMOTE_RUNTIME_SHA256}.tar}"
mkdir -p "$(dirname "$destination")"
temporary="$destination.partial"
trap 'rm -f "$temporary"' EXIT
curl --fail --location --proto '=https' --tlsv1.2 --output "$temporary" "$NIMOTE_RUNTIME_URL"
actual="$(sha256sum "$temporary" | awk '{print $1}')"
[ "$actual" = "$NIMOTE_RUNTIME_SHA256" ] || { printf 'runtime SHA-256 mismatch\n' >&2; exit 1; }
mv "$temporary" "$destination"
trap - EXIT
printf 'verified runtime bundle: %s\n' "$destination"
if [ "$mode" = --extract ]; then
  command -v tar >/dev/null 2>&1 || { printf 'tar is required for --extract\n' >&2; exit 1; }
  target="${NIMOTE_PROOT_RUNTIME_DIR:-$root/.cache/runtime/${NIMOTE_RUNTIME_SHA256}}"
  [ ! -e "$target" ] || { printf 'runtime directory already exists: %s\n' "$target" >&2; exit 1; }
  tar -tf "$destination" | grep -Eq '(^/|(^|/)\.\.(/|$))' && { printf 'unsafe archive path\n' >&2; exit 1; }
  staging="$target.partial"
  trap 'rm -rf "$staging"' EXIT
  mkdir -p "$staging"
  tar -xf "$destination" -C "$staging" --no-same-owner
  if [ ! -x "$staging/bin/proot" ] || [ ! -d "$staging/rootfs" ]; then
    printf 'runtime bundle must contain bin/proot and rootfs/\n' >&2
    exit 1
  fi
  mv "$staging" "$target"
  trap - EXIT
  printf 'runtime ready: export NIMOTE_PROOT_RUNTIME_DIR=%s\n' "$target"
fi
