" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 13, 2013
" URL: http://peterodding.com/code/vim/misc/

let g:xolox#misc#os#version = '0.2'

function! xolox#misc#os#is_win() " {{{1
  " Check whether Vim is running on Microsoft Windows.
  return has('win16') || has('win32') || has('win64')
endfunction

function! xolox#misc#os#exec(options) " {{{1
  " Execute an external command (hiding the console on Windows when possible).
  " NB: Everything below is wrapped in a try/finally block to guarantee
  " cleanup of temporary files.
  try

    " Unpack the options.
    let cmd = a:options['command']
    let async = get(a:options, 'async', 0)

    " Write the input for the external command to a temporary file?
    if has_key(a:options, 'stdin')
      let tempin = tempname()
      if type(a:options['stdin']) == type([])
        let lines = a:options['stdin']
      else
        let lines = split(a:options['stdin'], "\n")
      endif
      call writefile(lines, tempin)
      let cmd .= ' < ' . xolox#misc#escape#shell(tempin)
    endif

    " Redirect the standard output and standard error streams of the external
    " process to temporary files? (only in synchronous mode, which is the
    " default).
    if !async
      let tempout = tempname()
      let temperr = tempname()
      let cmd = printf('(%s) 1>%s 2>%s', cmd,
            \ xolox#misc#escape#shell(tempout),
            \ xolox#misc#escape#shell(temperr))
    endif

    " If A) we're on Windows, B) the vim-shell plug-in is installed and C) the
    " compiled DLL works, we'll use that because it's the most user friendly
    " method. If the plug-in is not installed Vim will raise the exception
    " "E117: Unknown function" which is caught and handled below.
    try
      if xolox#shell#can_use_dll()
        " Let the user know what's happening (in case they're interested).
        call xolox#misc#msg#debug("os.vim %s: Executing external command using compiled DLL: %s", g:xolox#misc#os#version, cmd)
        let exit_code = xolox#shell#execute_with_dll(cmd, async)
      endif
    catch /^Vim\%((\a\+)\)\=:E117/
      call xolox#misc#msg#debug("os.vim %s: The vim-shell plug-in is not installed, falling back to system() function.", g:xolox#misc#os#version)
    endtry

    " If we cannot use the DLL, we fall back to the default and generic
    " implementation using Vim's system() function.
    if !exists('exit_code')

      " Enable asynchronous mode (very platform specific).
      if async
        if xolox#misc#os#is_win()
          let cmd = 'start /b ' . cmd
        elseif has('unix')
          let cmd = '(' . cmd . ') &'
        else
          call xolox#misc#msg#warn("os.vim %s: I don't know how to run commands asynchronously on your platform! Falling back to synchronous mode.", g:xolox#misc#os#version)
        endif
      endif

      " Let the user know what's happening (in case they're interested).
      call xolox#misc#msg#debug("os.vim %s: Executing external command using system() function: %s", g:xolox#misc#os#version, cmd)
      call system(cmd)
      let exit_code = v:shell_error

    endif

    let result = {}
    if !async
      " If we just executed a synchronous command and the caller didn't
      " specifically ask us *not* to check the exit code of the external
      " command, we'll do so now.
      if get(a:options, 'check', 1) && exit_code != 0
        let msg = "os.vim %s: External command failed with exit code %d: %s"
        throw printf(msg, g:xolox#misc#os#version, result['exit_code'], result['command'])
      endif
      " Return the results as a dictionary with three key/value pairs.
      let result['exit_code'] = exit_code
      let result['stdout'] = s:readfile(tempout)
      let result['stderr'] = s:readfile(temperr)
    endif
    return result

  finally
    " Cleanup any temporary files we created.
    for name in ['tempin', 'tempout', 'temperr']
      if exists(name)
        call delete({name})
      endif
    endfor
  endtry

endfunction

function! s:readfile(fname) " {{{1
  " readfile() that swallows errors.
  try
    return readfile(a:fname)
  catch
    return []
  endtry
endfunction

" vim: ts=2 sw=2 et
