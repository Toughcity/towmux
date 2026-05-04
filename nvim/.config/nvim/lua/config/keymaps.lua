-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>?", function()
  vim.cmd("e ~/.config/nvim/CHEATSHEET.md")
end, { desc = "Open Cheatsheet" })

local agents = {
  { label = "Claude", cmd = "claude" },
  { label = "Codex",  cmd = "codex" },
}

local function open_ai_agent()
  vim.ui.select(agents, {
    prompt = "Select AI agent:",
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end
    if vim.fn.executable(choice.cmd) == 0 then
      vim.notify(choice.label .. " is not installed or not available on PATH", vim.log.levels.WARN)
      return
    end
    vim.cmd("botright 80vsplit | terminal " .. choice.cmd)
    vim.cmd("startinsert")
  end)
end

vim.keymap.set({ "n", "x" }, "<leader>ai", open_ai_agent, { desc = "Open AI Agent" })

local window_moves = {
  h = { command = "H", desc = "Move Window Left" },
  j = { command = "J", desc = "Move Window Down" },
  k = { command = "K", desc = "Move Window Up" },
  l = { command = "L", desc = "Move Window Right" },
}

for key, move in pairs(window_moves) do
  vim.keymap.set("n", "<leader>a" .. key, "<C-w>" .. move.command, { desc = move.desc })
  vim.keymap.set("t", "<C-w>" .. move.command, "<C-\\><C-n><C-w>" .. move.command, { desc = move.desc })
end
