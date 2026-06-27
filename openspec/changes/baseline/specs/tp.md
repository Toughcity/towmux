# Specs: tp — project picker

## S-TP-01: fuzzy-pick from known projects and running sessions

GIVEN the user runs `tp` with no arguments
WHEN there are directories under CODE_DIRS and/or running tmux sessions
THEN fzf opens with running sessions listed first (marked ●), idle projects below
AND the user can press Enter to open/attach or Ctrl-X to kill a running session

## S-TP-02: current directory shortcut

GIVEN the user runs `tp .` from a project directory
THEN that directory is used as the project target without showing the picker

## S-TP-03: explicit path

GIVEN the user runs `tp <path>`
THEN that path is used as the project target without showing the picker

## S-TP-04: session creation — layout prompt

GIVEN the resolved target has no existing tmux session
WHEN TP_LAYOUT is not set in the environment
THEN fzf opens a layout picker with live ASCII preview of each option
AND the user must choose `windows` or `ide` before the session is created

## S-TP-05: session creation — TP_LAYOUT env var

GIVEN TP_LAYOUT=ide (or windows) is set in the environment
WHEN a new session is needed
THEN the layout picker is skipped and that layout is used directly

## S-TP-06: windows layout

GIVEN layout=windows is chosen
THEN a session is created with three windows: `code` (nvim), `ai` (claude), `term`
AND nvim is launched in `code`, claude is launched in `ai` (if `claude` is on PATH)
AND `code` window is focused on attach

## S-TP-07: ide layout

GIVEN layout=ide is chosen
THEN a single `ide` window is created with three panes
AND nvim fills the left pane (~70% width)
AND claude fills the top-right pane (~30% width)
AND a terminal strip fills the bottom (~30% height)
AND each pane is tagged @layout-name (code / ai / term)
AND pane-border-status is set to `top` so pane titles are visible

## S-TP-08: attach to existing session

GIVEN the resolved target already has a running tmux session
THEN tp attaches to it (or switches to it if already inside tmux)
AND no layout prompt is shown

## S-TP-09: session naming

GIVEN a target directory path
THEN the session name is basename(path), lowercased, with spaces and dots replaced by `-`
AND this name is deterministic (same path always → same session name)

## S-TP-10: kill session from picker

GIVEN the fzf picker is open and a running session is highlighted
WHEN the user presses Ctrl-X
THEN that session is killed silently and the picker list reloads
