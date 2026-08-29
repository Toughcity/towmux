-- Debugging stack. The `lazyvim.plugins.extras.dap.core` extra (enabled in
-- lazyvim.json) pulls in nvim-dap, nvim-dap-ui, nvim-dap-virtual-text and
-- mason-nvim-dap with default adapter handlers.
--
-- nvim-dap reads `.vscode/launch.json` natively, so debug configs live in the
-- project (VSCode/Zed-portable) and are surfaced by the towmux run/debug picker
-- (<leader>r?). See lua/util/task_picker.lua.
--
-- netcoredbg (dotnet) is already installed by the lang.dotnet extra; this file
-- ensures the adapters for the other stacks towmux targets.
return {
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    -- mason-nvim-dap's default handlers auto-wire each installed debugger.
    ensure_installed = {
      "delve", -- go
      "python", -- debugpy
      "codelldb", -- c / c++ / rust
      "js", -- js-debug (node / browser)
    },
  },
}
