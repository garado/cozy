
" █░░ █ █▄░█ █▄▀    █░█ ▄▀█ █▄░█ █▀▄ █░░ █▀▀ █▀█ 
" █▄▄ █ █░▀█ █░█    █▀█ █▀█ █░▀█ █▄▀ █▄▄ ██▄ █▀▄ 

" Custom link handler

function! HandlePdf(link)

    " Use Vim to open ext files with the 'vfile:' scheme
    "if link =~# '^vfile:'
    "  let link = link[1:]

    "" Open PDFs in Zathura
    "elseif link =~# '.*.pdf'
    "  echomsg 'is a pdf'
    "  let ret = HandlePdf(link)
    "  return ret

    "" Open images in feh
    "elseif link =~# '.*#.*'
    "  echomsg 'is an image'
    "  execute 'feh ' . link
    "  return 1

    "" Vimwiki links
    "else
    "endif

    let buf = bufnr('%')
    let link_infos = vimwiki#base#resolve_link(a:link)
    if link_infos.filename == ''
      echomsg 'Vimwiki Error: Unable to resolve link!'
      return 0
    else
      exe 'edit ' . fnameescape(link_infos.filename)
      exe 'bd' . buf
      let vimwiki_prev_link = [vimwiki#path#current_wiki_file(), getpos('.')]
      return 1
    endif
  catch
  endtry
endfunction
