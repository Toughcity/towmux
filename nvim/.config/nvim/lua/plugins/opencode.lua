return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    {
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    vim.g.opencode_opts = {}
    vim.o.autoread = true

    local map = vim.keymap.set
    map({ "n", "t" }, "<leader>oo", function() require("opencode").toggle() end,                              { desc = "Toggle OpenCode" })
    map({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end,    { desc = "Ask OpenCode" })
    map({ "n", "x" }, "<leader>os", function() require("opencode").select() end,                              { desc = "OpenCode Select Action" })
    map("n",          "<leader>on", function() require("opencode").command("session.new") end,                { desc = "OpenCode New Session" })
    map("n",          "<leader>ol", function() require("opencode").command("session.select") end,             { desc = "OpenCode List Sessions" })
    map({ "n", "x" }, "go",        function() return require("opencode").operator("@this ") end,             { desc = "Add Range to OpenCode", expr = true })
    map("n",          "goo",       function() return require("opencode").operator("@this ") .. "_" end,      { desc = "Add Line to OpenCode", expr = true })
  end,
}
