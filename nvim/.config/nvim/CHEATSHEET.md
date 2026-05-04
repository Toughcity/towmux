# Neovim / LazyVim Cheatsheet

## Meta
- `<Space>?` — open this cheatsheet

## Navigation Between Splits
- `Ctrl+w` → `h/j/k/l` — move left/down/up/right between splits (release Ctrl+w first, then press direction)
- `Ctrl+w` → `H/J/K/L` — move the current split to the left/bottom/top/right edge
- `<Space>ah` / `<Space>aj` / `<Space>ak` / `<Space>al` — move the current split left/down/up/right
- `Ctrl+w` → `q` — close the current split/viewport

## Buffers (Open Files)
- `<Space>,` — switch buffer in current split
- `<Space>bd` — close the current buffer (file)
- `<Space>bb` — switch to previous buffer
- `<S-h>` / `<S-l>` — cycle to previous/next buffer tab

## Splits
- `<Space>|` — split vertically
- `<Space>-` — split horizontally

## File Explorer (Neo-tree)
- `<Space>e` — toggle the file tree open/closed
- `/` — search/filter files while inside the tree
- `Escape` — clear the search in the tree

## Finding Things
- `<Space><Space>` — find files
- `<Space>ff` — find files
- `<Space>fp` — find projects (shows ~/Code and ~/Code-Safad)
- `<Space>fb` — find open buffers
- `<Space>fr` — recent files
- `<Space>sg` — search (grep) inside files
- `p` — open projects (from the dashboard)
- Press `<Space>` and wait — which-key shows a popup of all available commands

## Editing
- `i` — enter insert mode (start typing)
- `Escape` — exit insert mode, go back to normal mode
- `u` — undo
- `Ctrl+r` — redo
- `:e!` — discard all changes since last save (reload file from disk)

## Git (requires lazygit installed: `brew install lazygit`)
- `<Space>gg` — open Lazygit (full git UI)
- Inside Lazygit: `s` stage, `c` commit, `p` push, `P` pull, `?` all keys, `q` quit
- `]h` / `[h` — jump to next/previous changed line (hunk)
- `<Space>gb` — git blame for current line
- `<Space>gs` — stage current hunk
- `<Space>gr` — reset/undo current hunk

## Terminal
- `<Space>ft` — open floating terminal (toggle)
- `<Space>fT` — open terminal in current directory
- `:terminal` — open terminal inside current split
- `Ctrl+\ Ctrl+n` — exit terminal mode (go back to normal mode)

## Tasks (overseer.nvim)
- `<Space>rr` — pick and run a task (Build, Run Game, Run Tests, Build + Run)
- `<Space>rt` — toggle task output panel
- `<Space>rl` — re-run the last task

## Codex / AI
- `<Space>ai` — open Codex in a right-side terminal split
- From the Codex terminal: `Ctrl+w` → `H/J/K/L` — move Codex to the left/bottom/top/right edge

## Understanding Shortcuts
- `<leader>` = `Space`
- `<C-x>` = Ctrl + x
- `<S-x>` = Shift + x
- `<A-x>` = Alt/Option + x
- `<CR>` = Enter

## Key Concepts
- **Buffer** = an open file in memory (may not be visible)
- **Split/Window** = a viewport showing one buffer at a time
- **Conceal** = Neovim hiding quotes/symbols unless your cursor is on that line (disabled in this config)
- Creating a split does NOT duplicate your buffers — all buffers are always accessible from any split via `<Space>,`
- Tabline height cannot be changed in terminal Neovim (use Neovide for GUI rendering)
