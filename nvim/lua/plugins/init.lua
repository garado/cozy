
-- █▀█ █░░ █░█ █▀▀ █ █▄░█ █▀ 
-- █▀▀ █▄▄ █▄█ █▄█ █ █░▀█ ▄█ 

-- Load VimPlug plugins
require("plugins.vimplug")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- All Nvim plugins go here
require("lazy").setup{

  -- █▀▀ █▀█ █▀█ █▀▀    █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
  -- █▄▄ █▄█ █▀▄ ██▄    █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

  "nvim-lua/plenary.nvim",

  {
    "williamboman/mason.nvim",
    config = require("mason").setup()
   },

  {
    "williamboman/mason-lspconfig.nvim",
    -- config = require("mason-lspconfig").setup()
  },

   {
     "nvim-treesitter/nvim-treesitter",
     -- run = function()
     --   local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
     --   ts_update()
     -- end,
   },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.config.nvim-lsp")
    end
  },


  -- █▀█ █▀█ █░░ 
  -- ▀▀█ █▄█ █▄▄ 

  {
    "folke/which-key.nvim",
    config = function()
      require('plugins.config.which-key')
    end,
  },

  -- Completions
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("plugins.config.cmp")
    end
  },

  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("plugins.config.luasnip")
    end
  },

  "saadparwaiz1/cmp_luasnip",

   {
    "windwp/nvim-autopairs",
      config = function()
        require("nvim-autopairs").setup{}
      end
    },

  -- Highlight range selection
  "winston0410/cmd-parser.nvim",
  {
    "winston0410/range-highlight.nvim",
    dependencies = "winston0410/cmd-parser.nvim",
    config = function()
      require"range-highlight".setup{}
    end
  },

  -- Paste image from clipboard as markdown link
  -- (Used for vimwiki)
  "ekickx/clipboard-image.nvim",

  -- █░█ █ 
  -- █▄█ █ 

  "norcalli/nvim.lua",
  "norcalli/nvim-base16.lua",

  {
    'toppair/peek.nvim',
    run = 'deno task --quiet build:fast'
  },

  {
    "folke/twilight.nvim",
    config = function()
      require("twilight").setup{}
    end
  },


  {
    "uga-rosa/ccc.nvim",
    config = function()
      require("ccc").setup({
        highlighter = {auto_enable = true}
      })
    end
  },

  {
    "nvim-tree/nvim-web-devicons",
    config = require("plugins.config.nvim-web-devicons")
  },

   {
    "romgrk/barbar.nvim",
    dependencies = "nvim-web-devicons",
    config = function()
      require("plugins.config.barbar")
      vim.cmd('let bufferline.animation = v:true')
    end
  },

  -- Theme
  -- TODO find an easy way to toggle this
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    config = require("plugins.config.indent-blankline")
  },

  -- Filetree
  {
    "nvim-tree/nvim-tree.lua",
    config = require("plugins.config.nvim-tree"),
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    -- tag = "nightly" -- optional, updated every week. (see issue #1193)
  },

  -- Statusbar
   {
    "nvim-lualine/lualine.nvim",
    config = require("plugins.config.lualine"),
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Telescope
   {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
  },

  -- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀ 
  -- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█ 

  -- jk, jj to escape
  {
    "max397574/better-escape.nvim",
    config = require("plugins.config.better_escape")
  },

  -- Easier commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("plugins.config.comment")
    end
  },

  -- Figlet
  {
    "pavanbhat1999/figlet.nvim",
		-- dependencies = "numToStr/Comment.nvim",
    config = function()
      require("plugins.config.figlet")
    end
  },


  -- █▀▄▀█ █ █▀ █▀▀ 
  -- █░▀░█ █ ▄█ █▄▄ 

  -- Wakatime
  "wakatime/vim-wakatime",

  {
    'vimwiki/vimwiki',
    config = function()
      vim.cmd('source $HOME/.config/nvim/lua/plugins/config/vimwiki/vimwiki.vim')
    end
  },

  -- Syntax highlighting
  'ledger/vim-ledger',
  'kylelaker/riscv.vim',

  -- Vimtex
  "lervag/vimtex",

  -- Show Neovim in Discord
  "andweeb/presence.nvim",
}
