
-- █░█ █ 
-- █▄█ █ 

return {

  -- Add Git highlights to sign column
  {
    'lewis6991/gitsigns.nvim',
    init = function()
      require("config.gitsigns")
    end,
  },

  "norcalli/nvim.lua",
  "norcalli/nvim-base16.lua",

  {
    'toppair/peek.nvim',
    build = 'deno task --quiet build:fast'
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
    config = function()
      require("config.nvim-web-devicons")
    end,
  },

  {
    "romgrk/barbar.nvim",
    lazy = false,
    dependencies = "nvim-web-devicons",
    config = function()
      require("config.barbar")
    end
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("config.indent-blankline")
    end
  },

  -- Filetree
  {
    "nvim-tree/nvim-tree.lua",
    version = "nightly",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("config.nvim-tree")
    end,
  },

  -- Statusbar
   {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = function()
      require("config.lualine")
    end,
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
    config = function()
      require("telescope").setup {
        defaults = {
          file_ignore_patterns = {
            "%.png",
            "%.jpg",
            "%.jpeg",
          }
        }
      }
  end,
  },
}
