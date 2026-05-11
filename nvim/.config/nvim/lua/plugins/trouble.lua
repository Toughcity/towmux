local uv = vim.uv or vim.loop

--- Jump action for LSP trouble items.
--- Uses vim.lsp.util.show_document so that encoding and buffer loading are
--- handled correctly. Detects OmniSharp metadata/source-generated URIs that
--- have no on-disk file and warns instead of crashing.
---@param view trouble.View
---@param ctx {item?: trouble.Item, node?: trouble.Node}
local function lsp_jump(view, ctx)
  if not ctx.item then
    if ctx.node then view:fold(ctx.node) end
    return
  end

  local item = ctx.item

  -- Non-LSP items (diagnostics, quickfix, etc.) use trouble's built-in jump.
  if not (item.item and item.item.location and item.item.client_id) then
    view:jump(item)
    return
  end

  local client = vim.lsp.get_client_by_id(item.item.client_id)
  if not client then
    view:jump(item)
    return
  end

  local location = item.item.location
  local uri = location.uri or location.targetUri or ""
  local fname = vim.uri_to_fname(uri)

  -- OmniSharp returns $metadata$ or source-generated URIs for framework/
  -- decompiled types. These have no file on disk; bufload silently fails and
  -- nvim_win_set_cursor then throws on the empty buffer. Warn and bail out.
  if not uv.fs_stat(fname) then
    vim.notify(
      ("'%s' is a metadata or source-generated file — use gd from the editor to navigate there"):format(
        vim.fn.fnamemodify(fname, ":t")
      ),
      vim.log.levels.WARN
    )
    return
  end

  view:goto_main()
  if vim.lsp.util.show_document then
    vim.lsp.util.show_document(location, client.offset_encoding, { reuse_win = true })
  else
    vim.lsp.util.jump_to_location(location, client.offset_encoding, true)
  end
end

return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      lsp = {
        win = { position = "right" },
        focus = true,
        keys = {
          ["<cr>"] = lsp_jump,
          ["<2-leftmouse>"] = lsp_jump,
        },
      },
    },
  },
}
