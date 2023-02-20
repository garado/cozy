
-- █▀█ █░█ ▄▀█ █░░ █ ▀█▀ █▄█    █▀█ █▀▀    █░░ █ █▀▀ █▀▀ 
-- ▀▀█ █▄█ █▀█ █▄▄ █ ░█░ ░█░    █▄█ █▀░    █▄▄ █ █▀░ ██▄ 

return {

  -- Defines keymappings and shows handy popup
  {
    "folke/which-key.nvim",
    config = function()
      require('plugins.config.which-key')
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
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("plugins.config.cmp")
    end
  },

  -- Snippets
  {
    "norcalli/snippets.nvim",
    init = function()
      require("plugins.config.snippets")
    end,
  },

  {
	  "L3MON4D3/LuaSnip",
	  version = "<CurrentMajor>.*",
	  build = "make install_jsregexp",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load { paths = vim.g.luasnippets_path or "" }
      require("luasnip.loaders.from_vscode").lazy_load()

      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if
            require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
            and not require("luasnip").session.jump_active
          then
            require("luasnip").unlink_current()
          end
        end,
      })
    end,
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
		dependencies = "numToStr/Comment.nvim",
    config = function()
      require("plugins.config.figlet")
    end
  },
}
