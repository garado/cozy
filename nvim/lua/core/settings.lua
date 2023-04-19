
-- █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

local opt = vim.opt
local g = vim.g

-- I was "strongly advised" to do this by nvim tree docs
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Case while searching tweaks
opt.ignorecase = true
opt.smartcase = true

-- Highlight search results
opt.hlsearch = true

-- -- makes search act like search in modern browsers ?
-- opt.incsearch = true

-- Line numbers
opt.number = true
-- opt.relativenumber = true

-- Enable move cursor with mouse
opt.mouse = "a"

-- Fancy colors
vim.opt.termguicolors = true

---------------------------------
-- => Text, tab, indent related 
---------------------------------
-- Space master race
opt.expandtab = true
opt.smarttab = true

-- 1 tab == 2 spaces
opt.shiftwidth = 2
opt.tabstop = 2

-- Linebreak on 500 chars
opt.lbr = true
opt.tw = 500

opt.ai = true  -- auto indent
opt.si = true	 -- smart indent

-- Wrapping
-- j, k move to next displayed line instead of next physical line
opt.wrap = true

vim.cmd('nnoremap j gj')
vim.cmd('nnoremap k gk')
vim.cmd('vnoremap j gj')
vim.cmd('vnoremap k gk')

-- Remove ugly squigglies from eob, replace with space
opt.fillchars = { eob = " " }

-- Paste from system clipboard
opt.clipboard = "unnamedplus"

opt.undofile = true

-- Disable stupid fucking swap files

-- Disable some built in plugins
local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

for _, plugin in pairs(default_plugins) do
  g["loaded_" .. plugin] = 1
end
