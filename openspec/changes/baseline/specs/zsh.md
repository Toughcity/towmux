# Specs: zsh/towmux.zsh and cfgsync

## S-ZSH-01: tmux session notice on shell start

GIVEN tmux is installed
AND the new shell is NOT already inside tmux (TMUX is unset)
AND at least one tmux session is running
THEN a notice is printed before the p10k instant prompt: "  N tmux session(s) — run `t` to switch"

GIVEN no tmux sessions are running
THEN no notice is printed (no output from this section)

## S-ZSH-02: environment variables

GIVEN towmux.zsh is sourced
THEN EDITOR and VISUAL are set to `nvim`
AND `$TOWMUX_DIR/.local/bin` (the CLI tools directory) is prepended to PATH
AND `$HOME/.local/bin` is also prepended to PATH (before system PATH)

## S-ZSH-03: local overrides file

GIVEN a file `~/.zshrc.local` exists
WHEN towmux.zsh is sourced
THEN `~/.zshrc.local` is sourced immediately after the environment block
AND can override any env var set above (CODE_DIRS, DEV_DIRS, TP_LAYOUT, etc.)

GIVEN `~/.zshrc.local` does not exist
THEN no error is raised — the source is silently skipped

## S-ZSH-04: history settings

GIVEN towmux.zsh is sourced
THEN HISTFILE is set to `~/.zsh_history`
AND HISTSIZE and SAVEHIST are both 50000
AND SHARE_HISTORY and INC_APPEND_HISTORY are enabled (shared across sessions)
AND EXTENDED_HISTORY is enabled (timestamps recorded)
AND HIST_IGNORE_DUPS, HIST_IGNORE_ALL_DUPS, HIST_IGNORE_SPACE are set
AND HIST_VERIFY is set (history expansions must be confirmed before execution)

## S-ZSH-05: plugin loading (antidote)

GIVEN antidote is installed at `/opt/homebrew/opt/antidote`
WHEN towmux.zsh is sourced
THEN antidote is sourced
AND `antidote load` is called with `$TOWMUX_DIR/.zsh_plugins.txt`
AND compinit runs before antidote (so plugins that use compdef work correctly)
AND the keymap is forced to emacs (`bindkey -e`) before plugin load (no vi-mode)

## S-ZSH-06: tool initializations

GIVEN zoxide is installed
THEN `eval "$(zoxide init zsh)"` runs, providing `z` (jump) and `zi` (interactive picker)

GIVEN atuin is installed
THEN `eval "$(atuin init zsh)"` runs, binding Ctrl-R to atuin history search

GIVEN fzf is installed via Homebrew at `/opt/homebrew/opt/fzf`
THEN fzf key-bindings (Ctrl-T, Alt-C, Ctrl-R) and completion (`**<TAB>`) are sourced
AND each fzf file is sourced only if it exists (guard with `-f` check)

## S-ZSH-07: lazy NVM stubs

GIVEN NVM_DIR is set to `~/.nvm`
WHEN towmux.zsh is sourced
THEN `nvm`, `node`, `npm`, and `npx` are defined as stub functions
AND each stub: (1) undefines all four stubs, (2) sources `$NVM_DIR/nvm.sh`, (3) calls the real binary with the original arguments
AND subsequent calls after the first hit the real NVM/Node binaries directly (stubs are gone)

GIVEN `~/.nvm/nvm.sh` does not exist
THEN the stubs still exist but calling them will fail when they attempt to source the missing file
(NVM not installed is surfaced at call time, not at shell startup)

## S-ZSH-08: aliases

GIVEN towmux.zsh is sourced
THEN the following aliases are set:

| Alias | Expands to |
|-------|-----------|
| `ls` | `eza --group-directories-first` |
| `ll` | `eza -lah --group-directories-first --git` |
| `la` | `eza -a` |
| `lt` | `eza --tree --level=2` |
| `cat` | `bat --paging=never` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `g` | `git` |
| `lg` | `lazygit` |
| `zshconfig` | `${EDITOR:-nvim} "$TOWMUX_FILE"` (opens the zsh module itself) |
| `cheat` | `_print_cheatsheet` |
| `cfgsync` | `_cfgsync` |
| `t` | `tp` |
| `tls` | `tmux ls 2>/dev/null \|\| echo "no tmux sessions"` |

## S-ZSH-09: cheatsheet

GIVEN the user runs `cheat`
THEN the section of `towmux.zsh` between `# CHEATSHEET START` and `# CHEATSHEET END` markers is extracted
AND the leading `# ` prefix is stripped from each line
AND the result is printed via `bat` (syntax-highlighted, no paging) if bat is available
AND falls back to plain `print` if bat is not on PATH

## S-ZSH-10: p10k prompt

GIVEN `$TOWMUX_DIR/.p10k.zsh` exists
THEN it is sourced at the end of the module to activate the Powerlevel10k theme
AND the p10k instant-prompt cache (if present) is sourced earlier in the file (section 1) to eliminate the blank-line delay on new shells

---

## S-CFGSYNC-01: nvim symlink refresh

GIVEN `cfgsync` is called
THEN before committing, dangling symlinks under `~/.config/nvim/` pointing into `$repo/nvim/.config/nvim/` are removed
AND every file under `$repo/nvim/.config/nvim/` is (re-)symlinked into `~/.config/nvim/` preserving directory structure
AND intermediate directories are created with `mkdir -p` as needed
AND existing, valid symlinks are overwritten (`ln -sfn`) — this is idempotent

## S-CFGSYNC-02: commit with default message

GIVEN `cfgsync` is called with no arguments
AND there are staged changes after `git add -A`
THEN the commit message is `sync: YYYY-MM-DD HH:MM` (current date/time)

## S-CFGSYNC-03: commit with custom message

GIVEN the user runs `cfgsync "my commit message"`
AND there are staged changes
THEN the provided string is used as the commit message

## S-CFGSYNC-04: nothing to commit

GIVEN `cfgsync` is called
AND `git diff --cached --quiet` passes (no staged changes)
THEN the message "cfgsync: nothing to commit" is printed
AND the function returns 0 (no error)

## S-CFGSYNC-05: push behavior

GIVEN a remote is configured on the repo (`git remote` returns output)
THEN `git push` is run after the commit

GIVEN no remote is configured
THEN the commit is made locally only
AND a message is printed: "cfgsync: committed locally (no remote configured — add one with: git remote add origin <url>)"
