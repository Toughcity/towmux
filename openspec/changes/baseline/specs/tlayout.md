# Specs: tlayout — live layout conversion

## S-TLAYOUT-01: pick target layout interactively

GIVEN the user runs `tlayout` with no arguments (or via prefix+L popup)
THEN fzf opens with `windows` and `ide` as options and a live ASCII preview
AND the selected layout is applied

## S-TLAYOUT-02: explicit target

GIVEN the user runs `tlayout ide` or `tlayout windows`
THEN the picker is skipped and that layout is applied directly

## S-TLAYOUT-03: no-op when already on target layout

GIVEN the current session is already in the `ide` layout
WHEN the user runs `tlayout ide`
THEN a message "tlayout: already ide" is displayed and no changes are made

## S-TLAYOUT-04: windows → ide conversion

GIVEN the session is in windows layout (separate `code`, `ai`, `term` windows)
WHEN the user converts to `ide`
THEN the `code` window becomes the base `ide` window
AND the `term` window pane is joined as a bottom strip (30% height)
AND the `ai` window pane is joined as a top-right strip (30% width)
AND any `run-*` windows are joined into the bottom strip as horizontal splits
AND each pane is tagged @layout-name so the conversion is reversible
AND pane-border-status is set to `top`
AND running processes in all moved panes are preserved

## S-TLAYOUT-05: ide → windows conversion

GIVEN the session is in ide layout (tagged panes in a single multi-pane window)
WHEN the user converts to `windows`
THEN the first pane stays and its window is renamed after its @layout-name tag
AND every other pane is broken out into its own window named after its @layout-name
AND the @layout-name tags are cleared
AND pane-border-status is reverted to global default (off)
AND running processes survive

## S-TLAYOUT-06: layout detection

GIVEN any pane in the session has a non-empty @layout-name option
THEN the current layout is detected as `ide`
OTHERWISE the current layout is detected as `windows`

## S-TLAYOUT-07: must be inside tmux

GIVEN the user runs `tlayout` outside of tmux
THEN an error is printed and the script exits with code 1
