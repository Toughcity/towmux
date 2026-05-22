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

-- smart-splits.nvim — C-hjkl moves and A-hjkl resize seamlessly across nvim
-- splits and tmux panes. Set here (not in the plugin spec) so they override
-- LazyVim's own <C-hjkl> nav and <A-j>/<A-k> move-line defaults, which load
-- earlier on VeryLazy.
local smart_splits = {
  ["<C-h>"] = "move_cursor_left",
  ["<C-j>"] = "move_cursor_down",
  ["<C-k>"] = "move_cursor_up",
  ["<C-l>"] = "move_cursor_right",
  ["<A-h>"] = "resize_left",
  ["<A-j>"] = "resize_down",
  ["<A-k>"] = "resize_up",
  ["<A-l>"] = "resize_right",
}

for lhs, fn in pairs(smart_splits) do
  vim.keymap.set("n", lhs, function()
    require("smart-splits")[fn]()
  end, { desc = "smart-splits: " .. fn:gsub("_", " ") })
end
