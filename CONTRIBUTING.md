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

## Contribution licensing and provenance

By submitting a contribution for inclusion, you agree to license your original
contribution under this repository's MIT license. Submit only material you own
or are authorized to contribute; this does not transfer copyright ownership.
Identify any copied or adapted third-party material, its exact upstream revision,
license and required notices in the PR, and preserve those notices. Maintainers
must review compatibility before merging it; do not relabel third-party code as
MIT or remove its attribution. This policy does not establish provenance for
historical contributions, which must be checked separately if uncertain.

See [Open-source compliance](docs/open-source-compliance.md) for the repository,
APT dependency and application-runtime distribution boundaries.
