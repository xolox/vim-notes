" String handling.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 19, 2013
" URL: http://peterodding.com/code/vim/misc/

function! xolox#misc#str#compact(s)
  " Compact whitespace in the string given as the first argument.
  return join(split(a:s), " ")
endfunction

function! xolox#misc#str#trim(s)
  " Trim all whitespace from the start and end of the string given as the
  " first argument.
  return substitute(a:s, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

" vim: ts=2 sw=2 et
