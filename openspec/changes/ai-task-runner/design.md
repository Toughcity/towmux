## Context

towmux is a tmux + neovim + zsh "IDE-in-a-terminal". Today it has two disconnected task systems: the `trun` shell command (reads a per-project `.trun` file, runs each config in a stable tmux window) and a vanilla `overseer.nvim` install (auto-detects npm/make/cargo, runs tasks in editor buffers) — neither knows about the other, and there is no in-editor debugging. The user wants a single VSCode/Zed-like flow: one keystroke surfaces what's runnable/debuggable, restarting if already running, with breakpoint debugging in neovim, and an AI-assisted path to author tasks when none exist.

Key enabling facts (verified against upstream docs):
- overseer.nvim natively reads `.vscode/tasks.json` — VS Code tasks appear in `:OverseerRun` with no extra config.
- nvim-dap natively reads `.vscode/launch.json` (loaded on `dap.continue()` / `:DapNew`).
- The project already has `overseer.nvim` and `snacks.nvim` (picker) installed; the session already has an `ai` tmux window per project.

## Goals / Non-Goals

**Goals:**
- One in-editor keymap that lists run + debug entries in a single picker.
- Run entries start if idle, restart if already running; each task keeps its own overseer buffer.
- Debug entries launch nvim-dap honoring editor breakpoints.
- Empty-state hands a natural-language request to the `ai` pane; Claude authors the config file and reports its path.
- A Claude skill encoding per-stack task/launch generation, including run-vs-debug intent detection.

**Non-Goals:**
- Spilling task output into dedicated tmux panes/windows (overseer's in-editor buffers are the chosen output surface).
- Auto-refreshing the picker after AI authoring (user re-triggers `<leader>r?` manually).
- 100% VSCode tasks.json/launch.json feature parity (overseer/dap coverage is sufficient).
- Auto-installing debug adapters at runtime (handled once via Mason).

## Decisions

### `.vscode/tasks.json` + `.vscode/launch.json` as the single source of truth
Both overseer and nvim-dap consume these natively, the format is what the user already knows from VSCode/Zed, files are project-local and portable to teammates, and they give Claude a documented schema plus a concrete file path to report back. **Alternatives considered:** keep `.trun` (rejected — bespoke, not debug-capable, duplicates overseer); overseer Lua templates in the nvim config (rejected — global not per-project, no file for Claude to hand back).

### Retire `trun` / `.trun`
With overseer reading `tasks.json`, `trun` is redundant. Keeping both would re-create the two-systems problem this change exists to fix. The `trun` script and `.trun` references are removed; existing `.trun` configs migrate to `tasks.json` entries. This is the **BREAKING** part of the change.

### Unified picker built on snacks.nvim
A single picker merges overseer's available templates/tasks (tagged `[run]`) with dap configurations (tagged `[debug]`). Matches the user's "command-palette" mental model and avoids a forgotten second keymap. **Alternative:** separate `<leader>r` / `<leader>d` per LazyVim convention (rejected — user explicitly wants one list).

### Start-or-restart via overseer task lookup
On selecting a run entry, query `overseer.list_tasks({ name = ... })`; if a live task exists, restart it; otherwise create + start. Gives the "run == re-run" behavior without duplicate processes. Debug entries delegate to `dap.run` / the loaded launch config.

### AI handoff via `tmux send-keys` to the `ai` window
The empty-state captures free text and sends it, prefixed with skill-invoking instructions, to `session:ai`. The pane already runs Claude, which has file-write ability, so it authors `.vscode/*.json` directly and prints the path. **Alternative:** Claude prints config for the user to paste (rejected — clunkier; direct write is the stated preference).

### Skill owns the stack knowledge
A `task-runner-skill` Claude skill maps stack → commands and adapter types, prefers surfacing declared scripts over inventing, and routes run-vs-debug requests to `tasks.json` vs `launch.json`. Keeping this in a skill (not nvim Lua) means the intelligence lives where Claude runs.

## Risks / Trade-offs

- **Debug doubles the surface area** → phased within one change: run path first (overseer, nearly free), then DAP plugins + Mason adapters. Adapters (`netcoredbg`, `delve`, `debugpy`, `codelldb`, `js-debug`) are a per-language install dependency documented in the cheatsheet.
- **Breaking removal of `trun`** → provide a migration note and a `.trun` → `tasks.json` mapping in docs; the baseline `trun` spec is superseded when baseline syncs.
- **send-keys handoff is fragile if the `ai` window is absent or not running Claude** → detect a missing `ai` window and report instead of mis-targeting; document that the flow assumes Claude in the `ai` pane.
- **Generated JSON could be invalid** → skill must emit schema-valid output; treat overseer-lists-it / dap-loads-it as the acceptance check.
- **overseer ≠ 100% VSCode parity** → keep generated tasks within supported types (process/shell, problem matchers, compound).

## Migration Plan

1. Add DAP plugin spec + document Mason adapters; extend overseer config; add the unified picker keymap and empty-state handoff.
2. Add the `task-runner-skill`.
3. Remove `trun` script and `.trun` references; update `CHEATSHEET.md` / `README.md` with the new flow and a `.trun` → `tasks.json` migration example.
4. Rollback: re-enabling is additive (DAP/picker can be disabled by reverting the plugin/keymap commits); restoring `trun` means reverting its removal commit.

## Open Questions

- Exact `<leader>r?` LHS — confirm it doesn't collide with existing overseer `<leader>r{r,t,l}` bindings (likely fine; `?` is free).
- Which languages ship adapters in the first pass vs. documented-but-not-preinstalled.
