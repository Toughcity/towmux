---
name: task-runner-skill
description: Author VSCode-format run/debug task configs for the current project. Use when asked to create a run task, debug config, or "task" for a project, or when towmux's run/debug picker (<leader>r?) hands off a natural-language request from the nvim `ai` window. Detects the tech stack and writes .vscode/tasks.json (run) or .vscode/launch.json (debug).
metadata:
  author: towmux
  version: "1.0"
---

# Task Runner Skill

Generate run and debug task definitions for a project in VSCode JSON format.
towmux's neovim picker (`<leader>r?`) consumes these natively:

- `.vscode/tasks.json` → listed and run by **overseer.nvim** (`[run]` entries)
- `.vscode/launch.json` → loaded and launched by **nvim-dap** (`[debug]` entries)

Both files are project-local and portable to real VSCode/Zed.

## Workflow

### 1. Detect the tech stack

Inspect the project root for manifests. Pick the first that matches; if several
coexist (e.g. a frontend + backend), generate a task per runnable unit.

| Marker | Stack | Run command | Debug adapter `type` |
|--------|-------|-------------|----------------------|
| `*.csproj` / `*.sln` | .NET | `dotnet run --project <proj>` | `coreclr` (netcoredbg) |
| `package.json` | Node | the `scripts` entries (`npm run <name>`) | `pwa-node` (js-debug) |
| `go.mod` | Go | `go run ./<main pkg>` | `go` (delve) |
| `Cargo.toml` | Rust | `cargo run` | `lldb` / `codelldb` |
| `Makefile` | make | each phony target (`make <target>`) | — |
| `pyproject.toml` / `requirements.txt` | Python | `python <entry>` | `python` (debugpy) |

If **no** marker is found, ask the user for the exact command rather than
guessing.

### 2. Decide run vs debug from the request

- Request mentions **debug, breakpoints, step through, attach** → write
  `.vscode/launch.json`.
- Otherwise (run, build, test, watch, serve, start) → write `.vscode/tasks.json`.

### 3. Prefer surfacing what already exists

Do **not** invent commands that the project already declares. Map directly to:

- `package.json` `scripts` → one task per script
- `Makefile` phony targets → one task per target
- multiple `*.csproj` → one task per project

Only invent for genuine gaps — e.g. a compound "API + watch" the manifests don't
express. Use `dependsOn` / compound tasks for multi-step run flows.

### 4. Choose concise names

Short, lowercase, descriptive: `dev`, `api`, `test`, `build`, `watch`. Make the
educated best guess for the primary entry point of the stack.

### 5. Write valid VSCode JSON

The output must be schema-valid so overseer lists it and nvim-dap loads it
without manual edits.

`.vscode/tasks.json` (run):

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "dev",
      "type": "shell",
      "command": "dotnet run --project src/Api",
      "problemMatcher": []
    }
  ]
}
```

`.vscode/launch.json` (debug) — pick the `type` from the table above:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug API",
      "type": "coreclr",
      "request": "launch",
      "program": "${workspaceFolder}/src/Api/bin/Debug/net8.0/Api.dll",
      "cwd": "${workspaceFolder}/src/Api"
    }
  ]
}
```

If the file already exists, merge the new entry into the existing array rather
than overwriting it.

### 6. Report the file path

After writing, tell the user the exact path (e.g. `.vscode/tasks.json`) so they
can re-run `<leader>r?` and find the new entry.
