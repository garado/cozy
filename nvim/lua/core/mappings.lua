
-- █▀▄▀█ ▄▀█ █▀█ █▀█ █ █▄░█ █▀▀ █▀
-- █░▀░█ █▀█ █▀▀ █▀▀ █ █░▀█ █▄█ ▄█

local g = vim.g
local keymap = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

-- Set space as leader key
g.mapleader = [[ ]]
g.maplocalleader = [[ ]]

-- Cancel search highlighting with ESC
keymap("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)


-- █▀█ █░░ █░█ █▀▀ █ █▄░█ █▀
-- █▀▀ █▄▄ █▄█ █▄█ █ █░▀█ ▄█

-- fc     Input Figlet stuff
keymap("n", "fc", ":Fig ", default_opts)

-- Ctrl+n   Toggle NvimTree
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", default_opts)

local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
vim.keymap.set('n', '<leader>fg', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope.help_tags, {})

-- Tabs
vim.keymap.set('n', '<Tab>', ':BufferNext<CR>')
vim.keymap.set('n', '<S-Tab>', ':BufferPrevious<CR>')
vim.keymap.set('n', '<C-c>', ':BufferClose<CR>')

-- tt   Twilight toggle
vim.keymap.set('n', 'tt', ':Twilight<CR>')

-- cp   Color picker
vim.keymap.set('n', 'cp', ':CccPick<CR>')
