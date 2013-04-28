" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: April 18, 2013
" URL: http://peterodding.com/code/vim/misc/

function! xolox#misc#buffer#is_empty() " {{{1
  " Check if the current buffer is an empty, unchanged buffer which can be reused.
  return !&modified && expand('%') == '' && line('$') <= 1 && getline(1) == ''
endfunction

function! xolox#misc#buffer#prepare(...) " {{{1
  " Open a special buffer (with generated contents, not directly edited by the user).
  if a:0 == 1 && type(a:1) == type('')
    " Backwards compatibility with old interface.
    let options = {'name': a:1, 'path': a:1}
  elseif type(a:1) == type({})
    let options = a:1
  else
    throw "Invalid arguments"
  endif
  let winnr = 1
  let found = 0
  for bufnr in tabpagebuflist()
    if xolox#misc#path#equals(options['path'], bufname(bufnr))
      execute winnr . 'wincmd w'
      let found = 1
      break
    else
      let winnr += 1
    endif
  endfor
  if !(found || xolox#misc#buffer#is_empty())
    vsplit
  endif
  silent execute 'edit' fnameescape(options['path'])
  lcd " clear working directory
  setlocal buftype=nofile bufhidden=hide noswapfile
  let &l:statusline = '[' . options['name'] . ']'
  call xolox#misc#buffer#unlock()
  silent %delete
endfunction

function! xolox#misc#buffer#lock() " {{{1
  " Lock a special buffer so it can no longer be edited.
  setlocal readonly nomodifiable nomodified
endfunction

function! xolox#misc#buffer#unlock() " {{{1
  " Unlock a special buffer so that its content can be updated.
  setlocal noreadonly modifiable
endfunction
