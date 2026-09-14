## Summary

Describe the change and why it is needed.

## Validation

- [ ] `scripts/test-all.sh` passes.
- [ ] `scripts/dev-setup.sh --verify` was run locally, or the missing local prerequisite is stated below.
- [ ] Manifest versions and checksums were updated if a preset changed.
- [ ] Affected ARM64/AMD64 runtime tests were run, skipped with reason, or their results are described below.

## Preset impact

- Affected APT packages, expected download/disk impact, and supported architectures:
- Exact install/verify command and result:

## Security and scope

- [ ] This change adds no credentials, binaries, rootfs images, Ubuntu corresponding-source archives, Android paths, or proprietary source.
- [ ] Any download uses a fixed URL and SHA-256; no `curl | sh`, `sudo`, or floating release URL was added.
- [ ] This change follows the Code of Conduct and SECURITY policy.
