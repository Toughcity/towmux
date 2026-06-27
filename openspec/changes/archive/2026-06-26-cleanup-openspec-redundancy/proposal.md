## Why

When the OpenSpec CLI was installed (`openspec init`), it took over the scaffolding workflow that `openspec/changes/_template/` and `openspec/README.md` were manually providing. These two artifacts now duplicate the tool's own functionality and documentation, creating maintenance overhead and potential confusion for contributors about which workflow to follow.

## What Changes

- Remove `openspec/changes/_template/` entirely — `/opsx:propose` generates all four change artifacts automatically
- Replace `openspec/README.md` with a minimal version that points to the OpenSpec tool rather than documenting a now-manual workflow

## Capabilities

### New Capabilities
- `lean-openspec-readme`: A concise README that orients contributors to the OpenSpec tool and the project's existing baseline, without duplicating upstream docs

### Modified Capabilities

## Impact

- `openspec/changes/_template/` (deleted — 4 files)
- `openspec/README.md` (rewritten — shorter, tool-aware)
- No code changes; documentation only
