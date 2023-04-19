
-- █▀█ █░█ ▄▀█ █░░ █ ▀█▀ █▄█    █▀█ █▀▀    █░░ █ █▀▀ █▀▀ 
-- ▀▀█ █▄█ █▀█ █▄▄ █ ░█░ ░█░    █▄█ █▀░    █▄▄ █ █▀░ ██▄ 

return {

  -- Defines keymappings and shows handy popup
  {
    "folke/which-key.nvim",
    config = function()
      require('config.which-key')
    end,
  },

  -- Syntax highlighting for TODO/FIXME/BUG/etc
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
  },

  -- Completions
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "saadparwaiz1/cmp_luasnip",
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("config.cmp")
    end
  },

  -- Snippets
  {
	  "L3MON4D3/LuaSnip",
	  version = "<CurrentMajor>.*",
	  build = "make install_jsregexp",
    dependencies = "nvim-cmp",
    config = function()
      local ls = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.g.luasnippets_path or "" })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("config.luasnip")

      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if ls.session.current_nodes[vim.api.nvim_get_current_buf()]
            and not ls.session.jump_active
          then
            ls.unlink_current()
          end
        end,
      })
    end,
  },

  {
    "rafamadriz/friendly-snippets",
    dependencies = "L3MON4D3/LuaSnip",
  },

  -- Automatically completes braces, parents, etc
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

  -- Automatically turn off relative line numbers when they don't make sense
  "sitiom/nvim-numbertoggle",

  -- jk, jj to escape (with timeout)
  {
    "max397574/better-escape.nvim",
    config = function() require("config.better_escape") end
  },

  -- Easier commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("config.comment")
    end
  },

  -- Figlet
  {
    "pavanbhat1999/figlet.nvim",
		dependencies = "numToStr/Comment.nvim",
    config = function()
      require("config.figlet")
    end
  },

  {
    'mfussenegger/nvim-dap',
    config = function()
      require("config.nvim-dap")
    end
  },
}
