# Release process

1. Configure GitHub before the first release: protect `main`, restrict creation
   of `v*` tags, require the lint and integration checks, and configure the
   `android-proot-release` environment with an approving maintainer.
2. Bump only the changed preset's semantic version and update its manifest.
3. Run static checks, isolated Ubuntu integration, and a fresh Android ARM64
   PRoot test for every release preset.
4. Commit generated `checksums.sha256` and manifests. Do not alter an existing
   tag; publish a new tag such as `v1.0.1` instead.
5. The release gate accepts only a `vMAJOR.MINOR.PATCH` tag and requires passing
   ARM64 PRoot reports plus `status: stable` for every released preset. It
   attaches a versioned preset bundle and its SHA-256 sidecar to the release.

Experimental presets may be published for explicit testing but cannot be part
of a Stable release gate.

## License review before publication

Inspect the generated preset archive and confirm it contains the unchanged
`LICENSE` and `NOTICE` alongside the manifests and scripts. The archive SHA-256
sidecar covers these files too; `checksums.sha256` covers the catalog and preset
payload only. Retain any additional third-party notices required by future
approved contributions. Review [Open-source compliance](open-source-compliance.md)
when changing distribution contents. If an older published bundle omitted the
license, provide its applicable LICENSE and NOTICE alongside that release and
publish a corrected bundle under a new version; do not silently replace an
existing asset or tag.
