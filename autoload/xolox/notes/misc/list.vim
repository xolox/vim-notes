" This Vim script was modified by a Python script that I use to manage the
" inclusion of miscellaneous functions in the plug-ins that I publish to Vim
" Online and GitHub. Please don't edit this file, instead make your changes on
" the 'dev' branch of the git repository (thanks!). This file was generated on
" May 21, 2013 at 03:00.

" List handling functions.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 19, 2013
" URL: http://peterodding.com/code/vim/misc/

function! xolox#notes#misc#list#unique(list) " {{{1
  " Remove duplicate values from the given list in-place (preserves order).
  call reverse(a:list)
  call filter(a:list, 'count(a:list, v:val) == 1')
  return reverse(a:list)
endfunction

function! xolox#notes#misc#list#binsert(list, value, ...) " {{{1
  " Performs in-place binary insertion, which depending on your use case can
  " be more efficient than calling Vim's [sort()] [sort] function after each
  " insertion (in cases where a single, final sort is not an option). Expects
  " three arguments:
  "
  " 1. A list
  " 2. A value to insert
  " 3. 1 (true) when case should be ignored, 0 (false) otherwise
  "
  " [sort]: http://vimdoc.sourceforge.net/htmldoc/eval.html#sort()
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
  " Tests for xolox#notes#misc#list#binsert().
  let s:list = ['a', 'B', 'e']
  function! s:test(value, expected)
    call xolox#notes#misc#list#binsert(s:list, a:value, 1)
    if s:list != a:expected
      call xolox#notes#misc#msg#warn("list.vim: Test failed! Expected %s, got %s",
            \ string(a:expected), string(s:list))
    endif
  endfunction
  call s:test('c', ['a', 'B', 'c', 'e'])
  call s:test('D', ['a', 'B', 'c', 'D', 'e'])
  call s:test('f', ['a', 'B', 'c', 'D', 'e', 'f'])
endif

" vim: ts=2 sw=2 et
