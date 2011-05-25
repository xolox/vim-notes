" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: March 15, 2011
" URL: http://peterodding.com/code/vim/misc/

" Trim whitespace from start and end of string.

function! xolox#misc#str#trim(s)
  return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" vim: ts=2 sw=2 et
