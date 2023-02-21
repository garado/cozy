
-- █▀▀ █▀█ █▀█ █▀▀ 
-- █▄▄ █▄█ █▀▄ ██▄ 

-- This is for the backend stuff that I'll never directly interact with

return {
  "nvim-lua/plenary.nvim",

  {
    "williamboman/mason.nvim",
    config = function()
      local mason = require("mason")
      if mason then require("mason").setup() end
    end
   },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup()
    end
  },

  {
   "nvim-treesitter/nvim-treesitter",
   config = function()
     require("config.treesitter")
   end,
   build = function()
    local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
    ts_update()
   end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("config.nvim-lsp")
    end
  },
}
