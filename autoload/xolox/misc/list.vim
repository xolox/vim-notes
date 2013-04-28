" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: August 31, 2011
" URL: http://peterodding.com/code/vim/misc/

" Remove duplicate values from {list} in-place (preserves order).

function! xolox#misc#list#unique(list)
  call reverse(a:list)
  call filter(a:list, 'count(a:list, v:val) == 1')
  return reverse(a:list)
endfunction

" Binary insertion (more efficient than calling sort() after each insertion).

function! xolox#misc#list#binsert(list, value, ...)
  let idx = s:binsert_r(a:list, 0, len(a:list), a:value, exists('a:1') && a:1)
  return insert(a:list, a:value, idx)
endfunction

function! s:binsert_r(list, low, high, value, ignorecase)
  let mid = a:low + (a:high - a:low) / 2
  if a:low == a:high
    return a:low
  elseif a:ignorecase ? a:value >? a:list[mid] : a:value > a:list[mid]
    return s:binsert_r(a:list, mid + 1, a:high, a:value, a:ignorecase)
  elseif a:ignorecase ? a:value <? a:list[mid] : a:value < a:list[mid]
    return s:binsert_r(a:list, a:low, mid, a:value, a:ignorecase)
  else
    return mid
  endif
endfunction

if 0
  " Tests for xolox#misc#list#binsert().
  let s:list = ['a', 'B', 'e']
  function! s:test(value, expected)
    call xolox#misc#list#binsert(s:list, a:value, 1)
    if s:list != a:expected
      call xolox#misc#msg#warn("list.vim: Test failed! Expected %s, got %s",
            \ string(a:expected), string(s:list))
    endif
  endfunction
  call s:test('c', ['a', 'B', 'c', 'e'])
  call s:test('D', ['a', 'B', 'c', 'D', 'e'])
  call s:test('f', ['a', 'B', 'c', 'D', 'e', 'f'])
endif

" vim: ts=2 sw=2 et
