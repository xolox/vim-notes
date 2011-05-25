" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: March 15, 2011
" URL: http://peterodding.com/code/vim/misc/

" Check whether Vim is running on Microsoft Windows.

function! xolox#misc#os#is_win()
  return has('win16') || has('win32') || has('win64')
endfunction

" vim: ts=2 sw=2 et
