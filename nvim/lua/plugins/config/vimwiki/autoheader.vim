
" ▄▀█ █░█ ▀█▀ █▀█ █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
" █▀█ █▄█ ░█░ █▄█ █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

" Automatically insert Hugo front matter for new VimWiki pages

:function Autoheader()
  let vault_home = "$HOME/Documents/Vault/content"
  let fname = expand('%')
 
  " Create header
  let header_text = "---\ntitle: "
  let fname_trunc = fnamemodify(fname, ':t:r')
  let header_text = header_text . fname_trunc . "\n---\n\n# " . fname_trunc . "\n"

  " Insert header
  execute "normal! i" . header_text . "\<Esc>"
:endfunction

autocmd BufNewFile *.md :call Autoheader()
