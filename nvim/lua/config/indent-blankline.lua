
-- █ █▄░█ █▀▄ █▀▀ █▄░█ ▀█▀    █▄▄ █░░ ▄▀█ █▄░█ █▄▀ █░░ █ █▄░█ █▀▀ 
-- █ █░▀█ █▄▀ ██▄ █░▀█ ░█░    █▄█ █▄▄ █▀█ █░▀█ █░█ █▄▄ █ █░▀█ ██▄ 

local present, blankline = pcall(require, "indent_blankline")
if not present then return end

vim.opt.list = true

vim.cmd('hi IndentBlanklineChar guifg=named_colors.black')

blankline.setup({
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
})
