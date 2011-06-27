" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: June 27, 2011
" URL: http://peterodding.com/code/vim/misc/

function! xolox#misc#option#get(name, ...)
  if exists('b:' . a:name)
    " Buffer local variable.
    return eval('b:' . a:name)
  elseif exists('g:' . a:name)
    " Global variable.
    return eval('g:' . a:name)
  elseif exists('a:1')
    " Default value.
    return a:1
  endif
endfunction

" Functions to parse multi-valued Vim options like &tags and &runtimepath.

function! xolox#misc#option#split(value)
  let values = split(a:value, '[^\\]\zs,')
  return map(values, 's:unescape(v:val)')
endfunction

function! s:unescape(s)
  return substitute(a:s, '\\\([\\,]\)', '\1', 'g')
endfunction

function! xolox#misc#option#join(values)
  let values = copy(a:values)
  call map(values, 's:escape(v:val)')
  return join(values, ',')
endfunction

function! s:escape(s)
  return escape(a:s, ',\')
endfunction

function! xolox#misc#option#split_tags(value)
  let values = split(a:value, '[^\\]\zs,')
  return map(values, 's:unescape_tags(v:val)')
endfunction

function! s:unescape_tags(s)
  return substitute(a:s, '\\\([\\, ]\)', '\1', 'g')
endfunction

function! xolox#misc#option#join_tags(values)
  let values = copy(a:values)
  call map(values, 's:escape_tags(v:val)')
  return join(values, ',')
endfunction

function! s:escape_tags(s)
  return escape(a:s, ', ')
endfunction

" vim: ts=2 sw=2 et
