# Testing

## Local prerequisites

Static checks require Bash, ShellCheck, Python 3, and the Python `jsonschema`
package. On Ubuntu, install the latter two with:

```bash
sudo apt-get install shellcheck python3-jsonschema
```

Run `scripts/dev-setup.sh --verify` to check these prerequisites and execute
the static gate. It never installs packages or uses elevated privileges.

Layer 1 runs `bash -n`, ShellCheck, manifest JSON Schema validation, hash
validation, and policy tests. Layer 2 starts one fresh Ubuntu container for each
preset; it installs the preset (and its declared minimal dependency) then runs
the runtime verifier. Containers are useful but never assert PRoot support.

Layer 3 runs `scripts/test-proot.sh PRESET` against a **fresh** matching
NimoteCode rootfs. Set `NIMOTE_PROOT_BIN` and `NIMOTE_PROOT_ROOTFS`, or set
`NIMOTE_PROOT_RUNTIME_DIR` when the runtime bundle has `bin/proot` and `rootfs/`.
`scripts/fetch-runtime-bundle.sh --extract` can download and prepare a versioned test bundle only
when both `NIMOTE_RUNTIME_URL` and `NIMOTE_RUNTIME_SHA256` are explicitly
supplied; it rejects floating URLs and verifies the archive before use. The
harness binds only `/dev`, `/proc`, resolver configuration, and this repository,
then writes `test-results/<preset>-proot-<architecture>.json`.

Local reports are ignored because they may contain machine-specific command
output; the protected release workflow generates and attaches fresh reports for
both architectures. A compliance audit is not a substitute for preset test
reports.

It must verify process creation, `/proc`, executable bits, symlinks, runtime
execution, and native compilation where applicable.

Installers preflight available disk on `/`. Under PRoot, GNU `timeout` cannot
reliably terminate a DNS child process, so every installer sets glibc
`RES_OPTIONS=attempts:1 timeout:5` (overridable with `NIMOTE_RES_OPTIONS`). APT
then adds its own 30-second HTTP/HTTPS connection timeouts and three retries.
This avoids a separate `getent` probe. APT reports package-index, disk, network
or concurrent-transaction failures without removing any lock file.
