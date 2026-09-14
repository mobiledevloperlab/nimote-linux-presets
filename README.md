# NimoteCode Linux Presets

Versioned, checksum-verified development-environment presets for the **NimoteCode Local Linux Environment**.

[NimoteCode website](https://nimotecode.com) · [Main project](https://github.com/mobiledevloperlab/nimotecode) · [Android Local Linux documentation](https://nimotecode.com/docs/local-linux) · [Presets documentation](https://nimotecode.com/docs/local-linux/presets)

This is an independent technical repository. It owns preset manifests, installers, verifiers, schemas, tests, and release packaging. It does not contain NimoteCode application source, Android binaries, PRoot binaries, Ubuntu rootfs archives, or proprietary code.

## Purpose

NimoteCode Local Linux provides a PRoot-based Ubuntu userspace on supported Android devices. This repository defines optional, reviewable toolsets for that environment. NimoteCode obtains a declared manifest, verifies script hashes, presents the action for confirmation, then runs the selected installer and verifier inside Local Linux over its local SSH connection.

Presets do not grant Android root, manage app installation state, replace the Local Linux runtime, or automatically uninstall shared APT dependencies.

## Supported environment

| Component | Declared support |
| --- | --- |
| Distribution | Ubuntu 24.04 |
| Architectures | `arm64`, `amd64` |
| Android requirement | API 26 / Android 8 or later, through the Local Linux runtime |
| PRoot runtime | `5.1.107.92` |
| Shell / packages | Bash and APT inside the Ubuntu rootfs |
| Local connection | Loopback SSH owned by NimoteCode |

The root [`manifest.json`](manifest.json) is authoritative for the runtime source URL, PRoot SHA-256, rootfs input metadata, minimum app version, and individual preset hashes. PRoot is process-root emulation, not a virtual machine: tools that depend on ptrace, special mounts, privileged networking, or exact `/proc` behaviour require target-runtime testing.

## Available presets

| ID | Purpose | Dependencies | Status |
| --- | --- | --- | --- |
| [`minimal`](presets/minimal/manifest.json) | Essential command-line development tools | None | Experimental |
| [`python`](presets/python/manifest.json) | Python 3, pip, and venv workflow | `minimal` | Experimental |
| [`web`](presets/web/manifest.json) | Node.js and npm from Ubuntu packages | `minimal` | Experimental |
| [`cpp`](presets/cpp/manifest.json) | GCC, CMake, GDB, and native build tooling | `minimal` | Experimental |

The status above is deliberately conservative. Container checks establish normal Ubuntu package behaviour; they do **not** prove PRoot compatibility. A preset can become stable only after the protected release process has fresh passing Android PRoot reports for both declared architectures and the manifest status is changed to `stable`.

## Manifest and SHA-256 verification

Every release file is covered by [`checksums.sha256`](checksums.sha256). The root manifest pins each preset manifest hash, and each preset manifest pins `install.sh` and `verify.sh` hashes. Validate before using a revision:

```bash
scripts/validate-manifests.sh
```

The validator checks JSON Schema conformance, root-to-preset hash declarations, script hashes, and the complete checksum file. Review the selected manifest for its supported architectures, Ubuntu version, dependencies, network requirement, and status before running an installer.

## Installation model

Installers run inside the user's Local Linux Ubuntu environment and request packages from the configured signed APT repositories at runtime. They do not download or embed a rootfs. Typical PRoot sessions expose UID 0 **inside the rootfs**; that is not Android root. Scripts do not invoke `sudo` and fail clearly when package installation cannot proceed.

`SSH`, `Git`, and the Ubuntu base are runtime foundations provided by Local Linux. Individual presets add their declared toolsets; they should not be treated as a generic operating-system installer.

## Testing status

Static checks cover strict shell mode, Bash syntax, ShellCheck, manifest schemas, checksum integrity, and shell policy. Ubuntu container CI installs and verifies each preset in a fresh Ubuntu 24.04 container. Android PRoot testing is separate because PRoot can affect process creation, `/proc`, symlinks, executable bits, networking, and native execution.

Run the static suite locally with Bash, ShellCheck, Python 3, and `jsonschema` available:

```bash
scripts/test-all.sh
```

For a matching PRoot runtime, set `NIMOTE_PROOT_BIN` and `NIMOTE_PROOT_ROOTFS`, then run a declared preset through `scripts/test-proot.sh PRESET`. See [Testing](docs/testing.md) and [Runtime compatibility](docs/runtime-compatibility.md). Do not download a large rootfs merely for this README; `scripts/fetch-runtime-bundle.sh --extract` accepts only an explicitly supplied, SHA-256-pinned maintainer runtime URL.

## Releases and downloads

Tagged releases are produced by the protected GitHub Actions release workflow. It requires passing Ubuntu checks, fresh Android PRoot reports for ARM64 and AMD64, `stable` status for every released preset, and an immutable `vMAJOR.MINOR.PATCH` tag. The workflow attaches a versioned preset bundle and SHA-256 sidecar to the GitHub Release.

This repository does not publish release assets through R2 and does not replace a previously published tag in place. See [Release process](docs/release-process.md) for the exact gate.

## Documentation

- [Architecture](docs/architecture.md) — Android, PRoot, Ubuntu, and SSH execution model.
- [Preset specification](docs/preset-spec.md) — manifest contract and installer rules.
- [Runtime compatibility](docs/runtime-compatibility.md) — current compatibility evidence and limits.
- [Testing](docs/testing.md) — static, container, and PRoot validation layers.
- [NimoteCode integration](docs/nimotecode-integration.md) — how the app consumes a preset safely.
- [Security policy](SECURITY.md) — vulnerability reporting and security boundary.

## Licence and source attribution

Repository-owned documentation, JSON metadata, and shell/Python snippets are licensed under [MIT](LICENSE). See [NOTICE](NOTICE) for the distribution boundary.

This repository does not redistribute Ubuntu packages, a PRoot executable, an Android executable, or a rootfs. Ubuntu packages are fetched from the user's configured APT repositories and retain their upstream licences. The manifest identifies the PRoot source as the [Termux PRoot source archive](https://github.com/termux/proot/archive/v5.1.107.92.zip) and pins its SHA-256; the PRoot project is GPL-licensed, but no PRoot source or binary is vendored here. Corresponding-source and licence notices for the NimoteCode-bundled Local Linux environment are published separately in [Local Linux Source and Licences](https://nimotecode.com/docs/local-linux-source).

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md), [Code of Conduct](CODE_OF_CONDUCT.md), [Support](SUPPORT.md), and [Security](SECURITY.md) before opening a change. Preserve the manifest/checksum contract, do not add rootfs or compressed runtime assets, and keep runtime claims backed by the documented test evidence.
