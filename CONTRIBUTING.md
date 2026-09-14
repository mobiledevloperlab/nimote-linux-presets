# Contributing

Each change must keep scripts non-interactive, idempotent, and compatible with
Ubuntu under PRoot. Start with `scripts/dev-setup.sh --verify`; it checks the
local toolchain and runs the static gate. A new or changed preset must have a
semantic version bump, regenerated checksums, and real ARM64 **and** AMD64
PRoot reports before it may be marked `stable`.

This is a script/manifest repository. Do not add binaries, rootfs images,
Ubuntu corresponding-source archives, Android paths, credentials, proprietary
NimoteCode source, `sudo`, `curl | sh`, or unverified downloads. Rootfs
corresponding source is published separately by NimoteCode; the optional
runtime downloader accepts only an explicit fixed URL and SHA-256.

For a preset change, describe the affected APT packages, expected disk/network
impact, supported architectures, and the exact validation command in the PR.

All participants must follow the [Code of Conduct](CODE_OF_CONDUCT.md). Use the
issue and pull-request templates to provide reproducible, security-safe reports.
