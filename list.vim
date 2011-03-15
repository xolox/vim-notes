" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: March 15, 2011
" URL: http://peterodding.com/code/vim/misc/

" Remove duplicate values from {list} in-place (preserves order).

function! xolox#misc#list#unique(list)
  let index = 0
  while index < len(a:list)
    let value = a:list[index]
    let match = index(a:list, value, index+1)
    if match >= 0
      call remove(a:list, match)
    else
      let index += 1
    endif
    unlet value
  endwhile
  return a:list
endfunction

" vim: ts=2 sw=2 et
