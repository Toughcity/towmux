#!/usr/bin/env bash
# Revert everything install.sh wires into your machine.
# Idempotent — safe to re-run, and safe to run whether you installed via the
# current "source from repo" approach or the older symlink approach.
#
# By default this only touches files install.sh manages:
#   - removes the towmux block from ~/.zshrc and ~/.config/tmux/tmux.conf
#     (or drops the whole file if it was a legacy symlink into this repo)
#   - removes leftover symlinks for .p10k.zsh, .zsh_plugins.txt and the
#     tp/trun/tterm/tnew/tlayout helpers
#   - removes the neovim config symlinks from ~/.config/nvim
#   - deletes antidote's generated plugin cache inside the repo
#
# Homebrew, the Brewfile packages, and NVM are shared tooling and are left in
# place. Pass --brew to also uninstall the Brewfile packages.

set -euo pipefail

cd "$(dirname "$0")"
REPO="$(pwd -P)"

MARK_START="# >>> towmux >>>"
MARK_END="# <<< towmux <<<"

# Legacy markers from when this project was called "term-config" — detached too.
LEGACY_START="# >>> term-config >>>"
LEGACY_END="# <<< term-config <<<"

UNINSTALL_BREW=0
[[ "${1:-}" == "--brew" ]] && UNINSTALL_BREW=1

# Canonical path a symlink resolves to (handles relative links + dangling
# files whose parent dir still exists). Prints nothing if $1 isn't a symlink.
link_target_canonical() {
  local f="$1" t dir
  [[ -L "$f" ]] || return 1
  t="$(readlink "$f")"
  case "$t" in /*) ;; *) t="$(dirname "$f")/$t" ;; esac
  dir="$(cd "$(dirname "$t")" 2>/dev/null && pwd -P)" || return 1
  printf '%s/%s\n' "$dir" "$(basename "$t")"
}

# True if $1 is a symlink that points somewhere inside this repo.
link_into_repo() {
  local resolved
  resolved="$(link_target_canonical "$1")" || return 1
  [[ "$resolved" == "$REPO"/* ]]
}

# Remove the managed block (markers inclusive) from $1 and trim surrounding
# blank lines. If nothing meaningful remains, delete the file.
strip_block() {
  local file="$1" rest
  rest="$(awk -v s="$MARK_START" -v e="$MARK_END" -v ls="$LEGACY_START" -v le="$LEGACY_END" '
    $0==s || $0==ls {skip=1; next}
    $0==e || $0==le {skip=0; next}
    !skip {print}
  ' "$file" | awk '
    { l[NR]=$0; if ($0 ~ /[^[:space:]]/) { if (!f) f=NR; t=NR } }
    END { for (i=f; i<=t; i++) print l[i] }
  ')"
  if [[ -z "$rest" ]]; then
    rm -f "$file"
    echo "   removed $file (no content left outside the towmux block)"
  else
    printf '%s\n' "$rest" >"$file"
    echo "   removed towmux block from $file"
  fi
}

# Detach a config file: drop it if it's a legacy symlink into the repo,
# otherwise strip our managed block from the real file.
detach() {
  local file="$1"
  if link_into_repo "$file"; then
    rm -f "$file"
    echo "   removed legacy symlink $file"
  elif [[ -f "$file" ]] && { grep -qF "$MARK_START" "$file" || grep -qF "$LEGACY_START" "$file"; }; then
    strip_block "$file"
  fi
}

echo "==> Detaching shell + tmux config"
detach "$HOME/.zshrc"
detach "$HOME/.config/tmux/tmux.conf"

echo "==> Removing leftover symlinks"
for f in "$HOME/.p10k.zsh" "$HOME/.zsh_plugins.txt" \
         "$HOME/.local/bin/tp"   "$HOME/.local/bin/trun"  \
         "$HOME/.local/bin/tterm" "$HOME/.local/bin/tnew" \
         "$HOME/.local/bin/tlayout"; do
  if link_into_repo "$f"; then
    rm -f "$f"
    echo "   removed $f"
  fi
done

echo "==> Removing neovim config symlinks"
NVIM_DST="$HOME/.config/nvim"
if [[ -d "$NVIM_DST" ]]; then
  find "$NVIM_DST" -type l 2>/dev/null | while IFS= read -r link; do
    if link_into_repo "$link"; then rm -f "$link"; fi
  done
  # Clean up directories left empty once our links are gone (keeps the dir if
  # unrelated files such as a .claude/ folder still live there).
  find "$NVIM_DST" -type d -empty -delete 2>/dev/null || true
fi

echo "==> Removing generated antidote cache"
rm -f "$REPO/zsh/.zsh_plugins.zsh"

if [[ "$UNINSTALL_BREW" -eq 1 ]]; then
  echo "==> Uninstalling Brewfile packages (--brew)"
  if command -v brew >/dev/null 2>&1; then
    # `brew bundle cleanup` only removes things NOT in the Brewfile, so uninstall
    # each listed package directly. Failures (e.g. a package other software still
    # depends on) are reported by brew and skipped.
    while IFS= read -r formula; do
      brew uninstall --formula "$formula" 2>/dev/null \
        && echo "   uninstalled $formula" \
        || echo "   kept $formula (not installed, or another package needs it)"
    done < <(sed -nE 's/^brew "([^"]+)".*/\1/p' "$REPO/Brewfile")
    while IFS= read -r cask; do
      brew uninstall --cask "$cask" 2>/dev/null \
        && echo "   uninstalled cask $cask" \
        || echo "   kept cask $cask (not installed)"
    done < <(sed -nE 's/^cask "([^"]+)".*/\1/p' "$REPO/Brewfile")
  else
    echo "   brew not found — nothing to do"
  fi
fi

cat <<EOF

==> Done. towmux has been detached from your machine.

Left in place (shared tooling — remove manually if you really want to):
EOF
[[ "$UNINSTALL_BREW" -eq 1 ]] || cat <<EOF
  - Brewfile packages    re-run with: ./uninstall.sh --brew
EOF
cat <<EOF
  - Homebrew itself      https://github.com/homebrew/install#uninstall-homebrew
  - NVM                  rm -rf "\$HOME/.nvm"

Open a new terminal to drop the towmux shell setup from your session.
EOF
