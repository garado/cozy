
-- █▄▄ ▄▀█ █▀█ █▄▄ ▄▀█ █▀█ 
-- █▄█ █▀█ █▀▄ █▄█ █▀█ █▀▄ 

local present, barbar = pcall(require, "bufferline")
if not present then return end

-- Position tab bar to the left of nvim-tree
local nvim_tree_events = require('nvim-tree.events')
local bufferline_api = require('bufferline.api')

local function get_tree_size()
  return require'nvim-tree.view'.View.width
end

nvim_tree_events.subscribe('TreeOpen', function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('Resize', function()
  bufferline_api.set_offset(get_tree_size() + 3)
end)

nvim_tree_events.subscribe('TreeClose', function()
  bufferline_api.set_offset(0)
end)

-- Setup
barbar.setup({
  animations = false,
  auto_hide = true,
  no_name_title = nil,
  icon_separator_active = ' ',
  icon_separator_inactive = ' ',
  tabpages = true,
})
