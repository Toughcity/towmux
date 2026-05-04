return {
  "b0o/incline.nvim",
  event = "BufReadPre",
  opts = {
    window = {
      padding = 1,
      margin = { horizontal = 1, vertical = 0 },
    },
    render = function(props)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      if filename == "" then
        filename = "[No Name]"
      end
      local modified = vim.bo[props.buf].modified
      local icon, icon_hl = require("nvim-web-devicons").get_icon(filename)

      if props.focused then
        return {
          { " ", guibg = "#1e1e2e" },
          icon and { icon, " ", group = icon_hl, guibg = "#313244" } or "",
          { filename, guifg = "#cba6f7", guibg = "#313244", gui = modified and "bold,italic" or "bold" },
          modified and { "  ", guifg = "#e0af68", guibg = "#313244" } or { " ", guibg = "#313244" },
        }
      else
        return {
          icon and { icon, " ", guifg = "#45475a" } or "",
          { filename, guifg = "#45475a", gui = "none" },
          modified and { "  ", guifg = "#45475a" } or "",
        }
      end
    end,
  },
}
