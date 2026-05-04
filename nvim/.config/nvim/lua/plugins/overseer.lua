return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle", "OverseerRestartLast" },
  keys = {
    { "<leader>rr", "<cmd>OverseerRun<cr>",         desc = "Run task" },
    { "<leader>rt", "<cmd>OverseerToggle<cr>",      desc = "Toggle task panel" },
    { "<leader>rl", "<cmd>OverseerRestartLast<cr>", desc = "Re-run last task" },
  },
  opts = {
    task_list = {
      direction = "bottom",
      min_height = 15,
      max_height = 20,
    },
  },
}
