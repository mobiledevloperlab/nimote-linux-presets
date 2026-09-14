#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tag="${1:?usage: package-release.sh <vMAJOR.MINOR.PATCH>}"
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { printf 'release tag must be vMAJOR.MINOR.PATCH\n' >&2; exit 2; }

output_dir="${NIMOTE_RELEASE_OUTPUT_DIR:-$root/dist}"
mkdir -p "$output_dir"
archive="$output_dir/nimotecode-linux-presets-$tag.tar.gz"
checksum="$archive.sha256"
if [ -e "$archive" ] || [ -e "$checksum" ]; then
  printf 'release asset already exists: %s\n' "$archive" >&2
  exit 1
fi

tar -C "$root" -czf "$archive" manifest.json checksums.sha256 presets
sha256sum "$archive" > "$checksum"
printf 'release bundle created: %s\n' "$archive"
