# Specs: trun — named run configurations

## S-TRUN-01: run named config from .trun file

GIVEN a `.trun` file exists in the session's project root
AND a config named `frontend` is defined as `frontend: npm run dev`
WHEN the user runs `trun frontend`
THEN a window named `run-frontend` is created (or reused) in the current session
AND the command `npm run dev` is sent to that window

## S-TRUN-02: fuzzy-pick config when no name given

GIVEN a `.trun` file exists with at least one config
WHEN the user runs `trun` with no arguments
THEN fzf opens with available config names
AND the selected config is run as in S-TRUN-01

## S-TRUN-03: ad-hoc command in default run window

GIVEN the user runs `trun -- <cmd>`
THEN a window named `run` is created (or reused)
AND `<cmd>` is sent to it

## S-TRUN-04: ad-hoc command in named window

GIVEN the user runs `trun <name> -- <cmd>`
THEN a window named `run-<name>` is created (or reused)
AND `<cmd>` is sent to it (ignoring any .trun config for that name)

## S-TRUN-05: restart behavior

GIVEN the target window already exists and is running a process
WHEN trun is called again for the same config
THEN Ctrl-C is sent first (to stop the existing process)
THEN Ctrl-U clears any partial input
THEN the new command is sent

## S-TRUN-06: error when no .trun and no ad-hoc command

GIVEN no `.trun` file exists in the project root
AND trun is called without `--`
THEN an error message is printed with usage instructions explaining .trun format

## S-TRUN-07: must be run inside tmux

GIVEN the user runs `trun` outside of a tmux session
THEN an error message is printed: "trun: not inside tmux"
AND the script exits with code 1

## S-TRUN-08: .trun file format

GIVEN a `.trun` file
THEN lines matching `<name>: <command>` are valid configs
AND lines starting with `#` are treated as comments
AND leading/trailing whitespace around the command is stripped
