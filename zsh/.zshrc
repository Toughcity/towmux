# ── 1. p10k instant prompt (must stay at top) ────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── 2. environment ───────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$PATH"

# ── 3. history ───────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt HIST_VERIFY HIST_REDUCE_BLANKS HIST_FIND_NO_DUPS

# ── 4. completion + plugins (antidote) ───────────────────────────────
# compinit must run before plugins that use compdef (git, brew, etc.)
autoload -Uz compinit && compinit
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load

# ── 5. tool initializations ──────────────────────────────────────────
eval "$(zoxide init zsh)"           # adds `z` and `zi`
eval "$(atuin init zsh)"            # ctrl-r history search
[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]   && source /opt/homebrew/opt/fzf/shell/completion.zsh

_pick_start_dir() {
  [[ -o interactive ]] || return
  command -v fzf >/dev/null 2>&1 || return

  local choice
  choice=$(print -rl -- "$HOME	~" "$HOME/Code	Code" "$HOME/Safad-Code	Safad-Code" \
    | fzf --delimiter=$'\t' --with-nth=2 --prompt='Open terminal in > ' --height=40% --border) || return

  cd "${choice%%$'\t'*}" || return
}

_pick_start_dir

# ── 6. lazy NVM (don't pay the load cost on every shell) ─────────────
export NVM_DIR="$HOME/.nvm"
nvm()  { unset -f nvm node npm npx; . "$NVM_DIR/nvm.sh"; nvm "$@"; }
node() { unset -f nvm node npm npx; . "$NVM_DIR/nvm.sh"; node "$@"; }
npm()  { unset -f nvm node npm npx; . "$NVM_DIR/nvm.sh"; npm "$@"; }
npx()  { unset -f nvm node npm npx; . "$NVM_DIR/nvm.sh"; npx "$@"; }

# ── 7. aliases ───────────────────────────────────────────────────────
alias ls='eza --group-directories-first'
alias ll='eza -lah --group-directories-first --git'
alias la='eza -a'
alias lt='eza --tree --level=2'
alias cat='bat --paging=never'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias lg='lazygit'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias cheat='_print_cheatsheet'
alias cfgsync='_cfgsync'

# ── 8. dotfiles sync ─────────────────────────────────────────────────
_cfgsync() {
  local repo="$HOME/Code/term-config"
  local msg="${1:-"sync: $(date '+%Y-%m-%d %H:%M')"}"
  git -C "$repo" add -A
  if git -C "$repo" diff --cached --quiet; then
    echo "cfgsync: nothing to commit"
    return 0
  fi
  git -C "$repo" commit -m "$msg" && git -C "$repo" push
}

# ── 9. p10k prompt ───────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── 10. cheatsheet (run `cheat` to print this) ───────────────────────
# CHEATSHEET START — keep this marker so the `cheat` function can find it
#
# ── Navigation ───────────────────────────────────────────────────────
#   ls / ll / la / lt    eza listings (basic / long+git / all / tree)
#   z <partial>          jump to most-frecent dir matching <partial>     (zoxide)
#   zi                   interactive dir picker via fzf                  (zoxide)
#   ..  ...              cd up one / two levels
#   cdf                  cd to the dir of the frontmost Finder window    (omz/macos)
#   ofd                  open current dir in Finder                      (omz/macos)
#   pfd                  echo path of frontmost Finder window            (omz/macos)
#
# ── Files & viewing ──────────────────────────────────────────────────
#   cat <file>           syntax-highlighted (bat, no pager)
#   bat <file>           same but with paging + line numbers
#   tldr <cmd>           quick example-driven cheatsheet for <cmd>
#   man <cmd>            colored man pages                               (omz/colored-man-pages)
#
# ── Search ───────────────────────────────────────────────────────────
#   rg <pattern>         ripgrep — fast recursive content search
#   fd <pattern>         fast file finder (regex on names)
#   Ctrl-T               fzf file picker (insert path on cmdline)        (fzf)
#   Alt-C                fzf cd-into-subdir                              (fzf)
#   **<TAB>              fzf-completion expansion of paths/args          (fzf)
#
# ── History ──────────────────────────────────────────────────────────
#   Ctrl-R               atuin fuzzy history search across sessions      (atuin)
#   ↑ / ↓                history-substring match by what's typed
#   !!                   last command       (sudo !! = re-run with sudo)
#   !$                   last argument of previous command
#   !*                   all args of previous command
#   fc                   open last command in $EDITOR, run on save
#
# ── Line editing (zsh) ───────────────────────────────────────────────
#   →                    accept full autosuggestion                      (zsh-autosuggestions)
#   Ctrl-→  / Alt-F      accept next word of suggestion / move word fwd
#   Ctrl-A  / Ctrl-E     beginning / end of line
#   Ctrl-W               delete word back
#   Ctrl-U  / Ctrl-K     clear to start / clear to end
#   Esc-.                insert last argument of previous command
#   Ctrl-X Ctrl-E        edit current command in $EDITOR
#
# ── Git (omz/git plugin) ─────────────────────────────────────────────
#   gst                  git status                  gp     git push
#   ga / gaa             git add / git add --all     gpf    git push --force-with-lease
#   gc / gcm "msg"       git commit / commit -m      gl     git pull
#   gco <ref>            git checkout               gcb     git checkout -b
#   gd / gds             git diff / --staged         glog   pretty graph log
#   gb / gbd             git branch / branch -d      gsta   git stash
#   gm  / grb            git merge / git rebase      gstp   git stash pop
#   g                    git                         lg     lazygit (TUI)
#
# ── Misc ─────────────────────────────────────────────────────────────
#   gh                   GitHub CLI (auth, pr, issue, repo, run, ...)
#   nvm / node / npm     lazy-loaded; first call is slow, then instant
#   zshconfig            edit ~/.zshrc
#   cheat                print this cheatsheet
#   cfgsync [msg]        commit + push ~/Code/term-config (optional commit message)
#
# CHEATSHEET END

_print_cheatsheet() {
  local out
  out=$(sed -n '/^# CHEATSHEET START/,/^# CHEATSHEET END/p' ~/.zshrc \
        | sed -e '1d' -e '$d' -e 's/^# \{0,1\}//')
  if command -v bat >/dev/null 2>&1; then
    print -r -- "$out" | bat --style=plain --language=md --paging=never
  else
    print -r -- "$out"
  fi
}
