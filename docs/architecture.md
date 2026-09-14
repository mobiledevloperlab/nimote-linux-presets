# Architecture and compatibility audit (Phase 0)

This repository contains only shell presets for the NimoteCode Local Linux
Environment: Android -> PRoot -> minimal Ubuntu -> SSH. It deliberately does
not contain a PRoot binary, rootfs, Android binary, Android package path, or
NimoteCode source.

## Execution model

NimoteCode obtains a signed/released root manifest, selects a declared preset,
checks the downloaded script hash, displays the action, receives confirmation,
then runs `install.sh` and `verify.sh` over SSH inside the local Ubuntu
environment. Install state is owned by NimoteCode; presets do not modify it.

`apt-get` requires package-management permission inside Ubuntu. Typical
minimal PRoot sessions expose UID 0 *inside the rootfs*; that is not Android
root. The scripts never invoke `sudo` and must fail clearly if the current
Linux user cannot install missing packages.

## Audit findings and release policy

Docker/WSL and GitHub container runs exercise package availability and normal
Ubuntu behaviour only. They do not prove PRoot support because PRoot can
change ptrace, `/proc`, `/dev`, symlink, executable-bit, fork, and process
behaviour. The current revision has passed runtime verification for all Phase 1
presets on x86_64 PRoot and Android ARMv8 (aarch64) PRoot. They remain
`experimental` until a protected release workflow attaches fresh Android ARM64
PRoot reports and release approval is recorded. Only reports generated with
`scripts/test-proot.sh` can promote them to `stable`.

`gdb` may be installed but is not used as a PRoot success criterion: ptrace is
often restricted. The C/C++ verifier uses compile-and-execute only.
