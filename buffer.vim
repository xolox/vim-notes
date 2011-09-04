" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 4, 2011
" URL: http://peterodding.com/code/vim/misc/

function! xolox#misc#buffer#is_empty()
  " Check if the current buffer is an empty, unchanged buffer which can be reused.
  return !&modified && expand('%') == '' && line('$') <= 1 && getline(1) == ''
endfunction

function! xolox#misc#buffer#prepare(bufname)
  let bufname = '[' . a:bufname . ']'
  let buffers = tabpagebuflist()
  call map(buffers, 'fnamemodify(bufname(v:val), ":t:r")')
  let idx = index(buffers, bufname)
  if idx >= 0
    execute (idx + 1) . 'wincmd w'
  elseif !(xolox#misc#buffer#is_empty() || expand('%:t') == bufname)
    vsplit
  endif
  silent execute 'edit' fnameescape(bufname)
  lcd " clear working directory
  setlocal buftype=nofile bufhidden=hide noswapfile
  let &l:statusline = bufname
  call xolox#misc#buffer#unlock()
  silent %delete
endfunction

function! xolox#misc#buffer#lock()
  " Lock a special buffer so it can no longer be edited.
  setlocal readonly nomodifiable nomodified
endfunction

function! xolox#misc#buffer#unlock()
  " Unlock a special buffer so that its content can be updated.
  setlocal noreadonly modifiable
endfunction
