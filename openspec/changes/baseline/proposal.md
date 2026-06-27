# Baseline: towmux as-built

## Status
archived

## Problem
Modern AI-assisted development pushes developers toward one IDE window per project,
each carrying its own editor process, language servers, integrated terminal, and AI
panel. Five projects open = five of everything, a cluttered dock, and heavy RAM use.

## What this project does
towmux is a repo you clone once to bootstrap a terminal development environment on a
new or existing Mac. It provides:

- **`tp`** — a fuzzy project picker that opens (or attaches to) a tmux session per repo,
  with choice of two layouts on first open.
- **`trun`** — a named run-config runner backed by a per-project `.trun` file, stable
  window-per-config semantics (like IDE run configurations).
- **`tlayout`** — live conversion between the two layouts, preserving running processes.
- **`tterm` / `tnew`** — helpers for adding terminal windows or scratch sessions.
- **`install.sh`** — idempotent bootstrapper: Homebrew, Brewfile, NVM, managed blocks
  in `~/.zshrc` and `~/.config/tmux/tmux.conf`, per-file nvim symlinks.
- **`uninstall.sh`** — clean teardown of managed blocks and symlinks.
- **`zsh/towmux.zsh`** — the zsh module: env, history, plugins (antidote), tool inits
  (zoxide, atuin, fzf), lazy NVM, aliases, dotfiles sync (`cfgsync`), p10k prompt,
  and a printable cheatsheet.
- **`tmux/.config/tmux/tmux.conf`** — tmux config: prefix `C-Space`, Tokyo Night status
  bar, seamless nvim↔tmux navigation via smart-splits, layout-aware keybinds.
- **`nvim/.config/nvim/`** — a LazyVim-based Neovim config with custom plugins (incline,
  trouble, overseer, smart-splits, Tokyo Night colorscheme, etc.).

## What will NOT change (baseline scope)
This is a documentation-only snapshot of the current working state. No code changes.

## Key constraints
- The repo must be cloned to a stable path (default: `~/Code/towmux`) because the
  install writes that absolute path into `~/.zshrc` and the tmux conf.
- The project has no build step, no package.json, no CI. It is plain bash + zsh + lua.
- Neovim is the only component that requires symlinks; zsh and tmux source files
  directly from the repo at shell/tmux startup time.
