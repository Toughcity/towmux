# openspec

Spec-driven development for towmux, powered by the [OpenSpec CLI](https://github.com/Fission-AI/openspec).

## Directory structure

```
openspec/
├── config.yaml              ← project metadata (name, tool, tech stack, conventions)
└── changes/
    ├── baseline/            ← as-built snapshot when specs were introduced
    │   ├── proposal.md      ← problem statement and project scope
    │   ├── design.md        ← architecture and key decisions (authoritative)
    │   ├── tasks.md         ← completed work and known tech debt
    │   └── specs/           ← behavioural specs for all components
    └── <change-slug>/       ← one directory per proposed or active change
```

## Workflow

Use the OpenSpec CLI slash commands in Claude Code:

| Command | When to use |
|---------|-------------|
| `/opsx:explore "idea"` | Think through something before committing to a proposal |
| `/opsx:propose "what you want"` | Generate proposal, design, specs, and tasks in one step |
| `/opsx:apply` | Implement the tasks for the active change |
| `/opsx:archive` | Finalize and archive a shipped change |

## The baseline

`changes/baseline/` is a permanent snapshot of towmux as it existed when specs were introduced. It is never modified. Future changes stand alongside it in their own `changes/<slug>/` directories.
