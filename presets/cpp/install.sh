#!/usr/bin/env bash
set -euo pipefail
log() { printf '[NIMOTE] %s\n' "$*"; }
fail() { printf '[NIMOTE] ERROR: %s\n' "$*" >&2; exit 1; }
on_error() { printf '[NIMOTE] ERROR: command failed (exit %s)\n' "$1" >&2; exit "$1"; }
trap 'on_error $?' ERR
export DEBIAN_FRONTEND=noninteractive
export RES_OPTIONS="${NIMOTE_RES_OPTIONS:-attempts:1 timeout:5}"
preflight() {
  required_kb="$1"; available_kb="$(df -Pk / | awk 'NR == 2 { print $4 }')"
  [ "${available_kb:-0}" -ge "$required_kb" ] || fail "insufficient disk space: need ${required_kb} KB free on /, found ${available_kb:-0} KB"
}
[ "${EUID}" -eq 0 ] || fail "package installation needs permission inside Ubuntu; Android root is never required"
command -v apt-get >/dev/null 2>&1 || fail "Ubuntu apt-get is required"
preflight 512000
log "Installing C/C++ Development..."
if ! dpkg --configure -a; then fail "package manager recovery failed; resolve the dpkg transaction before retrying"; fi
log "Updating package index..."
if ! apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 update; then fail "package index update failed; check network, DNS, repository access, APT connection timeout, and any active apt transaction"; fi
packages=(build-essential gcc g++ make cmake gdb pkg-config)
missing=()
for package in "${packages[@]}"; do dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null | grep -qx installed || missing+=("$package"); done
if [ "${#missing[@]}" -gt 0 ]; then log "Installing packages..."; if ! apt-get -o Acquire::Retries=3 -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 install -y --no-install-recommends "${missing[@]}"; then fail "package installation failed; check free disk space, network, APT connection timeout, and the dpkg/apt transaction state"; fi; else log "All requested packages are already installed."; fi
log "Running verification..."
"$(dirname "$0")/verify.sh"
log "SUCCESS"
