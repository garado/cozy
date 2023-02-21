
-- █▀▄▀█ █ █▀ █▀▀ 
-- █░▀░█ █ ▄█ █▄▄ 

local g = vim.g

return {
  -- Wakatime
  "wakatime/vim-wakatime",

  {
    "vimwiki/vimwiki",
    ft = {"md", "markdown"},
    branch = "dev",
    init = function()
      vim.cmd('source $HOME/.config/nvim/lua/config/vimwiki/vimwiki.vim')
    end,
  },

  -- Syntax highlighting
  {
    'ledger/vim-ledger',
    ft = "ledger",
  },

  {
    'kylelaker/riscv.vim',
    ft = {"asm", "v"},
  },

  {
    "lervag/vimtex",
    ft = "tex",
    config = function()
      g.vimtex_view_method = 'zathura'
    end
  },

  -- Show Neovim in Discord
  "andweeb/presence.nvim",
}
