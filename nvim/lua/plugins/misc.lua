
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
      vim.cmd('source $HOME/.config/nvim/lua/plugins/config/vimwiki/vimwiki.vim')
      vim.cmd('let g:vimwiki_hl_headers = 1')
      vim.cmd('hi VimwikiHeader1 guifg=#bf616a gui=bold')
      vim.cmd('hi VimwikiHeader2 guifg=#d08770 gui=bold')
      vim.cmd('hi VimwikiHeader3 guifg=#ebcb8b gui=bold')
      vim.cmd('hi VimwikiHeader4 guifg=#a3be8c gui=bold')
      vim.cmd('hi VimwikiHeader5 guifg=#b48ead gui=bold')
      vim.cmd('hi VimwikiHeader6 guifg=#8fbcbb gui=bold')
      vim.cmd('hi VimwikiItalic guifg=#2e3440 guibg=#d8dee9')
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
