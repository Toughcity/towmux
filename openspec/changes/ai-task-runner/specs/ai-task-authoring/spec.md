## ADDED Requirements

### Requirement: Capture a natural-language task request
When the user chooses to create a task from the picker's empty-state, the system SHALL prompt for a free-text description of what they want to run or debug.

#### Scenario: User describes a task
- **WHEN** the user selects "create one" in the empty-state picker
- **THEN** an input prompt appears where the user types what they need (e.g. "run the API and watch for changes")

#### Scenario: User cancels creation
- **WHEN** the user dismisses the input prompt without entering text
- **THEN** no handoff is sent and no files are created

### Requirement: Hand the request to the project AI pane
The system SHALL send the user's request, combined with the task-runner skill instructions, to the project's `ai` tmux window so that Claude can author the configuration.

#### Scenario: Prompt is delivered to the ai window
- **WHEN** the user submits a task description
- **THEN** the system sends the description plus skill-invoking instructions to the session's `ai` window via `tmux send-keys`
- **AND** focus is given to the `ai` window so the user can observe Claude working

#### Scenario: AI window is missing
- **WHEN** the current session has no `ai` window
- **THEN** the system reports that the `ai` window is unavailable rather than sending keys to the wrong target

### Requirement: Generated config is written and reported
Claude SHALL write the generated configuration directly to the appropriate project file and report the file path to the user upon completion.

#### Scenario: Config file is created and named
- **WHEN** Claude finishes authoring the task
- **THEN** the resulting `.vscode/tasks.json` or `.vscode/launch.json` file is written to the project
- **AND** the file path is stated back to the user so they can locate it

#### Scenario: Re-opening the picker shows the new task
- **WHEN** the user re-triggers `<leader>r?` after the file has been written
- **THEN** the newly authored task appears as a selectable entry in the picker
