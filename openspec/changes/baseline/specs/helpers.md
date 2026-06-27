# Specs: tterm and tnew

## S-TTERM-01: add a terminal window

GIVEN the user runs `tterm` inside a tmux session
THEN a new window named `term` is created in the current session
AND focus switches to it

## S-TTERM-02: auto-numbered windows

GIVEN a window named `term` already exists
WHEN tterm is run again
THEN the new window is named `term-2`; a third run creates `term-3`; and so on
AND the highest available number is always used

## S-TTERM-03: new window inherits current path

GIVEN the user runs `tterm` while in a specific directory
THEN the new window opens with that directory as its working directory

## S-TTERM-04: must be inside tmux

GIVEN the user runs `tterm` outside of tmux
THEN an error is printed and the script exits

---

## S-TNEW-01: named scratch session

GIVEN the user runs `tnew foo`
THEN a tmux session named `foo` is created (or attached to, if it exists)
AND a single default window is opened with the current directory as cwd
AND no nvim or claude are launched automatically

## S-TNEW-02: auto-named scratch session

GIVEN the user runs `tnew` with no arguments
THEN the session is named `scratch`
AND if `scratch` already exists, `scratch-2` is tried, then `scratch-3`, and so on

## S-TNEW-03: attach vs switch

GIVEN the user runs `tnew` from outside tmux
THEN `tmux attach-session` is used

GIVEN the user runs `tnew` from inside tmux
THEN `tmux switch-client` is used (avoids nested session prompt)
