-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>?", function()
  vim.cmd("e ~/.config/nvim/CHEATSHEET.md")
end, { desc = "Open Cheatsheet" })

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
