# Preset audit — current repository state

Audit date: 2026-09-13
Audited revision: `6293a97` (`main`)
Scope: files tracked by this repository only. NimoteCode, PRoot binaries,
Android devices, rootfs images, release assets and GitHub Actions run history
are explicitly outside the checkout, so none of those are inferred.

> 2026-09-14 refresh: the current runtime authority is
> [runtime-compatibility.md](runtime-compatibility.md) and `manifest.json`.
> Their fixed Ubuntu Base 24.04.3 identities, rootfs hashes, glibc
> `2.39-0ubuntu8.8`, source-delivery verification, and both published
> architectures supersede older passages below referring to
> `ubuntu-24.04-*-1`, glibc `0ubuntu8.9`, `current/`, arm64-only release
> metadata, or removed NimoteCode evidence files. Those passages are retained
> only as historical audit context and are not release claims.

## 2026-09-13 cross-repository update

The initial audit above began from this repository alone. NimoteCode revision
`ed4f79549013519c70e048862e4276619668884d` was subsequently inspected as the
owner of the Android runtime. The concrete facts found there are now copied,
with source provenance and boundaries, into
[runtime-compatibility.md](runtime-compatibility.md). That document supersedes
the earlier use of `Unknown` for PRoot/rootfs/runtime identity in this audit.

Verified from NimoteCode source and retained evidence:

* Android Local Linux supports API 26+ 64-bit ARM64/aarch64 and x86_64/amd64
  processes; 32-bit processes are rejected.
* It ships Ubuntu 24.04 Noble ARM64 (`ubuntu-24.04-arm64-1`) and AMD64
  (`ubuntu-24.04-amd64-1`) images with fixed archive checksums, exact package
  inventories, glibc `2.39-0ubuntu8.9`, APT `2.8.3`, dpkg `1.22.6ubuntu6.6`,
  Bash and OpenSSH.
* It builds Termux PRoot `5.1.107.92` from a checksum-pinned source with NDK
  `28.2.13676358`, talloc `2.4.3`, documented patches, and the production
  `--link2symlink` command argument.
* A retained ARM64 Android 16/API 36 PKG110 acceptance and an Android 14
  x86_64-emulator smoke record prove the bundled runtime's core install, SSH,
  Git, APT and restart paths. They do **not** prove that this repository's four
  `install.sh`/`verify.sh` pairs ran in those environments.

Accordingly, statements below about missing rootfs/PRoot identity describe the
original preset release manifest rather than the current repository
documentation. The remaining release risks are direct preset-on-runtime test
evidence, special-filesystem coverage, public remote Git coverage and the
rebuildability of Canonical's `current/` base URL.

## A. Current status

This is a **script-only** preset repository, not a rootfs or PRoot distribution.
It has four preset manifests (`minimal`, `python`, `web`, `cpp`), all marked
`experimental`, all declaring Ubuntu 24.04 and `arm64` plus `amd64`. The root
manifest publishes only `arm64`, deliberately treating x86_64/amd64 as a
compatibility/CI target rather than an Android release target. Each preset has
a semantic version, dependency IDs, install/verify script hashes, and the
root release manifest plus all delivered scripts are protected by
`checksums.sha256`.

The checked-in scripts install packages through the current signed APT
configuration, use `set -euo pipefail`, reject non-root *inside Ubuntu*, run
`dpkg --configure -a`, preflight disk space, and use bounded APT retries and
connection timeouts. `minimal` declares/install checks `curl`, `wget`,
`ca-certificates`, `tar`, `xz-utils`, `zip`, `unzip`, `git`, `procps`,
`findutils`, `less`, `nano`, `jq`, `ripgrep`, and `file`; it does **not**
declare/install `openssh-client` or `openssh-server`. `python` adds Python,
pip, venv and development headers; `web` adds Ubuntu's `nodejs` and `npm`; and
`cpp` adds build-essential/GCC/G++/Make/CMake/GDB/pkg-config.

The following is an installer declaration audit, not an assertion about an
unidentified rootfs' contents:

| Tool/group requested for review | Current declaration/installation |
| --- | --- |
| bash, coreutils, gzip, grep, sed, awk | Assumed to come from the unspecified base rootfs; `awk` and `grep` are used by installers, but none is declared in a base-runtime contract |
| ca-certificates, curl, wget, tar, xz, zip/unzip, git, procps, findutils, less, nano | Installed by `minimal` (`xz-utils` supplies xz); nano is optional |
| openssh-client / openssh-server | Neither is declared or installed by a preset, despite product docs mentioning SSH outside this repository |
| build-essential, gcc, g++, make | Installed by `cpp`; appropriate as a developer preset, not base |
| Python/pip/venv/dev headers | Installed by `python`; language-specific |
| Node/npm | Installed by `web`; language-specific |

The runtime verifiers are deliberately small: they check tool availability,
execute a Python program and create a venv, execute a Node program, and
compile/execute a C program. The minimal verifier only prints versions of Git,
cURL, wget, jq and ripgrep. No preset currently represents Go, Java, Flutter,
Rust or an AI coding CLI; therefore no language- or AI-CLI-specific package or
test claim is applicable.

The repository documents a three-layer intent and includes an Android ARM64
self-hosted release job. `scripts/test-proot.sh` starts PRoot with `-0`, `-r`,
binds `/dev`, `/proc`, `/etc/resolv.conf`, and the repository, and sets `-w
/root`. It records only preset/version/`dpkg --print-architecture`, one shared
install/verify exit status, duration, and version output. It does **not** record
Android version/device/emulator, PRoot version/hash/source, rootfs identity,
filesystem subtests, network subtests, or the exact PRoot command/flags beyond
the test harness. The checked-out repository has no `test-results/*.json`
because those files are ignored, and it has no Git tag or release artifact.

### Evidence obtained in this audit

The following read-only/static checks were run at the audited revision:

| Check | Result | Boundary |
| --- | --- | --- |
| Manifest JSON Schema and declared SHA-256 validation | PASS | `scripts/validate-manifests.sh` |
| Bash syntax for all tracked `.sh` files | PASS | `bash -n` |
| Prohibited script policy (`curl | sh`, `sudo`, Termux/Android paths, `systemctl`) | PASS | `tests/shell/script-policy.sh` |
| Credential/private-key pattern scan of tracked files | No match | heuristic scan, not a secret-management guarantee |
| `scripts/test-all.sh` | NOT COMPLETED | stopped because `shellcheck` is not installed in this audit environment |
| Container integration, x86_64 PRoot, Android ARM64 PRoot | NOT RUN / no retained report | requires external rootfs/PRoot/device environment |

The README and `docs/testing.md` state that all four presets passed x86_64
PRoot and Android ARMv8/aarch64 PRoot. NimoteCode now supplies retained runtime
evidence and concrete identity for both targets, as summarized above. This
checkout still does not retain a matching **preset-script** report, so the
statement must not be translated into finer-grained preset PASS cells that the
current harness never tests.

## B. Missing necessary information

The cross-repository update and `runtime-compatibility.md` resolve the original
absence of Android/PRoot/rootfs identity in this repository's documentation.
The items below are the remaining gaps in the release manifest, direct preset
evidence, or long-term rebuild provenance.

### Runtime and platform

Now documented: API 26+ 64-bit ARM64/x86_64 support; Android 16/API 36 PKG110
and Android 14 x86_64 emulator evidence; Termux PRoot version/source/checksums,
build inputs and patches; production `--link2symlink` arguments; known PRoot
boundaries; and the initial `env -i` guest environment.

Still missing or incomplete:

* A broader Android device/API/OEM matrix. One ARM64 device and one x86_64
  emulator are evidence, not a compatibility range.
* A guest-environment assertion for login/non-login SSH shells, Agent, Task and
  Terminal. `SHELL`, `LC_ALL` and guest `TMPDIR` are deliberately not injected
  by the command builder and must be tested rather than assumed.
* Explicit expected-result tests for sockets, FIFOs, device files, ptrace,
  inotify, mmap and file locking. The documentation now scopes these as
  unclaimed rather than hiding them.

### Rootfs and reproducibility

The runtime record now identifies both rootfs artifacts, checksums, base-input
checksums, glibc, shells and APT/dpkg versions. It still has no explicit image
creation timestamp, and Canonical's base URL uses mutable `current/`; a future
rebuild needs an archived/datestamped upstream input. `supportedUbuntuVersions`
in a preset remains compatibility metadata, not a per-release rootfs binding.

APT package names are recorded only in shell code, not as manifest data, and
APT resolves the then-current repository versions. This has a legitimate
security-update trade-off, but it means package versions and package-index
snapshot are not reproducible six months later. There is no documented policy
that explicitly chooses rolling signed APT packages versus a dated snapshot/
lockfile.

### Preset manifest

Machine-readable manifests already exist, so a new parallel manifest format is
not needed. The root `runtime` block now carries PRoot/rootfs identity and
runtime `testedOn` metadata. It still lacks a package list/version policy and a
structured **per-preset** test-report reference. The root manifest's
`architecture: ["arm64"]` also needs a clear per-artifact explanation while
individual presets declare both `arm64` and `amd64`.

### Tests and verification

The current harness has no dedicated smoke/integration separation and has no
test matrix artifact keyed by architecture. It does not test:

* normal/hidden files, directories, executable permission, relative/absolute/
  broken symlinks, hardlinks, rename, atomic replacement, chmod, or timestamps;
* `--link2symlink` semantics or their effects on Git, dpkg/APT, Node, Python
  venv, Cargo, or native build tools;
* DNS/HTTP/HTTPS as distinct assertions; cURL transport; `git clone` over HTTPS
  or SSH; SSH client; SSH server startup, localhost access, or key auth;
* real Git workflow (`init`, commit, branch/switch, diff, symlink tracking) on
  either architecture;
* `apt install`, `apt remove`, `dpkg` operations or package post-install
  scripts as explicit assertions. Installers invoke some of these, but they do
  not assert outcomes beyond overall script success;
* `npm install`/`npm run`, pip package installation, or a Python venv package
  installation. C++ compile/execute is covered; no Go/Java/Rust/etc. preset
  exists to test.

The release workflow has a valuable ARM64 PRoot gate, but only on tag pushes,
only for ARM64, and it reduces every assertion to shared installer/verifier
status. The normal integration workflow is an Ubuntu container matrix, not
x86_64 PRoot. The release script requires `status: stable`, whereas every
current preset is `experimental`; therefore this exact revision cannot pass a
stable release gate by design.

### Documentation, lifecycle, licence

README does not provide the requested top-level compatibility matrix, Android
versions/devices, PRoot version, rootfs source/checksum, concrete test matrix,
known limitations, a custom-preset creation procedure, or an explicit
environment-variable contract. It does correctly state the NimoteCode Local
Linux relationship and points to installation verification documentation.

Install/update is mostly idempotent at the package-presence level and fails
with useful APT/disk errors. It has no transaction/rollback marker, so an APT
failure can leave ordinary partially installed packages; retry plus
`dpkg --configure -a` is the current recovery mechanism. Automatic uninstall
is intentionally absent because dependencies are shared, but README only says
to reset the entire Local Linux Environment. It does not give an explicit
per-preset removal policy or exact clean-up boundary.

MIT licensing for repository-owned files is explicit and `NOTICE` accurately
says no PRoot/rootfs/binaries are bundled. Since their concrete identities are
not declared, however, the repository cannot yet provide the requested PRoot,
rootfs, or bundled-binary licence/notices for an actual NimoteCode release.

## C. Risk

### Critical

No Critical defect was proven in the checked-in scripts: no credential material
was found by the audit scan; there is no `curl | sh`, `sudo`, Android-private
path, or bundled opaque binary in the checked-in preset scripts. This is not a
claim about excluded NimoteCode/PRoot/rootfs artifacts.

### High

* **Direct preset evidence is absent.** The runtime has ARM64/x86_64 acceptance
  evidence, but the release does not retain a run of each actual preset script
  on that runtime.
* **Rootfs rebuild source can drift.** Shipped rootfs checksums are fixed, but
  the Canonical base input is still addressed through `current/`; the exact
  source may not remain retrievable after six months.
* **Filesystem coverage remains incomplete.** PRoot link semantics have real
  ARM64 coverage, but the preset harness has no detailed file-operation matrix,
  x86_64 detail is weaker, and special-file APIs are explicitly unclaimed.
* **Public remote Git and transport coverage is incomplete.** Loopback SSH,
  DNS and signed APT update work in runtime evidence, but public HTTPS/SSH clone
  and direct cURL transport are not tested.

### Medium

* **Package composition drifts.** APT package versions are unpinned and absent
  from manifests; package post-install and removal are not explicit test cases.
* **Shell-context behaviour is partly unspecified.** Initial command values are
  fixed, but SSH login/non-login, Agent, Task and Terminal inheritance has no
  retained comparison matrix.
* **Install failure leaves ordinary APT partial state.** Retrying is supported,
  but state is not recorded and no scoped cleanup is described.
* **Release implementation mismatch.** Current `experimental` manifests cannot
  satisfy the stable release script, and the root only publishes arm64 despite
  each preset advertising amd64 compatibility; this is safe only if documented
  and enforced as an intentional release policy.

### Low

* README lacks a concise compatibility/test matrix and custom-preset guide.
* Default-shell, glibc and base-tool ownership are implicit in an unspecified
  minimal Ubuntu rootfs.
* This audit environment lacks ShellCheck, so the full static entry point could
  not be completed. README documents that prerequisite; this is not a
  repository defect, but a release run should retain its successful output.

## D. Recommended minimal changes

1. Add one concise `docs/runtime-compatibility.md` (or an equivalent top-level
   README table) owned jointly with NimoteCode. For each published architecture,
   record Android min/tested API versions and device/emulator, rootfs source
   URL/release/filename/SHA-256/glibc/date, and PRoot source/version/SHA-256.
   If self-built, include upstream ref, exact flags and patch list/hashes.
2. Add production PRoot arguments to that document. State explicitly whether
   `--link2symlink` is used. If it is, explain that hard-link requests may be
   represented as symlinks and publish compatibility results for Git, dpkg/APT,
   Node, Python venv and build tools. If it is not used, say so and test the
   actual flags instead.
3. The root manifest now has a small validated `runtime` block. Add only
   `packages` and a per-preset `testedOn` report reference next; do not create a
   second manifest system or a package-lock framework unless reproducible package
   versions are a product requirement. At minimum record an APT snapshot/date
   policy so rolling package resolution is intentional.
4. Make `test-proot.sh` invoke a small standalone filesystem smoke script and
   write a structured report per architecture. Test the listed file kinds and
   operations, including expected/unsupported results. Include PRoot command,
   version/hash, rootfs metadata, Android metadata, test-case outcomes and
   sanitized logs. Keep reports as release artifacts; do not commit
   machine-specific local reports.
5. Add explicit smoke assertions for DNS, HTTPS/cURL, APT update/install/remove
   plus a harmless package post-install, and a real local Git repository flow
   including a tracked symlink. Test HTTPS clone against a fixed public fixture
   or controlled test repository. Run SSH clone only where a non-secret test
   fixture is configured, report it as `SKIP (no fixture)` otherwise. If SSH
   server is product-supported, add its separate localhost/key-auth test;
   otherwise remove/qualify the SSH-server expectation in product docs.
6. Expand language verifiers only for existing presets: Python should install a
   harmless package into its venv; Web should execute `npm install` and `npm
   run`. Retain C++ compile/execute. Add tests for other ecosystems only when
   their preset is introduced.
7. Document the environment contract and which layer (NimoteCode versus preset)
   sets it. Do not hard-code Android paths in installers. State the intentional
   no-uninstall/shared-APT policy and the exact reset/cleanup owner.
8. Update README's first screen with compatibility, actual test-status and
   known-limitations tables, PRoot/rootfs identities, install/verify/reset
   commands, and a brief custom-preset path pointing to the manifest schema.

## E. Compatibility matrix

The table incorporates the subsequently recorded NimoteCode runtime facts. A
fixed rootfs archive checksum identifies the shipped image; it does not turn
Canonical's mutable `current/` base URL into a permanent rebuild source.

| Architecture | Distro | Distro version | Rootfs | PRoot version | Tested Android version | Status |
| --- | --- | --- | --- | --- | --- | --- |
| arm64 / aarch64 / ARMv8 | Ubuntu | 24.04 Noble | `ubuntu-24.04-arm64-1`, archive SHA-256 recorded in runtime compatibility record | Termux PRoot 5.1.107.92 | PKG110, Android 16 / API 36 | Runtime acceptance PASS; all four preset manifests remain experimental and lack a retained direct preset report |
| x86_64 / amd64 | Ubuntu | 24.04 Noble | `ubuntu-24.04-amd64-1`, archive SHA-256 recorded in runtime compatibility record | Termux PRoot 5.1.107.92 | Android 14 x86_64 emulator | Runtime smoke PASS; not a root-manifest Android release target, and no direct preset report is retained |

`manifest.json` itself still declares only `arm64`; each individual preset
manifest declares `arm64` and `amd64`. This remains a release-policy mismatch
to document or align. The base rootfs uses APT/dpkg as recorded above; later
package installation resolves against the user's signed APT configuration.

## F. Test matrix

`Runtime PASS` below is backed by NimoteCode's retained device/emulator evidence.
It is distinct from a `Preset PASS`: no retained report proves that the four
preset scripts themselves ran under either production runtime. `Not tested`
means no matching assertion exists in the checked-in preset harness or the
identified runtime evidence.

| Feature | arm64 / Android ARMv8 PRoot | x86_64 PRoot | Checked-in harness coverage |
| --- | --- | --- | --- |
| Boot/rootfs | Runtime PASS: offline install, fixed rootfs metadata | Runtime PASS: offline install, fixed rootfs metadata | preset harness itself has no boot assertion |
| Minimal tools | Runtime PASS: Bash/Git/SSH/APT verified | Runtime PASS: Bash/Git/SSH/APT verified | preset verifier remains presence/version only |
| APT update/install | Runtime PASS for update; language-package install also exercised in dedicated ARM64 QA | Runtime PASS for update | preset installer is an unreported side effect, not architecture evidence |
| APT remove/dpkg/postinstall | Not tested | Not tested | no explicit case |
| Regular file/directory/executable | Runtime PASS for file/SFTP/editor I/O | Runtime PASS for file/SFTP I/O | Python/Node/C++ verifiers only; no direct preset report |
| Symlink, hardlink, atomic rename, chmod, timestamps, hidden/broken/absolute/relative links | Symlink/hardlink and restart topology PASS; other rows remain incomplete | No retained fine-grained matrix | preset harness has no case |
| Git init/commit/branch/diff/symlink | Runtime PASS for init/add/commit; symlink handling has ARM64 device coverage | Runtime PASS for init/add/commit/status | preset verifier remains `git --version` only |
| Git HTTPS clone | Not tested | Not tested | no public remote fixture |
| Git SSH clone / SSH client | SSH client/runtime PASS; clone not tested | SSH client/runtime PASS; clone not tested | no preset case |
| SSH server/local key auth | Runtime PASS: loopback sshd, pinned key health | Runtime PASS: loopback SSH smoke | base runtime supplies OpenSSH; preset has no case |
| DNS/HTTP/HTTPS/cURL transport | DNS and signed APT update PASS; cURL transport not explicit | DNS and signed APT update PASS; cURL transport not explicit | no explicit preset request assertion |
| Python runtime and venv | ARM64 runtime QA PASS after opt-in APT install | Not tested | preset verifier creates venv but does not install a package |
| Node/npm runtime | ARM64 runtime QA PASS after opt-in APT install | Not tested | preset verifier has no `npm install`/`npm run` |
| C/C++ compile/execute | Not tested in production runtime evidence | Not tested | preset verifier compiles/executes C but has no direct report |
| Go/Java/Rust/Flutter | N/A: no preset | N/A: no preset | no preset/case |
| AI coding CLI | N/A: no preset declaration | N/A: no preset declaration | no CLI/token case |

The Ubuntu-container CI matrix is useful package/runtime integration coverage
for both GitHub-hosted runner architecture and a fresh Ubuntu 24.04 container,
but is not PRoot or Android coverage and must not fill the x86_64 PRoot column.

## G. Version manifest recommendation

Retain the existing JSON manifests. The smallest useful change is to add a
single referenced runtime record (one per published architecture) and a few
fields to the existing preset manifest. Values must be concrete, never
`latest`, `current` or `newest`.

Example shape (illustrative keys only; do not copy placeholder values into a
release):

```json
{
  "runtime": {
    "id": "ubuntu-24.04-arm64-YYYYMMDD",
    "distro": "ubuntu",
    "distroVersion": "24.04",
    "architecture": "arm64",
    "rootfs": {
      "source": "Ubuntu official rootfs",
      "upstreamUrl": "https://…/fixed-release-artifact",
      "release": "24.04.x",
      "filename": "fixed-name.tar.gz",
      "sha256": "<64 lowercase hex>",
      "glibc": "2.xx",
      "createdAt": "YYYY-MM-DD"
    },
    "proot": {
      "version": "x.y.z",
      "sourceUrl": "https://…",
      "upstreamRef": "tag-or-commit",
      "sha256": "<64 lowercase hex>",
      "buildFlags": ["only-if-self-built"],
      "patches": ["path-and-sha256-if-any"],
      "arguments": ["actual production arguments"]
    },
    "defaultShell": "/bin/bash",
    "packageManager": "apt",
    "testedOn": [{"android": "API-level/version", "kind": "device-or-emulator"}]
  },
  "packages": ["exact package names; package-version/snapshot policy documented"],
  "testedOn": ["runtime-id and release-report reference"]
}
```

If `--link2symlink` is used, make it an explicit `proot.arguments` value and
add a short `filesystemSemantics` note rather than hiding it in an application
command line. Keep actual test outcome records as versioned release artifacts,
with a report schema that includes each test case and `pass`/`fail`/`skip`.

## Final conclusion

**Public Beta quality: not yet for the preset bundle itself.** The runtime is
now concretely documented and has retained ARM64 and x86_64 acceptance evidence.
The remaining blocker is that no retained result runs each released preset's
actual installer and verifier through that exact runtime on both architectures;
the preset harness also omits several required feature-level assertions.

**NimoteCode formal integration: suitable for the existing experimental
presets.** Stable promotion should wait for architecture-specific direct preset
reports plus the remaining special-filesystem, public-remote Git and package
lifecycle coverage.

**Public GitHub publication: suitable as an explicitly experimental,
script-only repository.** It now carries a concrete runtime compatibility
record, but reproducible rootfs rebuilding still needs a retained dated
Canonical base input rather than only a mutable `current/` URL.

**Must fix before a stable/public-beta preset release:** (1) run and retain
metadata-rich reports for each preset on the exact ARM64 and x86_64 runtime;
(2) add the missing filesystem, public Git remote, package remove/postinstall
and network assertions; (3) resolve or explicitly scope the root-manifest
arm64-only versus preset-amd64 policy; and (4) retain a dated/archived Canonical
base artifact for future rootfs rebuilds.
