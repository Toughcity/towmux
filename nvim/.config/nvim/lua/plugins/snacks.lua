-- Project search roots come from $DEV_DIRS (colon-separated, like $PATH).
-- Override in ~/.zshrc.local: export DEV_DIRS="$HOME/Code:$HOME/Work"
local function dev_dirs()
  local raw = vim.env.DEV_DIRS or "~/Code"
  local dirs = {}
  for dir in raw:gmatch("[^:]+") do
    table.insert(dirs, dir)
  end
  return dirs
end

return {
  "folke/snacks.nvim",
  opts = {
    -- Dashboard only when not inside a git project.
    -- Project startup (README / empty buffer) is handled in autocmds.lua.
    dashboard = {
      enabled = vim.fn.finddir(".git", vim.fn.getcwd() .. ";") == "",
    },
    picker = {
      sources = {
        projects = {
          dev = dev_dirs(),
        },
        explorer = {
          exclude = { "*.uid" },
        },
      },
    },
  },
}
