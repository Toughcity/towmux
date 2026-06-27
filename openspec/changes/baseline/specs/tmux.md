# Specs: tmux/.config/tmux/tmux.conf

## S-TMUX-01: prefix key

GIVEN the tmux config is loaded
THEN the prefix is `C-Space` (Ctrl+Space)
AND the default `C-b` prefix is unbound
AND `C-Space C-Space` sends the literal prefix key through to the active pane
AND `Space` alone is unbound at the tmux level (so nvim's Space leader is never intercepted)

## S-TMUX-02: nvim compatibility settings

GIVEN the tmux config is loaded
THEN `escape-time` is set to 0 (no delay after Esc — required for nvim to respond instantly)
AND `focus-events on` is set (allows nvim to trigger `autoread` when the pane gains focus)
AND `extended-keys on` is set (passes CSI u sequences through, needed by TUI apps including claude)

## S-TMUX-03: seamless nvim ↔ tmux pane navigation (smart-splits)

GIVEN smart-splits.nvim is active in a pane (the pane option `@pane-is-vim` is set)
WHEN `C-h`, `C-j`, `C-k`, or `C-l` is pressed without a prefix
THEN the key is forwarded into nvim (navigates nvim splits)

GIVEN the focused pane does NOT have `@pane-is-vim` set
WHEN `C-h`, `C-j`, `C-k`, or `C-l` is pressed without a prefix
THEN the corresponding tmux pane direction is selected

AND the same C-hjkl bindings also work inside copy-mode-vi to navigate panes

## S-TMUX-04: pane resizing

GIVEN any pane is focused
THEN `M-h/j/k/l` (Alt+hjkl, no prefix) resizes the pane by 3 cells in the corresponding direction
AND when the focused pane has `@pane-is-vim`, the resize key is forwarded into nvim instead
AND `prefix+H/J/K/L` also resizes panes by 5 cells (repeatable with `-r`)
AND `prefix+h/j/k/l` navigates between panes (prefix-based, always tmux-side)

## S-TMUX-05: splits and new windows

GIVEN `prefix+|` is pressed
THEN the current window is split vertically (left/right), inheriting the current pane's path

GIVEN `prefix+-` is pressed
THEN the current window is split horizontally (top/bottom), inheriting the current pane's path

GIVEN `prefix+c` is pressed
THEN a new window is created inheriting the current pane's path

GIVEN `prefix+=` is pressed
THEN the next tmux layout preset is cycled (even-horizontal → even-vertical → main-vertical → tiled → …)

## S-TMUX-06: named window shortcuts

GIVEN the current session follows the towmux naming convention
THEN `prefix+e` switches to the window named `code` (the nvim editor window)
AND `prefix+i` switches to the window named `ai` (the claude window)
AND `prefix+o` switches to the window named `term` (the terminal window)
AND if the named window doesn't exist in the current session, the key does nothing (silently)

## S-TMUX-07: Alt+number window switching

GIVEN any pane is focused
THEN `M-1` through `M-5` (Alt+number, no prefix) switch directly to windows 1–5 respectively
AND this works from inside nvim without interference because nvim does not bind Alt+numbers by default

## S-TMUX-08: session navigation

GIVEN `prefix+s` is pressed
THEN the session/window tree is displayed (zoomable, navigate with j/k/Enter)

GIVEN `prefix+(` or `prefix+)` is pressed
THEN the client switches to the previous or next session respectively

## S-TMUX-09: workflow shortcuts

GIVEN `prefix+T` is pressed
THEN `tterm` is run (adds a new `term-N` window to the current session)

GIVEN `prefix+r` is pressed
THEN `~/.config/tmux/tmux.conf` is reloaded and a "tmux reloaded" message is displayed

GIVEN `prefix+P` is pressed
THEN a prompt "pull window:" is shown; the entered window name is pulled in as a horizontal split

GIVEN `prefix+B` is pressed
THEN a prompt "break to name:" is shown; the current pane is broken out into a new window with that name

GIVEN `prefix+L` is pressed
THEN `tlayout` is launched in a popup (70% wide, 40% tall) for interactive layout switching

## S-TMUX-10: copy mode

GIVEN `prefix+Enter` is pressed
THEN copy mode is entered (vi key bindings)

GIVEN the user is in copy mode
THEN `v` begins a visual selection
AND `y` copies the selection to the macOS clipboard via `pbcopy` and exits copy mode
AND `Escape` cancels and exits copy mode

## S-TMUX-11: status bar — position and style

GIVEN the tmux config is loaded
THEN the status bar is positioned at the TOP of the terminal (not the bottom)
AND the status bar background is `#24283b` (Tokyo Night Surface1)
AND the status bar foreground is `#c0caf5` (Tokyo Night Foreground)
AND the status bar refreshes every 5 seconds

## S-TMUX-12: status bar — left segment

GIVEN a tmux session is active
THEN the left side of the status bar shows the session name in a purple (`#bb9af7`) Powerline block
AND a chevron separator transitions from the purple block to a blue (`#7aa2f7`) block

## S-TMUX-13: status bar — right segment

GIVEN a tmux session is active
THEN the right side shows two Powerline segments:
1. The session root path (tilde-abbreviated) on a grey (`#414868`) block
2. The current git branch of the active pane's working directory on a green (`#9ece6a`) block
AND if the active pane is not inside a git repo, the branch segment shows `—`
AND each segment has a left-pointing triangle transition from the bar background

## S-TMUX-14: window tabs — color coding

GIVEN multiple windows exist in a session
THEN each window tab is colored by its index position:
- Index 1 → blue (`#7aa2f7`)
- Index 2 → green (`#9ece6a`)
- Index 3 → orange (`#ff9e64`)
- Index 4 → purple (`#bb9af7`)
- Index 5+ → cyan (`#7dcfff`)
AND each tab has a right-pointing arrow whose color matches the NEXT tab's background (chaining effect)
AND the final tab's arrow uses the status bar background (no dangling separator)
AND the active window's tab text is bold

## S-TMUX-15: pane border labels (IDE layout)

GIVEN the global default
THEN `pane-border-status` is `off` (no pane title labels in windows-layout)

GIVEN the IDE layout is active and `pane-border-status top` is set per-window (by `tp` or `tlayout`)
THEN each pane shows a centered label at its top border
AND the label reads the `@layout-name` option of the pane (e.g. `code`, `ai`, `term`)
AND the active pane's label background is orange (`#ff9e64`); inactive panes use grey (`#414868`)
AND the label has a Powerline taper on both sides (left `` and right `` triangles)
AND pane borders are a single uniform blue (`#7aa2f7`) color (active and inactive borders match)

## S-TMUX-16: terminal tab title

GIVEN `set-titles on` is configured
THEN tmux emits an OSC title sequence with the session name (`#S`)
AND the host terminal's tab/window title shows the current session name (project name)
AND this works in Ghostty, iTerm2, and Apple Terminal

## S-TMUX-17: window base index and renumbering

GIVEN the tmux config is loaded
THEN windows are numbered starting from 1 (not 0)
AND panes are numbered starting from 1
AND when a window is closed, remaining windows are automatically renumbered to stay contiguous

## S-TMUX-18: clipboard and mouse

GIVEN the tmux config is loaded
THEN mouse support is enabled (click to select panes/windows, scroll to scroll history)
AND `set-clipboard on` is set (tmux integrates with the terminal's clipboard stack)
