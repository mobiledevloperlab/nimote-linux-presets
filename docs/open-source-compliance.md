# Open-source compliance scope and review

## Repository review

The tracked tree reviewed for this change contains documentation, JSON,
installation/verification scripts and CI configuration, with an MIT license and
copyright notice at the root. No vendored third-party implementation, package
binary or rootfs archive was identified in that tree. This inspection does not
establish authorship of every historical contribution or audit external release
assets or the NimoteCode application.

A concrete distribution gap was identified: `scripts/package-release.sh` omitted
LICENSE and NOTICE from the preset archive. It now includes both without changing
preset contents, commands, versions or runtime behavior. MIT requires the copyright
and permission notices to accompany copies or substantial portions of the work.
Consumers copying individual scripts must also retain the applicable license and
copyright notice in their distribution; a URL alone is not a replacement for the
notice. NOTICE explains scope and does not impose additional license restrictions.

## External components

| Component | Relationship to this repository | Compliance evidence |
| --- | --- | --- |
| Repository-owned scripts, schemas and documentation | Distributed as source under MIT | Root LICENSE and NOTICE; included in generated preset bundles |
| Ubuntu APT packages | Requested at runtime; not shipped in preset bundles | Exact installed versions and each package's `/usr/share/doc/<package>/copyright` |
| Termux PRoot | Source URL and hash referenced in manifest; executable not shipped here | Actual distributor must review the license and corresponding source for its exact build |
| Ubuntu rootfs | Compatibility metadata only; image not shipped here | Actual distributor must inventory the image, licenses, modifications and corresponding source obligations |
| CI actions and development tools | Referenced or executed, not vendored in bundles | Upstream licenses govern those components; reassess if copying or redistributing them |

Direct APT requests currently include:

- minimal: curl, wget, ca-certificates, jq, unzip, zip, tar, xz-utils, less, nano,
  ripgrep, file, procps, findutils; git when absent.
- python: python3, python3-pip, python3-venv, python3-dev.
- web: nodejs, npm.
- cpp: build-essential, gcc, g++, make, cmake, gdb, pkg-config.

Python, web and cpp also depend on minimal. This list is not a complete bill of
materials: transitive dependencies and versions depend on the configured Ubuntu
repositories and the existing guest. Do not assign one blanket license to all
packages. For an actual image redistribution, record at least binary package
name/version/architecture, source package/version, upstream copyright/license
files, local patches and build information. `dpkg-query -W` and
`/usr/share/doc/*/copyright` are useful inputs, not proof of complete compliance.

Merely requesting packages for local use does not distribute those packages in
this repository. Redistributing an installed environment, cache, rootfs or binary
is a separate action requiring review of each applicable license. GPL-covered
binary distribution may require complete corresponding source, including relevant
modifications and build scripts, through a method permitted by the applicable GPL
version; a generic upstream homepage or an unverified source link is insufficient.
Other licenses may require attribution, license texts or additional notices.

## Remaining evidence outside this checkout

Before claiming application-wide compliance, its distributor must verify:

1. The actual shipped PRoot binary and rootfs inventory, exact sources, patches,
   build instructions, notices and applicable license versions.
2. That the published source delivery mechanism covers those exact distributed
   builds and meets the applicable licenses' access and retention requirements.
3. That application distributions include the required preset MIT notice and all
   applicable third-party license notices.
4. Historical contribution provenance where ownership or copying is uncertain,
   and older release archives for missing notices.

The existing Local Linux source documentation link is a pointer, not evidence
that these checks passed. This change does not supply or certify external source
archives, historical releases or application artifacts that were not inspected.
Future copied material must follow the provenance review in CONTRIBUTING.md.

## Authoritative references

- [MIT license text (Open Source Initiative)](https://opensource.org/license/mit)
- [GNU GPL FAQ: binary redistribution and corresponding source](https://www.gnu.org/licenses/gpl-faq.html#UnchangedJustBinary)
- [GNU GPL FAQ: aggregation](https://www.gnu.org/licenses/gpl-faq.html#MereAggregation)

These references explain license requirements; conclusions about this repository
are based on the tracked files and packaging script inspected above.
