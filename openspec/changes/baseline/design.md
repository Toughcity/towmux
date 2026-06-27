# Design: towmux baseline

## Architecture

towmux is a **repo-as-dotfiles** project. No daemon, no build step, no package manager.
The repo is cloned once and stays in place. Shell and tmux config is sourced directly
from the repo; Neovim is the one exception (symlinked per-file into `~/.config/nvim`).

```
~/Code/towmux/
├── install.sh          # bootstrapper (idempotent)
├── uninstall.sh        # teardown
├── Brewfile            # declarative dependency list
├── zsh/
│   ├── towmux.zsh      # the zsh module (sourced from ~/.zshrc)
│   ├── .zsh_plugins.txt
│   ├── .zsh_plugins.zsh
│   ├── .p10k.zsh
│   └── .local/bin/     # CLI tools on PATH
│       ├── tp          # project picker / session launcher
│       ├── trun        # named run configs
│       ├── tlayout     # layout converter
│       ├── tterm       # add terminal window
│       └── tnew        # scratch session
├── tmux/
│   └── .config/tmux/tmux.conf
└── nvim/
    └── .config/nvim/   # LazyVim config (symlinked into ~/.config/nvim)
```

## Key design decisions

### Managed blocks (not full file ownership)
`install.sh` injects a marked block (`# >>> towmux >>>` … `# <<< towmux <<<`) into
`~/.zshrc` and `~/.config/tmux/tmux.conf`. The user's own content in those files is
left untouched. The block is replaced in-place on re-run, not appended — achieved via
`awk` stripping the old block before writing the new one.

### Per-file nvim symlinks (not stow, not a single dir link)
`ln -sfn` is used per-file so the user can have unrelated files in `~/.config/nvim`
that towmux never touches. `install.sh` and `cfgsync` both sweep for dangling symlinks
pointing into the repo and remove them, so renaming or removing repo files propagates
cleanly.

### Lazy NVM
NVM adds ~200ms to shell startup. towmux stubs `nvm`, `node`, `npm`, `npx` as
functions that load NVM on first call and then undefine themselves — subsequent calls
hit the real binaries.

### Two layouts
- **`windows`**: one tmux window per role (`code`, `ai`, `term`, `run-*`). Easiest to
  navigate; clear mental separation. Default.
- **`ide`**: single window, three panes. `nvim` left, `claude` top-right, `term` bottom.
  Good for smaller screens or when you want everything visible at once.

`tlayout` converts between them at runtime by joining/breaking panes. Running processes
survive the conversion. Layout detection: any pane tagged with `@layout-name` → ide;
all single-pane windows → windows.

### trun: stable windows, not ephemeral processes
Each named run config gets its own stable tmux window (`run-<name>` or `run`). If the
window already exists, `trun` sends `C-c` and replaces the command. This mirrors IDE
run configuration behavior: one button press restarts the process in the same slot.

### Session naming
`tp` derives the session name from `basename(path)` lowercased with spaces/dots
replaced by `-`. This means the session name is deterministic from the directory name,
so `tp .` in the same repo always attaches to the same session.

## Dependencies (managed via Brewfile)
| Tool | Role |
|------|------|
| tmux | session/window/pane manager |
| neovim | editor |
| node | Mason / LSP servers / Copilot under LazyVim |
| uv | Python provider for nvim (ruff, mypy) |
| antidote | zsh plugin manager |
| atuin | shell history search (Ctrl-R) |
| zoxide | frecency directory jumper (z/zi) |
| fzf | fuzzy finder (all pickers, fzf-tab) |
| bat | syntax-highlighted `cat` |
| eza | modern `ls` |
| lazygit | TUI git client |
| gh | GitHub CLI |
| ripgrep | fast content search (rg) |
| fd | fast file finder |
| tldr | example-driven manpages |
| font-meslo-lg-nerd-font | Powerline/p10k glyph rendering |

NVM is installed separately (not via Homebrew) to avoid version-pinning issues.

## Neovim plugins (beyond LazyVim defaults)

Note: This baseline lists the Neovim plugins in use, but does not attempt to fully specify Neovim/LazyVim behaviour (keymaps, UI, plugin semantics, etc.).

| Plugin | Purpose |
|--------|---------|
| smart-splits.nvim | seamless Ctrl-hjkl across nvim splits and tmux panes |
| incline.nvim | floating filename labels per split |
| trouble.nvim | diagnostics list panel |
| overseer.nvim | task runner (maps to trun configs) |
| Tokyo Night | colorscheme (matches tmux status bar) |
| tint.nvim | dim inactive splits |
| indent-blankline | indent guides |
| gitsigns | inline git hunks in gutter |
| snacks.nvim | LazyVim extras (notifications, etc.) |

## Environment variables
| Variable | Default | Purpose |
|----------|---------|---------|
| `CODE_DIRS` | `~/Code ~/Code-Safad` | space-separated roots for `tp` project scan |
| `DEV_DIRS` | `~/Code` | colon-separated roots for nvim `<Space>fp` |
| `TP_LAYOUT` | _(unset — prompts)_ | skip the layout picker on new sessions |

## Known tech debt
- `CODE_DIRS` (space-separated) and `DEV_DIRS` (colon-separated) are separate env vars
  for the same concept. Should be unified to one format with one variable.
- No tests. The CLI scripts have no automated test coverage.
- `cfgsync` runs `git add -A` which would pick up unintended files if the user has
  untracked files they don't want committed.
