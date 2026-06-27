## ADDED Requirements

### Requirement: Unified run/debug picker keymap
The system SHALL provide a single in-editor neovim keymap (`<leader>r?`) that opens one picker listing both run entries and debug entries available for the current project.

#### Scenario: Open picker with available tasks
- **WHEN** the user presses `<leader>r?` in a project that has run and/or debug tasks
- **THEN** a picker opens listing each run entry (sourced from overseer / `.vscode/tasks.json`) tagged `[run]` and each debug entry (sourced from `.vscode/launch.json`) tagged `[debug]`

#### Scenario: Run and debug entries appear in one list
- **WHEN** a project defines both `.vscode/tasks.json` run tasks and `.vscode/launch.json` debug configs
- **THEN** the picker presents both kinds in a single list so the user does not need to remember a separate debug command

### Requirement: Start-or-restart run semantics
When the user selects a run entry, the system SHALL start it if it is not currently running and SHALL restart it (stop the existing instance, then run again) if it is already running.

#### Scenario: Run a task that is not running
- **WHEN** the user selects a `[run]` entry whose overseer task is not currently running
- **THEN** the system creates and starts the task in its own overseer terminal buffer

#### Scenario: Re-run a task that is already running
- **WHEN** the user selects a `[run]` entry whose overseer task is already running
- **THEN** the system stops the running instance and starts it again (restart), rather than spawning a duplicate

#### Scenario: Each task retains its own output buffer
- **WHEN** multiple run tasks are running
- **THEN** each has its own overseer terminal buffer, viewable and toggled via the existing `<leader>rt` task panel

### Requirement: Debug launch honors editor breakpoints
When the user selects a debug entry, the system SHALL start a nvim-dap session using the matching `.vscode/launch.json` configuration so that breakpoints set in the editor are honored.

#### Scenario: Launch a debug configuration
- **WHEN** the user selects a `[debug]` entry
- **THEN** nvim-dap starts a debug session for that configuration and stops at breakpoints the user has placed in the editor

### Requirement: Empty-state offers task creation
When the current project has no run or debug tasks, the picker SHALL present a "create a task" affordance instead of an empty list.

#### Scenario: No tasks exist
- **WHEN** the user presses `<leader>r?` in a project with no `.vscode/tasks.json`, no `.vscode/launch.json`, and no overseer-detectable templates
- **THEN** the picker shows a "no tasks — create one" option that enters the AI task authoring flow
