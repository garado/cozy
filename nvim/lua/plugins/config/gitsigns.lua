
-- █▀▀ █ ▀█▀ █▀ █ █▀▀ █▄░█ █▀ 
-- █▄█ █ ░█░ ▄█ █ █▄█ █░▀█ ▄█ 

local present, gitsigns = pcall(require, "gitsigns")
if not present then return end

gitsigns.setup({
  signs = {
    add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
    change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
    delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
    topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
    changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
  },
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
})
