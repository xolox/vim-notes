" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: March 15, 2011
" URL: http://peterodding.com/code/vim/misc/

let s:windows_compatible = has('win32') || has('win64')

" Split a pathname into a list of path components.

function! xolox#misc#path#split(path)
  if type(a:path) == type('')
    if s:windows_compatible
      return split(a:path, '[\/]\+')
    else
      let absolute = (a:path =~ '^/')
      let segments = split(a:path, '/\+')
      return absolute ? insert(segments, '/') : segments
    endif
  endif
  return []
endfunction

" Join a list of path components into a pathname.

function! xolox#misc#path#join(parts)
  if type(a:parts) == type([])
    if !s:windows_compatible && a:parts[0] == '/'
      return join(a:parts, '/')[1 : -1]
    else
      return join(a:parts, '/')
    endif
  endif
  return ''
endfunction

" Canonicalize and resolve a pathname.

function! xolox#misc#path#absolute(path)
  if type(a:path) == type('')
    let path = fnamemodify(a:path, ':p')
    " resolve() doesn't work when there's a trailing path separator.
    if path =~ '/$'
      let stripped_slash = 1
      let path = substitute(path, '/$', '', '')
    endif
    let path = resolve(path)
    " Restore the path separator after calling resolve().
    if exists('stripped_slash') && path !~ '/$'
      let path .= '/'
    endif
    return path
  endif
  return ''
endfunction

" Make an absolute pathname relative.

function! xolox#misc#path#relative(path, base)
  let path = xolox#misc#path#split(a:path)
  let base = xolox#misc#path#split(a:base)
  while path != [] && base != [] && path[0] == base[0]
    call remove(path, 0)
    call remove(base, 0)
  endwhile
  let distance = repeat(['..'], len(base))
  return xolox#misc#path#join(distance + path)
endfunction

" Join a directory and filename into a single pathname.

function! xolox#misc#path#merge(parent, child, ...)
  if type(a:parent) == type('') && type(a:child) == type('')
    if s:windows_compatible
      let parent = substitute(a:parent, '[\\/]\+$', '', '')
      let child = substitute(a:child, '^[\\/]\+', '', '')
      return parent . '\' . child
    else
      let parent = substitute(a:parent, '/\+$', '', '')
      let child = substitute(a:child, '^/\+', '', '')
      return parent . '/' . child
    endif
  endif
  return ''
endfunction

" Find the common prefix of path components in a list of pathnames.

function! xolox#misc#path#commonprefix(paths)
  let common = xolox#misc#path#split(a:paths[0])
  for path in a:paths
    let index = 0
    for segment in xolox#misc#path#split(path)
      if len(common) <= index
        break
      elseif common[index] != segment
        call remove(common, index, -1)
        break
      endif
      let index += 1
    endfor
  endfor
  return xolox#misc#path#join(common)
endfunction

" Encode a pathname so it can be used as a filename.

function! xolox#misc#path#encode(path)
  let mask = s:windows_compatible ? '[*|\\/:"<>?%]' : '[\\/%]'
  return substitute(a:path, mask, '\=printf("%%%x", char2nr(submatch(0)))', 'g')
endfunction

" Decode a pathname previously encoded with xolox#misc#path#encode().

function! xolox#misc#path#decode(encoded_path)
  return substitute(a:encoded_path, '%\(\x\x\?\)', '\=nr2char("0x" . submatch(1))', 'g')
endfunction

" Check whether two pathnames point to the same file.

if s:windows_compatible
  function! xolox#misc#path#equals(a, b)
    return a:a ==? a:b || xolox#misc#path#absolute(a:a) ==? xolox#misc#path#absolute(a:b)
  endfunction
else
  function! xolox#misc#path#equals(a, b)
    return a:a ==# a:b || xolox#misc#path#absolute(a:a) ==# xolox#misc#path#absolute(a:b)
  endfunction
endif

" Create a temporary directory and return the path.

function! xolox#misc#path#tempdir()
  if !exists('s:tempdir_counter')
    let s:tempdir_counter = 1
  endif
  if exists('*mkdir')
    if s:windows_compatible
      let template = $TMP . '\vim_tempdir_'
    elseif filewritable('/tmp') == 2
      let template = '/tmp/vim_tempdir_'
    endif
  endif
  if !exists('template')
    throw "xolox#misc#path#tempdir() hasn't been implemented on your platform!"
  endif
  while 1
    let directory = template . s:tempdir_counter
    try
      call mkdir(directory, '', 0700)
      return directory
    catch /\<E739\>/
      " Keep looking for a non-existing directory.
    endtry
    let s:tempdir_counter += 1
  endwhile
endfunction

" vim: ts=2 sw=2 et
