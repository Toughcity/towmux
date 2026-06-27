# Tasks: baseline

This is a documentation-only baseline — no implementation tasks.

## Completed (as-built)
- [x] `tp`: project picker with fzf, two layouts, session kill shortcut
- [x] `trun`: named run configs, stable windows, restart behavior
- [x] `tlayout`: live layout conversion, process-preserving join/break-pane
- [x] `tterm`: auto-numbered terminal windows
- [x] `tnew`: scratch sessions, auto-naming, inside/outside tmux attach
- [x] `install.sh`: idempotent, managed blocks, per-file nvim symlinks, Homebrew, NVM
- [x] `uninstall.sh`: block removal, symlink cleanup, optional brew teardown
- [x] `zsh/towmux.zsh`: env, history, antidote, tool inits, lazy NVM, aliases, cfgsync, p10k, cheatsheet
- [x] `tmux.conf`: prefix, Tokyo Night status bar, smart-splits, layout keybinds, copy mode
- [x] Neovim (LazyVim base + custom plugins)

## Known gaps / tech debt
- [ ] Unify CODE_DIRS and DEV_DIRS into a single env var with one format
- [ ] `cfgsync` uses `git add -A` — could accidentally commit unintended files
- [ ] No automated tests for CLI scripts
- [ ] `uninstall.sh` lacks `--brew` implementation (passes flag but behavior needs verification)
