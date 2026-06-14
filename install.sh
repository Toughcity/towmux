#!/usr/bin/env bash
# Bootstrap a new mac with the terminal + neovim setup.
# Idempotent — safe to re-run.
#
# This does NOT overwrite your shell or tmux config. Instead it appends a
# small managed block to ~/.zshrc and ~/.config/tmux/tmux.conf that sources
# the towmux files straight from this repo. Your own settings in those
# files are left untouched. Remove the marked block to fully detach.

set -euo pipefail

cd "$(dirname "$0")"
REPO="$(pwd -P)"

MARK_START="# >>> towmux >>>"
MARK_END="# <<< towmux <<<"

# Legacy markers from when this project was called "term-config" — stripped on
# install so renaming doesn't leave a stale duplicate block behind.
LEGACY_START="# >>> term-config >>>"
LEGACY_END="# <<< term-config <<<"

# Replace any existing towmux block in $1, then write $2 to it.
# $3 = "top" prepends (needed so p10k's instant prompt stays near the top of
# ~/.zshrc); anything else appends.
ensure_block() {
  local file="$1" block="$2" where="${3:-bottom}"
  mkdir -p "$(dirname "$file")"
  # Migration: older installs symlinked this path into the repo. Writing
  # through that link would clobber the repo's own files, so drop the link
  # and start from a real (empty) file before adding our block.
  [[ -L "$file" ]] && rm -f "$file"
  [[ -f "$file" ]] || : >"$file"

  # Strip a previous managed block (current or legacy markers, inclusive) so
  # re-runs update in place, then trim leading/trailing blank lines so blanks
  # don't accumulate.
  local stripped
  stripped="$(awk -v s="$MARK_START" -v e="$MARK_END" -v ls="$LEGACY_START" -v le="$LEGACY_END" '
    $0==s || $0==ls {skip=1; next}
    $0==e || $0==le {skip=0; next}
    !skip {print}
  ' "$file" | awk '
    { l[NR]=$0; if ($0 ~ /[^[:space:]]/) { if (!f) f=NR; t=NR } }
    END { for (i=f; i<=t; i++) print l[i] }
  ')"

  if [[ "$where" == "top" ]]; then
    printf '%s\n\n%s\n' "$block" "$stripped" >"$file"
  else
    printf '%s\n\n%s\n' "$stripped" "$block" >"$file"
  fi
}

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Brew packages
echo "==> Installing Brewfile packages"
brew bundle --file=./Brewfile

# 3. NVM (towmux.zsh lazy-loads it; install if missing)
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> Installing NVM"
  PROFILE=/dev/null curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# 4. Reference the zsh module from ~/.zshrc (prepended, never overwritten)
echo "==> Wiring towmux into ~/.zshrc"
ensure_block "$HOME/.zshrc" "$(cat <<EOF
$MARK_START
# Managed by towmux/install.sh — sources shared shell config from the repo.
# Delete this block (both markers included) to detach. Your other settings stay.
[[ -f "$REPO/zsh/towmux.zsh" ]] && source "$REPO/zsh/towmux.zsh"
$MARK_END
EOF
)" top

# 5. Reference the tmux config from ~/.config/tmux/tmux.conf (appended)
echo "==> Wiring towmux into ~/.config/tmux/tmux.conf"
ensure_block "$HOME/.config/tmux/tmux.conf" "$(cat <<EOF
$MARK_START
# Managed by towmux/install.sh — delete this block to detach.
source-file "$REPO/tmux/.config/tmux/tmux.conf"
$MARK_END
EOF
)"

# 6. Symlink the neovim config into ~/.config/nvim. nvim has no "source a
#    file" hook, so this is the one part that must be linked — but with plain
#    `ln`, not stow. We link per-file (not the whole dir) so unrelated files
#    already in ~/.config/nvim are left alone.
echo "==> Linking neovim config"
NVIM_SRC="$REPO/nvim/.config/nvim"
NVIM_DST="$HOME/.config/nvim"
mkdir -p "$NVIM_DST"
# Drop our own symlinks whose source file was removed from the repo.
find "$NVIM_DST" -type l 2>/dev/null | while IFS= read -r link; do
  tgt="$(readlink "$link")"; [[ "$tgt" != /* ]] && tgt="$(dirname "$link")/$tgt"
  [[ "$tgt" == "$NVIM_SRC"/* && ! -e "$link" ]] && rm -f "$link"
done
# Link every config file from the repo, recreating the directory structure.
find "$NVIM_SRC" -type f -print0 | while IFS= read -r -d '' f; do
  rel="${f#"$NVIM_SRC"/}"
  mkdir -p "$NVIM_DST/$(dirname "$rel")"
  ln -sfn "$f" "$NVIM_DST/$rel"
done

cat <<EOF

==> Done.

Next steps:
  1. Open a new terminal so the towmux additions to ~/.zshrc load.
  2. Run \`nvim\` once — LazyVim will bootstrap lazy.nvim and install all plugins.
  3. Set your terminal font to "MesloLGS Nerd Font" so p10k glyphs render.
  4. Run \`tp .\` inside any project directory to open your first tmux project.
     (Inside an existing tmux session, hit prefix + r to reload its config.)

Refreshing later:
  brew upgrade               # latest brew packages
  nvim +':Lazy sync' +qa     # latest nvim plugins (rewrites lazy-lock.json — commit it)
  tp                         # open / switch tmux project (fzf picker)
EOF
