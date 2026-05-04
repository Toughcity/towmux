# term-config

Terminal + Neovim setup for a fresh macOS install.

## What's in here

```
.
├── Brewfile             # curated CLI tools — terminal/nvim only
├── install.sh           # idempotent bootstrap script
├── zsh/
│   ├── .zshrc           # antidote, p10k, atuin, fzf, zoxide, aliases
│   ├── .zsh_plugins.txt # antidote bundle list
│   └── .p10k.zsh        # powerlevel10k prompt config
└── nvim/.config/nvim/   # LazyVim starter (LazyVim updates via :Lazy)
```

`stow` symlinks the contents of `zsh/` into `$HOME` and `nvim/.config/nvim/`
into `$HOME/.config/nvim/`.

## Bootstrap a new mac

```sh
git clone <this-repo> ~/Code/term-config
cd ~/Code/term-config
./install.sh
```

The script installs Homebrew (if missing), runs `brew bundle`, installs NVM,
and stows the dotfiles. Re-run it anytime — it's idempotent.

After install: open a new terminal, then run `nvim` once to let LazyVim
bootstrap its plugins.

## Refreshing

```sh
brew upgrade                 # latest CLI tools
nvim +':Lazy sync' +qa       # latest nvim plugins (commits the lock refresh)
git add nvim/.config/nvim/lazy-lock.json && git commit -m "chore: refresh nvim plugins"
```

`lazy-lock.json` is committed so a fresh laptop reproduces *exactly* what
works today. `:Lazy sync` is how you pull upstream drift on your schedule.

## Adding a tool

If a CLI you actually use in the terminal or nvim is missing, add a line to
`Brewfile` and re-run `./install.sh`. Keep project-specific tooling
(databases, cloud SDKs, language SDKs) out of here — install those per project.
