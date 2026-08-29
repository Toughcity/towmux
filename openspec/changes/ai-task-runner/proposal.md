## Why

Running and debugging a project from inside towmux today means dropping to a shell and remembering `trun`, while neovim's installed `overseer.nvim` runs a parallel, disconnected task system and there is no in-editor debugging at all. Developers coming from VSCode/Zed expect one keystroke to surface "what can I run/debug here?", a guided way to create those tasks when none exist, and breakpoint debugging in the editor. This change unifies on overseer + nvim-dap, makes task/debug definitions AI-authorable, and retires the bespoke `.trun` mechanism.

## What Changes

- Add a single neovim keymap (`<leader>r?`, in-editor) that opens a unified picker listing both **run** entries (from overseer / `.vscode/tasks.json`) and **debug** entries (from `.vscode/launch.json`).
- Picker run semantics: selecting a run entry that is **not** currently running starts it; selecting one that **is** running restarts it (kill + rerun). Each task keeps its own overseer terminal buffer, toggled via the existing `<leader>rt`.
- Picker debug semantics: selecting a debug entry launches nvim-dap so breakpoints set in the editor are honored.
- Empty-state flow: when a project has no run/debug tasks, the picker offers "create one", prompts the user for what they need in natural language, and sends that prompt (plus skill instructions) to the project's `ai` tmux window so Claude authors the task. Claude writes the config file directly and reports the file path back to the user.
- Add a Claude skill that encodes per-tech-stack knowledge: detect the stack, surface tasks already declared in manifests (npm scripts, `*.csproj`/`*.sln`, `go.mod`, `Makefile`, `Cargo.toml`), pick concise task names, and emit `.vscode/tasks.json` for run tasks or `.vscode/launch.json` (correct adapter `type` per language) when the request is about debugging.
- Add the LazyVim DAP stack (`nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap`) and document the per-language debug adapters installed via Mason (`netcoredbg`, `delve`, `debugpy`, `codelldb`, `js-debug`).
- **BREAKING**: `.trun` files and the `trun` shell command are retired in favor of `.vscode/tasks.json` consumed by overseer. (Migration: existing `.trun` configs are re-expressed as `tasks.json` entries.)

## Capabilities

### New Capabilities
- `run-task-picker`: in-editor unified picker over run + debug entries, with start/restart semantics and dap launch.
- `ai-task-authoring`: empty-state handoff that turns a natural-language request into a generated task/launch config via the project `ai` pane.
- `task-runner-skill`: the Claude skill encoding tech-stack detection and VSCode-format task/launch generation, including run-vs-debug intent detection.

### Modified Capabilities
<!-- None in main specs yet; trun exists only as an unsynced baseline delta and is retired here, not modified. -->

## Impact

- **neovim config** (`nvim/.config/nvim/lua/plugins/`): extend `overseer.lua`, add DAP plugin spec(s); new keymap in `lua/config/keymaps.lua`; picker built on installed `snacks.nvim`.
- **tmux/zsh**: empty-state handoff uses `tmux send-keys` to the session `ai` window; `trun` script (`zsh/.local/bin/trun`) and `.trun` references in `zsh/towmux.zsh`, `README.md`, `install.sh`/`uninstall.sh` removed or redirected.
- **Claude skills** (`.claude/skills/`): new `task-runner-skill`.
- **Dependencies**: Mason-managed debug adapters; LazyVim DAP extra.
- **Docs**: `CHEATSHEET.md` / `README.md` updated; supersedes the baseline `trun` spec when baseline is synced.
