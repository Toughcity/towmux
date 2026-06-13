# term-config

Terminal + Neovim setup for a fresh macOS install.

## What's in here

```
.
├── Brewfile             # curated CLI tools — terminal/nvim only
├── install.sh           # idempotent bootstrap script
├── zsh/
│   ├── term-config.zsh  # antidote, p10k, atuin, fzf, zoxide, aliases
│   ├── .zsh_plugins.txt # antidote bundle list
│   ├── .p10k.zsh        # powerlevel10k prompt config
│   └── .local/bin/      # tp / trun / tterm / tnew / tlayout helpers
├── tmux/.config/tmux/   # tmux.conf
└── nvim/.config/nvim/   # LazyVim starter (LazyVim updates via :Lazy)
```

`install.sh` does **not** overwrite your `~/.zshrc` or tmux config. It appends a
small managed block to each (marked with `# >>> term-config >>>`) that sources
the files above straight from this repo and adds `zsh/.local/bin` to your
`PATH`. Anything you already have in those files is preserved. Delete the marked
block to detach. Only the neovim config — a complete config this repo owns — is
symlinked, via `stow`, into `~/.config/nvim/`.

## Bootstrap a new mac

```sh
git clone <this-repo> ~/Code/term-config
cd ~/Code/term-config
./install.sh
```

The script installs Homebrew (if missing), runs `brew bundle`, installs NVM,
wires the zsh + tmux references into your config, and stows the neovim config.
Re-run it anytime — it's idempotent, and re-running updates the managed blocks
in place (useful if you move the repo).

## Uninstall

```sh
cd ~/Code/term-config
./uninstall.sh           # detach from your machine
./uninstall.sh --brew    # also uninstall the Brewfile packages
```

`uninstall.sh` removes the managed block from `~/.zshrc` and the tmux config
(preserving your own settings), drops the leftover symlinks and stowed neovim
config, and deletes the generated plugin cache. Homebrew, the Brewfile packages,
and NVM are shared tooling and are left in place unless you pass `--brew`.

After install: open a new terminal, then run `nvim` once to let LazyVim
bootstrap its plugins.

## Local overrides

Put machine-specific env vars in `~/.zshrc.local`.

```sh
echo 'export MY_VAR=value' >> ~/.zshrc.local
```

`~/.zshrc` sources that file if it exists, so the settings stay local and out
of the repo.

### Project search roots

`DEV_DIRS` is a colon-separated list of directories that the nvim project
picker (`<Space>fp`) searches. Defaults to `~/Code`. Add more in
`~/.zshrc.local`:

```sh
export DEV_DIRS="$HOME/Code:$HOME/Work:$HOME/Forks"
```

## Refreshing

```sh
brew upgrade                 # latest CLI tools
nvim +':Lazy sync' +qa       # latest nvim plugins (commits the lock refresh)
git add nvim/.config/nvim/lazy-lock.json && git commit -m "chore: refresh nvim plugins"
```

`lazy-lock.json` is committed so a fresh laptop reproduces *exactly* what
works today. `:Lazy sync` is how you pull upstream drift on your schedule.

## Adding a tool

Add a line to `Brewfile` and re-run `./install.sh`. Keep project-specific
tooling (databases, cloud SDKs, language SDKs) out of here — install those
per project.
