

-- █░█ █ █▀▄▀█ █▀█ █░░ █░█ █▀▀ 
-- ▀▄▀ █ █░▀░█ █▀▀ █▄▄ █▄█ █▄█ 

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
  Plug 'vimwiki/vimwiki'
vim.call('plug#end')

vim.cmd('source $HOME/.config/nvim/lua/config.vimwiki/vimwiki.vim')
