local M = {}

M.base_30 = {
  -- some colors 
}

M.base_16 = {
  -- some colors 
}

vim.opt.bg = "dark" -- this can be either dark or light

M = require("base46").override_theme(M, "atheme")

return M
