#!/usr/bin/env bash
# Bootstrap a new mac with the terminal + neovim setup.
# Idempotent — safe to re-run.

set -euo pipefail

cd "$(dirname "$0")"

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Brew packages
echo "==> Installing Brewfile packages"
brew bundle --file=./Brewfile

# 3. NVM (.zshrc lazy-loads it; install if missing)
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> Installing NVM"
  PROFILE=/dev/null curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# 4. Stow dotfiles into $HOME
echo "==> Linking dotfiles via stow"
stow --target="$HOME" --restow zsh
stow --target="$HOME" --restow nvim

cat <<'EOF'

==> Done.

Next steps:
  1. Open a new terminal so the new ~/.zshrc loads.
  2. Run `nvim` once — LazyVim will bootstrap lazy.nvim and install all plugins.
  3. Set your terminal font to "MesloLGS Nerd Font" so p10k glyphs render.

Refreshing later:
  brew upgrade               # latest brew packages
  nvim +':Lazy sync' +qa     # latest nvim plugins (rewrites lazy-lock.json — commit it)
EOF
