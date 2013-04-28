" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: March 15, 2011
" URL: http://peterodding.com/code/vim/misc/

" Keyword completion from the current buffer for user defined commands.

function! xolox#misc#complete#keywords(arglead, cmdline, cursorpos)
  let words = {}
  for line in getline(1, '$')
    for word in split(line, '\W\+')
      let words[word] = 1
    endfor
  endfor
  return sort(keys(filter(words, 'v:key =~# a:arglead')))
endfunction

" vim: ts=2 sw=2 et
