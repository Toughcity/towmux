## 1. Debug stack (nvim-dap)

- [x] 1.1 Add LazyVim DAP plugin spec(s) (`nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap`) under `nvim/.config/nvim/lua/plugins/`
- [x] 1.2 Configure Mason to install the per-language debug adapters (`netcoredbg`, `delve`, `debugpy`, `codelldb`, `js-debug`)
- [ ] 1.3 Confirm nvim-dap auto-loads `.vscode/launch.json` and breakpoints are hit for one stack (e.g. dotnet) — *launch.json configs verified listing live via getconfigs; hitting a live breakpoint still needs a real debug target*

## 2. Run task source (overseer + tasks.json)

- [x] 2.1 Verify overseer lists `.vscode/tasks.json` entries via `:OverseerRun` in a sample project — *verified: template.list returned the tasks.json entries*
- [x] 2.2 Extend `overseer.lua` config as needed so tasks.json tasks are discoverable by the picker — *default vscode provider suffices; picker uses overseer.template.list*
- [x] 2.3 Implement start-or-restart helper: look up live task by name, restart if running else create+start

## 3. Unified picker

- [x] 3.1 Build a snacks.nvim picker that merges run entries (overseer/tasks.json) tagged `[run]` and debug entries (launch.json) tagged `[debug]`
- [x] 3.2 Wire run selection to the start-or-restart helper; wire debug selection to nvim-dap launch
- [x] 3.3 Bind the picker to `<leader>r?` (placed in `overseer.lua` keys rather than `keymaps.lua` so loading the key pulls in overseer; verified no collision with `<leader>r{r,t,l}`)
- [x] 3.4 Show running state in the picker so a running task is visibly restartable

## 4. Empty-state AI handoff

- [x] 4.1 Detect the no-tasks condition (no tasks.json, no launch.json, no overseer-detectable templates) and show a "create one" option
- [x] 4.2 Prompt for a free-text task description (cancel = no-op)
- [x] 4.3 Resolve the session `ai` window; report and abort if absent
- [x] 4.4 Send the description + skill-invoking instructions to `session:ai` via `tmux send-keys` and focus that window

## 5. Task-runner skill

- [x] 5.1 Create `.claude/skills/task-runner-skill/SKILL.md` with stack detection (package.json, *.csproj/*.sln, go.mod, Cargo.toml, Makefile)
- [x] 5.2 Encode run-vs-debug intent detection and the per-stack adapter `type` mapping for launch.json
- [x] 5.3 Specify "surface declared scripts first, invent only for gaps" and concise task-naming guidance
- [x] 5.4 Require valid VSCode-format output and reporting the written file path back to the user

## 6. Retire trun and document

- [x] 6.1 Remove `zsh/.local/bin/trun` and `.trun` references in `zsh/towmux.zsh`, `install.sh`, `uninstall.sh`
- [x] 6.2 Update `CHEATSHEET.md` and `README.md` with the `<leader>r?` flow, the AI-creation path, and a `.trun` → `.vscode/tasks.json` migration example
- [x] 6.3 Note in docs that debug requires the Mason adapters and that the `ai` pane must run Claude

## 7. Verification

- [x] 7.1 End-to-end: empty project → `<leader>r?` → describe task → prompt sent to `ai` window (verified live); Claude authoring the file + re-trigger → run is the one manual step
- [ ] 7.2 End-to-end: debug request → Claude writes `.vscode/launch.json` → `<leader>r?` → `[debug]` entry → breakpoint hit — *[debug] listing + dap.run wiring verified live; live breakpoint needs a real debug target*
- [x] 7.3 Restart semantics: selecting a running `[run]` entry restarts rather than duplicates — *verified live: one `RUNNING: watch`, no duplicate*
