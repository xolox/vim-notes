" This Vim script was modified by a Python script that I use to manage the
" inclusion of miscellaneous functions in the plug-ins that I publish to Vim
" Online and GitHub. Please don't edit this file, instead make your changes on
" the 'dev' branch of the git repository (thanks!). This file was generated on
" May 21, 2013 at 03:00.

" String handling.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 19, 2013
" URL: http://peterodding.com/code/vim/misc/

function! xolox#notes#misc#str#compact(s)
  " Compact whitespace in the string given as the first argument.
  return join(split(a:s), " ")
endfunction

function! xolox#notes#misc#str#trim(s)
  " Trim all whitespace from the start and end of the string given as the
  " first argument.
  return substitute(a:s, '^\_s*\(.\{-}\)\_s*$', '\1', '')
endfunction

" vim: ts=2 sw=2 et
