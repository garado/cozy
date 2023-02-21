
-- █░█░█ █░█ █ █▀▀ █░█    █▄▀ █▀▀ █▄█ 
-- ▀▄▀▄▀ █▀█ █ █▄▄ █▀█    █░█ ██▄ ░█░ 

local present, wk = pcall(require, "which-key")
if not present then return end

-- Config options
wk.setup({
})

-- -- Creating mappings
-- wk.register({
--   f = {
--     name = "file",
--     f = { "<cmd>Telescope find_files<cr>", "Find File" },
--     r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File", noremap=false, buffer = 123 },
--     n = { "New File" }, -- just a label. don't create any mapping
--     e = "Edit File", -- same as above
--     ["1"] = "which_key_ignore",  -- special label to hide it in the popup
--     b = { function() print("bar") end, "Foobar" } -- you can also pass functions!
--   },
-- }, { prefix = "<leader>" })
