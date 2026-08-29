-- Unified run/debug task picker for towmux.
--
-- One keymap (<leader>r?) lists, in a single snacks picker:
--   [run]   overseer templates, including those read from .vscode/tasks.json
--   [debug] nvim-dap configs, including those read from .vscode/launch.json
--
-- Run entries start if idle, or restart (kill + rerun) if already running, so a
-- run is always a re-run. Each task keeps its own overseer terminal buffer,
-- toggled with <leader>rt. Debug entries launch nvim-dap so breakpoints set in
-- the editor are honored.
--
-- When a project has no tasks, the picker offers AI-assisted creation: it sends
-- a natural-language request to the project's tmux `ai` window so Claude can
-- author the config (see .claude/skills/task-runner-skill).

local M = {}

-- ── run tasks (overseer) ───────────────────────────────────────────────
-- Start the named template, or restart it if a task by that name is running.
local function run_or_restart(name)
  local overseer = require("overseer")
  local running = overseer.list_tasks({ name = name })
  if #running > 0 then
    for _, task in ipairs(running) do
      task:restart(true) -- force: stop the live instance, then run again
    end
    overseer.open({ enter = false })
  else
    overseer.run_template({ name = name }, function(task)
      if task then
        overseer.open({ enter = false })
      end
    end)
  end
end

-- ── debug configs (nvim-dap) ───────────────────────────────────────────
-- User-defined debug configs from the project's .vscode/launch.json.
--
-- Deliberately NOT dap.configurations[ft]: that also contains the generic
-- "Launch file" defaults every language extra registers, which would make the
-- empty-state (see M.open) never fire for real projects. getconfigs() reads only
-- launch.json (with vscode-variable handling) and returns {} when it's absent.
local function debug_configs()
  local ok, vscode = pcall(require, "dap.ext.vscode")
  if not ok then
    return {}
  end
  return vscode.getconfigs() or {}
end

-- ── AI-assisted task authoring ─────────────────────────────────────────
-- Hand a natural-language request to the project's tmux `ai` window so Claude
-- can author .vscode/tasks.json or launch.json and report the file path.
local function create_via_ai()
  if not vim.env.TMUX then
    vim.notify("Task creation needs the tmux `ai` window (not inside tmux).", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Describe the task to run/debug: " }, function(desc)
    if not desc or desc == "" then
      return
    end
    local session = vim.fn.systemlist("tmux display-message -p '#S'")[1]
    local windows = vim.fn.systemlist("tmux list-windows -t " .. vim.fn.shellescape(session) .. " -F '#W'")
    if not vim.tbl_contains(windows, "ai") then
      vim.notify("No `ai` window in this session — cannot hand off to Claude.", vim.log.levels.ERROR)
      return
    end
    local target = session .. ":ai"
    local prompt = string.format(
      "Use the task-runner-skill to create a run/debug task for this project (%s). "
        .. "What I want: %s. Detect the stack, write the config to .vscode/tasks.json "
        .. "(or .vscode/launch.json if this is a debug request), then tell me the file path.",
      vim.fn.getcwd(),
      desc
    )
    vim.fn.system({ "tmux", "send-keys", "-t", target, prompt, "Enter" })
    vim.fn.system({ "tmux", "select-window", "-t", target })
    vim.notify("Sent to the `ai` window. Re-run <leader>r? once the file is written.", vim.log.levels.INFO)
  end)
end

-- ── picker ─────────────────────────────────────────────────────────────
local function build_items(templates)
  local overseer = require("overseer")
  local items = {}
  for _, tmpl in ipairs(templates or {}) do
    -- Mark running tasks so it's clear the entry will restart, not duplicate.
    local running = #overseer.list_tasks({ name = tmpl.name }) > 0
    local marker = running and " ●" or ""
    items[#items + 1] = { text = "[run]   " .. tmpl.name .. marker, kind = "run", name = tmpl.name }
  end
  for _, cfg in ipairs(debug_configs()) do
    items[#items + 1] = { text = "[debug] " .. cfg.name, kind = "debug", config = cfg }
  end
  return items
end

local function open_picker(items)
  if #items == 0 then
    vim.ui.select({ "Create a task with AI…" }, { prompt = "No run/debug tasks found" }, function(choice)
      if choice then
        create_via_ai()
      end
    end)
    return
  end
  Snacks.picker.pick({
    title = "Run / Debug",
    items = items,
    format = "text",
    preview = false, -- items are tasks, not files; the default previewer errors on them
    layout = { preview = false },
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      if item.kind == "run" then
        run_or_restart(item.name)
      else
        require("dap").run(item.config)
      end
    end,
  })
end

-- Entry point bound to <leader>r?. Overseer template listing is async.
function M.open()
  require("overseer.template").list({ dir = vim.fn.getcwd() }, function(templates)
    vim.schedule(function()
      open_picker(build_items(templates))
    end)
  end)
end

return M
