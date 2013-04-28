" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: November 24, 2011
" URL: http://peterodding.com/code/vim/misc/

let g:xolox#misc#os#version = '0.1'

" Check whether Vim is running on Microsoft Windows.

function! xolox#misc#os#is_win()
  return has('win16') || has('win32') || has('win64')
endfunction

" Execute an external command (hiding the console on Windows when possible).

function! xolox#misc#os#exec(cmdline, ...)
  try
    " Try using my shell.vim plug-in.
    return call('xolox#shell#execute', [a:cmdline, 1] + a:000)
  catch /^Vim\%((\a\+)\)\=:E117/
    " Fall back to system() when we get an "unknown function" error.
    let output = call('system', [a:cmdline] + a:000)
    if v:shell_error
      throw printf("os.vim %s: Command %s failed: %s", g:xolox#misc#os#version, a:cmdline, xolox#misc#str#trim(output))
    endif
    return split(output, "\n")
  endtry
endfunction

" vim: ts=2 sw=2 et
