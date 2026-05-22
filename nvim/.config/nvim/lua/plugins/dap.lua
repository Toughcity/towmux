-- C# / Godot debugging support.
--
-- The `dap.core` extra (enabled in lazyvim.json) installs nvim-dap, dap-ui and
-- the standard <leader>d debug keymaps. The `lang.dotnet` extra registers the
-- `netcoredbg` adapter and installs the binary via Mason.
--
-- This file only adds project-agnostic glue. The actual debug configs live
-- per-project in `<project>/.vscode/launch.json`, so non-dotnet projects are
-- left untouched.
return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = { "stevearc/overseer.nvim" },
    opts = function()
      local dap = require("dap")

      -- VS Code names the .NET adapter `coreclr`; LazyVim's dotnet extra
      -- registers it as `netcoredbg`. Alias it so a launch.json written for
      -- VS Code also works here unchanged.
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.exepath("netcoredbg"),
        args = { "--interpreter=vscode" },
        options = { detached = false },
      }

      -- Run launch.json preLaunchTask / postDebugTask (e.g. the Godot build
      -- step) through overseer, and let it strip comments from the json.
      pcall(function()
        require("overseer").patch_dap(true)
        require("dap.ext.vscode").json_decode = require("overseer.json").decode
      end)

      -- Load the open project's own .vscode/launch.json, mapping its
      -- `coreclr` configs onto C# buffers.
      pcall(function()
        require("dap.ext.vscode").load_launchjs(nil, {
          coreclr = { "cs" },
          netcoredbg = { "cs" },
        })
      end)
    end,
  },
}
