# NimoteCode Local Linux runtime compatibility

This document records the Android Local Linux runtime on which these presets are
intended to run. The runtime is built and released by NimoteCode, not by this
script-only repository.

Source snapshot: NimoteCode `3b0a37292`, revalidated by the 2026-09-14 Local
Linux GPL/OSS second audit. The authoritative build inputs are
`android/proot/runtime.lock.json`, `android/proot/build-runtime.py`, and
`android/local_linux/assets/local_linux/manifest*.json` in that repository.
Update this document and preset test evidence whenever those inputs change.

## Supported runtime

| Item | arm64 / aarch64 / ARMv8 | x86_64 / amd64 |
| --- | --- | --- |
| Android process requirement | API 26+, 64-bit ARM64 process | API 26+, 64-bit x86_64 process |
| Ubuntu | 24.04 Noble | 24.04 Noble |
| Rootfs version | `ubuntu-base-24.04.3-arm64-20260905` | `ubuntu-base-24.04.3-amd64-20260905` |
| Bundled archive | `ubuntu-minimal-arm64.tgz` | `ubuntu-minimal-amd64.tgz` |
| Archive SHA-256 | `8bdb7c5991831f8999ef83f3777dcea6b338dc3d83d48e3bad898da660b437ee` | `13037cdfcc700f2f7d42fecb772b5477dbf0ef7d50604186904041c2ec93c246` |
| Compressed / extracted bytes | 53,455,740 / 182,626,622 | 56,171,813 / 161,502,189 |
| Canonical base input | `ubuntu-base-24.04.3-base-arm64.tar.gz`, SHA-256 `7b2dced6dd56ad5e4a813fa25c8de307b655fdabc6ea9213175a92c48dabb048` | `ubuntu-base-24.04.3-base-amd64.tar.gz`, SHA-256 `6bc2cde3930ad088b3bb46fa45279e96d25bc3810f209850ecbe4722711874f9` |
| glibc | `2.39-0ubuntu8.8` | `2.39-0ubuntu8.8` |
| Default shells | `/bin/sh`, `/bin/bash` | `/bin/sh`, `/bin/bash` |
| Package manager | APT `2.8.3`, dpkg `1.22.6ubuntu6.6` | APT `2.8.3`, dpkg `1.22.6ubuntu6.6` |

The bundled archive is the reproducible runtime payload: NimoteCode verifies its
SHA-256 and size before extraction, prepares it in staging, and atomically
commits the installation. The base URLs are fixed-version Ubuntu Base 24.04.3
artifacts; dated Ubuntu snapshot provenance, package inventories and matching
corresponding source are verified by the second audit.

## PRoot

NimoteCode builds Termux PRoot `5.1.107.92` from
`https://github.com/termux/proot/archive/v5.1.107.92.zip` (SHA-256
`29385d1ddb619a9c4449ab512bfd55032034b22f724ddf98fc95ff300ea32135`) with
NDK `28.2.13676358` and talloc `2.4.3` (SHA-256
`dc46c40b9f46bb34dd97fe41f548b0e8b247b77a918576733c528e83abd854dd`). It
builds independent ARM64 and x86_64 executables.

The build applies fail-closed source-context patches for the missing `string.h`
declaration, SIGTERM tracee teardown, `PTRACE_O_EXITKILL`, 16 KiB ELF alignment,
NDK `llvm-readelf`, and Android x86_64 `rename`/`unlink` translation to
`renameat`/`unlinkat`. The exact patch text and compile invocation are in
NimoteCode `android/proot/build-runtime.py`; the Android package includes the
corresponding source and inputs in `assets/licenses/proot-corresponding-source.tgz`.

The recorded build uses the matching NDK `<triple>-linux-android24-clang`,
`-O2 -ffile-prefix-map=<abi-build>=/source`, `-fPIC` for talloc, and PRoot
`CPPFLAGS` `-D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -DARG_MAX=131072` plus its
version/include definitions. It invokes Make with `GIT=false`,
`PROOT_UNBUNDLE_LOADER=/nonexistent`, an NDK toolchain/strip/readelf set, and
links `-ltalloc -Wl,-z,noexecstack,-z,max-page-size=16384`. The launcher is PIE
with the same 16 KiB page-size alignment. These are build facts, not suggested
generic flags; change them only by updating the pinned NimoteCode build recipe.

Production commands use:

```text
--kill-on-exit --link2symlink -0 -r <rootfs> -b /dev -b /proc -w <cwd>
```

The launcher sets `PROOT_LOADER`, `PROOT_TMP_DIR`, `TMPDIR`,
`PROOT_NO_SECCOMP=1`, and, for the central-storage layout, `PROOT_L2S_DIR`. No
`/sys`, external storage, or other app-private directory is bound.

`--link2symlink` is intentional. Hard-link operations can have a
PRoot-managed backing/link representation rather than portable host hard-link
semantics. Rootfs packaging uses GNU tar `--hard-dereference`, and the Android
extractor materializes archive hardlinks by copying; guest symlinks remain
confined to the guest. Do not treat inode/link-count behaviour as native Linux
behaviour without a specific test. Device acceptance covers guest-created
symlink/hardlink aliases, restart topology preservation, SFTP/editor operations
and Git-related link handling.

PRoot is a compatibility layer, not a security sandbox; guest code runs with the
app's Android UID. ptrace/seccomp behaviour is Android-specific. No blanket
claim is made for FIFOs, device files, inotify, mmap, sockets or file locking
beyond the tested SSH/process cases, nor for arbitrary concurrency or
crash/power-loss atomicity.

## Initial environment and base tools

PRoot starts guest commands through `env -i` with:

```text
HOME=/root
USER=root
LOGNAME=root
TERM=xterm-256color
LANG=C.UTF-8
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

`SHELL`, `LC_ALL`, and a guest `TMPDIR` are not injected by this command builder.
Login/non-login shell customisation is owned by OpenSSH and the user; preset
scripts must work with the explicit base environment and avoid Android paths.

The exact base inventory lives in NimoteCode `packages.tsv` and
`packages-amd64.tsv`. It includes Bash, coreutils, ca-certificates, Git,
OpenSSH client/server, procps, findutils, grep, sed, awk, tar and gzip. Key
recorded versions are Bash `5.2.21-2ubuntu4`, coreutils `9.4-3ubuntu6.3`, Git
`1:2.43.0-1ubuntu7.3`, OpenSSH `1:9.6p1-3ubuntu13.19`, and ca-certificates
`20260601~24.04.1`. Node, Python, GCC/Clang, Java, Go, Rust, Flutter, Docker
and external AI CLIs are intentionally not preinstalled.

## Network, SSH, lifecycle and licensing

Initial installation is offline. At startup NimoteCode writes resolver data from
the active Android network (falling back to `1.1.1.1` and `8.8.8.8`); later APT
uses signed Ubuntu repositories and the bundled CA store. Android requires APT's
sandbox user to be `root`.

OpenSSH is bundled. Each installation creates fresh Ed25519 user and host keys,
listens only on `127.0.0.1` at a selected port in `22000–22999`, disables
password/PAM authentication, uses public-key authentication and strict host-key
pinning, and verifies `NIMOTE_LINUX_OK` before opening the workspace. Keys are
app-private and backup-excluded; no credential belongs in a preset.

NimoteCode owns install/start/stop/delete. It uses staging and atomic commit;
failed staging is removed. Delete/reset is explicit and removes the environment,
keys and runtime logs. Presets own only shared APT changes, so they are
install/update-only and reset is the safe complete cleanup boundary.

The Android distribution provides PRoot GPL-2.0-or-later and talloc
LGPL-3.0-or-later notices/corresponding source, plus Ubuntu package notices and
inventories. This repository contains no such binaries or rootfs and remains
MIT-licensed; see `NOTICE` for that boundary.

## Current release evidence

The 2026-09-14 second audit verified both final APK ABI payloads, rootfs hashes,
inventories, notices, PRoot/talloc corresponding source, fixed base provenance,
and the external versioned Ubuntu corresponding-source release. It is a release
compliance check, not a fresh device acceptance run of the four presets.

Before promoting a preset from `experimental`, run its `install.sh` and
`verify.sh` through the matching NimoteCode runtime and attach a sanitized,
architecture-specific report to the preset release.
