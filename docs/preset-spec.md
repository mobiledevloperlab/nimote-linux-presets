# Preset manifest specification

The root manifest is the trust entry point of a versioned release bundle. Each
item maps an ID to a relative preset manifest and the latter's SHA-256.
Relative paths are resolved only inside the selected, verified release bundle;
scripts never embed download URLs. `checksums.sha256` covers the root manifest
and every declared install/verify script.

The root `runtime` block identifies the minimum Android API, PRoot source/version
and arguments, checksum-pinned rootfs for each architecture, and recorded runtime
test environments. It is runtime composition metadata, not proof that an
individual preset has run there; `docs/runtime-compatibility.md` gives its
source-provenance and known-limitations context.

Each preset uses semantic `version`, a status (`stable`, `beta`,
`experimental`, or `deprecated`), supported Ubuntu/architecture lists, UI size
estimates, dependency IDs, scripts, script SHA-256 values, and network/restart
requirements. NimoteCode displays only `stable` by default; beta is an explicit
advanced-user choice. V1 supports install/update only, never automatic removal,
because APT dependencies are shared.

The schemas in `schemas/` are normative. A released version is immutable: any
content change needs a new semantic version and release tag.
