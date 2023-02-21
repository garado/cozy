
-- █ █▄░█ █ ▀█▀ 
-- █ █░▀█ █ ░█░ 

require("core.settings")
require("plugins")
require("core.mappings")

vim.cmd('hi DiffAdd guifg=#2e3440 guibg=#a3be8c')
vim.cmd('hi DiffChange guifg=#2e3440 guibg=#ebcb8b')
vim.cmd('hi DiffDelete guifg=#2e3440 guibg=#bf616a')

vim.cmd('let g:vimwiki_hl_headers = 1')
vim.cmd('hi VimwikiHeader1 guifg=#bf616a gui=bold')
vim.cmd('hi VimwikiHeader2 guifg=#d08770 gui=bold')
vim.cmd('hi VimwikiHeader3 guifg=#ebcb8b gui=bold')
vim.cmd('hi VimwikiHeader4 guifg=#a3be8c gui=bold')
vim.cmd('hi VimwikiHeader5 guifg=#b48ead gui=bold')
vim.cmd('hi VimwikiHeader6 guifg=#8fbcbb gui=bold')
vim.cmd('hi VimwikiItalic guifg=#2e3440 guibg=#d8dee9')
vim.cmd('hi VimwikiBold guifg=#bf616a guibg=#d8dee9')
