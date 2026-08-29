## ADDED Requirements

### Requirement: Detect project tech stack
The skill SHALL inspect the project to determine its tech stack before generating any task or debug configuration.

#### Scenario: Recognize common stacks
- **WHEN** the skill runs in a project containing a recognizable manifest (`package.json`, `*.csproj`/`*.sln`, `go.mod`, `Cargo.toml`, or `Makefile`)
- **THEN** the skill identifies the corresponding stack and the conventional run/debug commands for it

#### Scenario: Unknown stack
- **WHEN** no recognizable manifest is found
- **THEN** the skill asks the user for the run/debug command rather than guessing

### Requirement: Surface existing declared tasks
The skill SHALL prefer surfacing commands already declared in the project's manifests over inventing new ones, inventing only to fill gaps (e.g. multi-step commands).

#### Scenario: Reuse declared scripts
- **WHEN** the project declares runnable entries (e.g. npm `scripts`, `Makefile` targets, multiple `*.csproj` projects)
- **THEN** the generated tasks map to those declared entries with concise, descriptive names

### Requirement: Run-vs-debug intent detection
The skill SHALL decide which configuration file to generate based on the user's request: a debugging request produces a `.vscode/launch.json` nvim-dap configuration; otherwise it produces a `.vscode/tasks.json` overseer task.

#### Scenario: Run request
- **WHEN** the user's request describes running, building, testing, or watching
- **THEN** the skill writes or extends `.vscode/tasks.json`

#### Scenario: Debug request
- **WHEN** the user's request mentions debugging or breakpoints
- **THEN** the skill writes or extends `.vscode/launch.json` with the correct adapter `type` for the detected stack (e.g. `coreclr`/netcoredbg for dotnet, `go`/delve, `python`/debugpy, `node`/js-debug, `lldb`/codelldb)

### Requirement: Valid VSCode-format output
Generated `tasks.json` and `launch.json` SHALL be valid VSCode-format JSON that overseer and nvim-dap can consume without manual edits.

#### Scenario: Output is consumable
- **WHEN** the skill writes a configuration file
- **THEN** the file conforms to the VSCode tasks/launch schema such that overseer lists the task and nvim-dap loads the debug config
