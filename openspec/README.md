# openspec

This directory contains the behavioural specification for towmux. It is the source of truth for what the project is supposed to do — independent of any particular implementation.

Specs are written before code is changed. A passing implementation is one that satisfies all specs in the relevant change.

---

## Directory structure

```
openspec/
├── README.md              ← you are here
├── config.yaml            ← project-level metadata (name, tool, tech stack)
└── changes/
    ├── baseline/          ← snapshot of the as-built state when specs were introduced
    │   ├── proposal.md    ← problem statement and scope
    │   ├── design.md      ← architecture and key decisions
    │   ├── tasks.md       ← completed work and known gaps
    │   └── specs/         ← one file per component
    │       ├── tp.md
    │       ├── trun.md
    │       └── ...
    └── <change-slug>/     ← one directory per proposed change (see below)
        ├── proposal.md
        ├── design.md
        ├── tasks.md
        └── specs/
```

A **change** is any unit of planned work — a new feature, a bug fix, a refactor, or an improvement. Each change lives in its own subdirectory under `changes/` and follows the same four-file structure.

---

## How to read specs

Specs use GIVEN/WHEN/THEN format:

```
## S-<COMPONENT>-<NN>: short title

GIVEN <precondition>
WHEN <trigger>      ← optional; omit if the condition alone is sufficient
THEN <observable outcome>
AND <additional outcome>
```

Each spec is independently testable. A reader should be able to verify a spec without reading any other spec in the file.

Spec IDs are stable — once assigned, they don't change even if the spec is updated. This lets PRs and issues reference them unambiguously (`S-TP-04`, `S-CFGSYNC-05`, etc.).

---

## How to propose a change

1. Copy `changes/_template/` to `changes/<your-slug>/`
2. Fill in `proposal.md` — the problem, the proposed solution, and what is explicitly out of scope
3. Open a PR with just the proposal; get alignment before writing design or specs
4. Once the proposal is approved, fill in `design.md` and `specs/`
5. Implement the change; update `tasks.md` as each item is completed
6. When fully shipped, mark the proposal `status: shipped` in `proposal.md`

The `baseline/` directory is a permanent snapshot and is never modified. Shipped changes stand on their own.

---

## Spec lifecycle

```
proposal → design → specs → implementation → shipped
```

- **proposal**: problem is defined, scope is agreed
- **design**: architecture decisions are locked; implementation can begin
- **specs**: behavioural contracts are written; these drive implementation and review
- **implementation**: code is written to satisfy the specs
- **shipped**: change is merged; `proposal.md` status updated to `shipped`

A spec that cannot be verified against the implementation is a bug in either the spec or the code.

---

## config.yaml

`config.yaml` captures project-level metadata used by tooling and AI assistants:

```yaml
project:        the repo name
description:    one-paragraph summary of what the project does
tool:           the AI coding tool used (claude-code, cursor, etc.)
source_of_truth: the design doc that is authoritative for architecture questions
tech_stack:     list of languages / runtimes
conventions:    invariants that apply to all specs and all code
```
