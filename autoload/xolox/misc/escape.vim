" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: November 21, 2011
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

" Convert a string into a quoted command line argument. I was going to add a
" long rant here about &shellslash, but really, it won't make any difference.
" Let's just suffice to say that I have yet to encounter a single person out
" there who uses this option for its intended purpose (running a UNIX-style
" shell on Windows).

function! xolox#misc#escape#shell(string)
  if xolox#misc#os#is_win()
    try
      let ssl_save = &shellslash
      set noshellslash
      return shellescape(a:string)
    finally
      let &shellslash = ssl_save
    endtry
  else
    return shellescape(a:string)
  endif
endfunction

" vim: ts=2 sw=2 et
