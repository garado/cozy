
" ▄▀█ █░█ ▀█▀ █▀█ █▀▀ █▀█ █▀▄▀█ █▀▄▀█ █ ▀█▀ 
" █▀█ █▄█ ░█░ █▄█ █▄▄ █▄█ █░▀░█ █░▀░█ █ ░█░ 

" Auto commit to Git every time a file in the vault is saved

:function Autocommit()
  let vault_home = "$HOME/Documents/Vault/content"
  let fname = expand('%')
 
  " Create header

  " Insert header

  echo "Page header created"
:endfunction

" autocmd BufWritePost $HOME/Documents/Vault/content/** silent! execute '! if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1 ; then git add % ; git commit -m %; fi'
