" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: March 15, 2011
" URL: http://peterodding.com/code/vim/misc/

" Convert a string into a :substitute pattern that matches the string literally.

function! xolox#misc#escape#pattern(string)
  if type(a:string) == type('')
    let string = escape(a:string, '^$.*\~[]')
    return substitute(string, '\n', '\\n', 'g')
  endif
  return ''
endfunction

" Convert a string into a :substitute replacement that inserts the string literally.

function! xolox#misc#escape#substitute(string)
  if type(a:string) == type('')
    let string = escape(a:string, '\&~%')
    return substitute(string, '\n', '\\r', 'g')
  endif
  return ''
endfunction

" vim: ts=2 sw=2 et
