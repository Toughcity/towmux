## Context

The `openspec/` directory was bootstrapped manually before the OpenSpec CLI existed in this project. Two artifacts from that manual phase are now redundant:

- `openspec/changes/_template/` — four files (proposal.md, design.md, tasks.md, specs/example.md) that show contributors how to scaffold a change by hand. The CLI's `/opsx:propose` does this automatically.
- `openspec/README.md` — documents the manual GIVEN/WHEN/THEN workflow, change lifecycle, and template usage. Most of this is now covered by the OpenSpec tool's own upstream documentation.

The `openspec/changes/baseline/` content and `openspec/config.yaml` are correct and unchanged.

## Goals / Non-Goals

**Goals:**
- Remove the `_template/` directory so contributors aren't confused between the manual and CLI workflows
- Rewrite `openspec/README.md` to be a thin orientation doc: what's in this directory, how the OpenSpec CLI is used here, and where the baseline lives

**Non-Goals:**
- Changing any spec content in `baseline/`
- Changing `config.yaml`
- Modifying any code in the project

## Decisions

**Delete `_template/` rather than update it** — The template was only useful when changes were scaffolded by hand. With the CLI active, keeping it would suggest the manual workflow is still valid. Deletion is unambiguous.

**Rewrite README rather than delete it** — A README at `openspec/README.md` still has value: it orients a new contributor to the directory structure and explains that the project uses the OpenSpec CLI. It should be short (under 30 lines) and point outward to the tool's docs rather than duplicating them.

## Risks / Trade-offs

[The existing README is linked from the PR that introduced it] → Low risk — the PR is merged and the link exists in git history only; no external documentation points to this file.

[A contributor may have bookmarked `_template/`] → Negligible — the template was only in the repo for a short time and the CLI is the documented path going forward.
