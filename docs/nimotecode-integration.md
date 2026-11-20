# NimoteCode preset integration contract

The public, MIT-licensed `mobiledevloperlab/nimote-linux-presets` repository owns
installation and verification recipes. Contributors follow its `CONTRIBUTING.md`;
contributing a preset does not require access to NimoteCode source. A merged PR
becomes available in the app only after maintainers review and adopt its revision.

## Implemented transport and trust

NimoteCode currently downloads individual files from a pinned Git commit, **not**
the release tarball. `LinuxPresetDownloads.revision` and `manifestHash` are the
trust anchors shipped with the application. Every preset manifest is hashed by
the verified root manifest; every script is hashed by its verified preset manifest.
LICENSE and NOTICE have separate application-pinned hashes. Downloads use fixed
HTTPS paths, reject redirects, and limit each file to 256 KiB. Cache reads recheck
hashes. Changing a moving branch or publishing an adjacent checksum cannot update
the application's trust anchors.

Release tarballs remain repository distribution artifacts. Consuming them in the
app requires a separately reviewed implementation of archive validation and a
trusted release channel; downloading a tarball plus its adjacent hash alone is
not a substitute for the current trust anchors.

## V1 consumer interface

The schemas in the presets repository remain normative for producer validation.
The Android consumer implements this subset and rejects incompatible requests
before shell execution:

| Area | Consumer behavior |
| --- | --- |
| Root | `schemaVersion == 1`, `distro == ubuntu`, matching architecture, semantic `minimumNimoteVersion` no newer than the installed application |
| IDs and paths | Unique IDs matching `[a-z0-9-]+`; exact `presets/<id>/manifest.json`, `install.sh`, `verify.sh`; no caller-provided URLs or commands |
| Runtime | Ubuntu 24.04; `arm64` or `amd64`; preset must declare the current architecture and Ubuntu version |
| Lifecycle | `stable` and `experimental` accepted; existing app warning identifies experimental availability; beta/deprecated entries are hidden, direct execution rejected; no beta opt-in yet |
| Restart | `requiresRestart: true` entries are hidden and execution rejected; restart orchestration is not implemented |
| Dependencies | Manifest-declared IDs, resolved transitively in dependency order, deduplicated; missing dependencies and cycles reject the operation |
| Scripts | Non-interactive Bash; installers are idempotent; installation explicitly runs verification for each dependency and the requested preset |
| Result | Zero exit required; any failure clears readiness for the attempted dependency graph; success records each preset version; UI compares recorded and catalog versions |
| Presentation | `name`, `description`, sizes, dependency IDs, version and status are supplied over the existing method channel; built-in names retain their translations |
| Examples | Only `minimal`, `python`, `web` have app-owned example generators; other toolkits expose install/check without a fabricated example |
| C/C++ | `cpp` remains explicitly gated pending Android device acceptance; installing GCC is distinct from IDE debugger integration |

A malformed trusted manifest fails catalog loading. An otherwise eligible preset
whose dependency is incompatible also fails graph validation. Package readiness
records describe the last successful check, not continuous health monitoring.

The method channel keeps `toolsCatalog`, `toolsStatus`, and `runTools(id, action)`
with actions `install`, `verify`, `example`. Unknown or undeclared IDs cannot run.
Catalog entries include `id`, `name`, `description`, `dependencies`, `hasExample`,
`version`, `status`, `download`, `installedSize`; status includes `phase`, `id`,
`action`, bounded `output`, `installed` (ID to version), and runtime `busy`.

## Script execution environment

Execution uses the existing local SSH transport in the managed Linux guest.
Scripts receive a fixed system PATH prefixed with `/opt/nimote-search`, `umask 077`,
and `NIMOTE_VERIFY_DIR` inside a fresh temporary directory. Keep install and verify
self-contained except for their verified sibling script: no undeclared files are
staged. Verification must use and clean its own temporary files without deleting
user projects. Existing fixed `/tmp/nimote-test-*` assignments have a narrow
compatibility adapter; new scripts should honor `NIMOTE_VERIFY_DIR` directly.
The minimal installer also has an adapter for NimoteCode's managed ripgrep.

No automatic removal or rollback of shared APT packages is supported. The UI
requires confirmation and serializes work with environment lifecycle operations;
closing the page does not cancel APT. Android process loss yields interrupted
state. No guarantee of indefinite background execution is made.

## Contributor and maintainer workflow

1. Add `presets/<id>/manifest.json`, `install.sh`, `verify.sh`; use existing schema
   fields, explicit dependencies, supported runtimes and realistic size estimates.
2. Follow upstream contribution, security and release rules: semantic versions,
   regenerate checksums, static schema/hash/shell checks, clean Ubuntu tests,
   then matching ARM64 and AMD64 PRoot reports before claiming stable support.
3. Open a PR in the presets repository describing packages, network/disk impact,
   reproducible tests and known runtime limitations. New capabilities start with
   an honest experimental status when device evidence is incomplete.
4. Maintainers review scripts, dependency closure and runtime compatibility,
   then update the app's pinned revision/root hash (and notice hashes if changed).
   No additional hardcoded ID or custom page is needed for an eligible V1 toolkit.
5. Run native consumer tests and Flutter tests, then Android device acceptance.
   Test install twice, verify failure, offline cache, interruption/relaunch,
   both architectures, and interaction with existing projects and shared packages.

A repository contribution alone cannot add IDE UI, language-server discovery,
DAP debugger registration, tasks, persistent services, ports, arbitrary example
commands, new distros/architectures or runtime upgrades. Propose these interfaces
jointly before adding new manifest fields; the current schema rejects unknown
fields. Installing a CLI makes it available in the guest terminal, but does not
prove IDE features or kernel-dependent services work under PRoot.

## Validation and remaining limits

`LinuxDevelopmentToolsTest` covers dynamic IDs, graph ordering, missing/cyclic
dependencies, minimum application version, integrity/cache behavior, explicit
post-install verification, persisted readiness, and interruption. Set
`NIMOTE_PRESET_REPOSITORY` to a local presets checkout to exercise the pinned
snapshot through `git show` without network. `NIMOTE_PRESET_ONLINE_TEST=1` opts
into the separate real download test.

Flutter tests cover manifest-driven toolkit content, version changes, optional
examples, confirmation, busy state, six locales, both themes and large text.
These tests validate consumer behavior and shell syntax; they do not install
packages or replace real Android/PRoot acceptance reports.
