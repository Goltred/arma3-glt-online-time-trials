# Third-Party Licenses and Attributions

This file tracks third-party code, scripts, assets, and tools used by GLT Online Operational Trials.

## How to use this file

- Add an entry whenever you import or adapt external work.
- Include source URL, author, license, and what was changed.
- Keep this file updated in the same PR/commit that adds the third-party content.

## Runtime dependencies (not bundled)

These are required at runtime but are not copied into this repository unless explicitly noted.

### Community Base Addons (CBA_A3)

- Project: CBA_A3
- Source: [https://github.com/CBATeam/CBA_A3](https://github.com/CBATeam/CBA_A3)
- License: GPL-2.0
- Usage here: runtime dependency (functionality/keybind framework), not vendored.

## Bohemia / Arma platform content

- Arma 3 game assets, trademarks, and platform content are owned by Bohemia Interactive.
- This repository does not claim ownership of Arma 3 base game assets.
- Distribution and usage of Arma content remain subject to Bohemia terms and licenses.

## Bundled third-party content

Use this table for external content that is actually included in this repository.

| Name | Type | Path(s) | Source | Author | License | Modified? | Notes |
|------|------|---------|--------|--------|---------|-----------|-------|
| _ExampleLib_ | SQF script | `addons/GLT_Core/...` | https://example.com | Example Author | MIT | Yes | Ported to project coding style |

> Remove the example row when real entries are added.

## Optional tools and build-time dependencies

List tools/scripts used only for development or build pipelines when relevant to redistribution.

| Tool | Purpose | Source | License | Notes |
|------|---------|--------|---------|-------|
| _Example Tool_ | Packaging | https://example.com | Apache-2.0 | Not distributed with release PBOs |

## Attribution notes

If a third-party license requires attribution text in release notes, Workshop description, or in-game credits, add the required text here verbatim.
