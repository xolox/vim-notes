" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: June 14, 2011
" URL: http://peterodding.com/code/vim/misc/

" Trim whitespace from start and end of string.

function! xolox#misc#str#trim(s)
  return substitute(a:s, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

" vim: ts=2 sw=2 et
