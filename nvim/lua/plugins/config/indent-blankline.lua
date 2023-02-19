
-- █ █▄░█ █▀▄ █▀▀ █▄░█ ▀█▀    █▄▄ █░░ ▄▀█ █▄░█ █▄▀ █░░ █ █▄░█ █▀▀ 
-- █ █░▀█ █▄▀ ██▄ █░▀█ ░█░    █▄█ █▄▄ █▀█ █░▀█ █░█ █▄▄ █ █░▀█ ██▄ 

local present, blankline = pcall(require, "indent-blankline")
if not present then return end

vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

blankline.setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}
