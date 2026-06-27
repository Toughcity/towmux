# Specs: install.sh and uninstall.sh

## S-INSTALL-01: idempotent on re-run

GIVEN install.sh has already been run
WHEN run again (e.g. after moving the repo or updating it)
THEN all managed blocks are replaced in place (not duplicated)
AND no user-owned content in ~/.zshrc or tmux.conf is modified or lost

## S-INSTALL-02: managed block injection — zsh

GIVEN ~/.zshrc may or may not exist
WHEN install.sh runs
THEN a managed block is prepended to ~/.zshrc (so p10k instant prompt stays near top)
AND the block sources `zsh/towmux.zsh` from the repo's absolute path
AND existing file content is preserved below the block

## S-INSTALL-03: managed block injection — tmux

GIVEN ~/.config/tmux/tmux.conf may or may not exist
WHEN install.sh runs
THEN a managed block is appended to the tmux config
AND the block sources `tmux/.config/tmux/tmux.conf` from the repo's absolute path

## S-INSTALL-04: legacy marker migration

GIVEN a previous install used markers `# >>> term-config >>>` (old project name)
WHEN install.sh runs
THEN the legacy block is stripped and replaced with the current `towmux` markers
AND no stale duplicate block is left behind

## S-INSTALL-05: symlink upgrade (broken link recovery)

GIVEN a previous install had symlinked the config file itself (not contents)
WHEN install.sh runs and encounters a symlink at the target file path
THEN the symlink is removed and a real file is created in its place

## S-INSTALL-06: nvim config symlinks

GIVEN the repo has files under `nvim/.config/nvim/`
WHEN install.sh runs
THEN every file is symlinked individually into `~/.config/nvim/` preserving directory structure
AND dangling symlinks under `~/.config/nvim/` pointing into the repo are removed first
AND unrelated files in `~/.config/nvim/` not owned by towmux are untouched

## S-INSTALL-07: homebrew setup

GIVEN Homebrew is not installed
WHEN install.sh runs
THEN Homebrew is installed via its official install script
AND `brew bundle` installs all packages in Brewfile

GIVEN Homebrew is already installed
WHEN install.sh runs
THEN `brew bundle` is run (idempotent — skips already-installed packages)

## S-INSTALL-08: NVM setup

GIVEN `~/.nvm` does not exist
WHEN install.sh runs
THEN NVM is installed without modifying the user's shell profile (PROFILE=/dev/null)

GIVEN `~/.nvm` already exists
THEN NVM install is skipped

---

## S-UNINSTALL-01: remove managed blocks

GIVEN uninstall.sh is run
THEN the towmux managed block is removed from ~/.zshrc
AND the towmux managed block is removed from ~/.config/tmux/tmux.conf
AND the user's own content in both files is preserved

## S-UNINSTALL-02: remove nvim symlinks

GIVEN uninstall.sh is run
THEN symlinks in `~/.config/nvim/` that point into the towmux repo are removed
AND unrelated files in `~/.config/nvim/` are left untouched

## S-UNINSTALL-03: brew packages preserved by default

GIVEN uninstall.sh is run without `--brew`
THEN Homebrew and Brewfile packages are NOT uninstalled
(they may be shared with other tools)

GIVEN uninstall.sh is run with `--brew`
THEN `brew bundle cleanup` is run to remove the Brewfile packages
