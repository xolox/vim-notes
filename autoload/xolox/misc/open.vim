" Integration between Vim and its environment.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 19, 2013
" URL: http://peterodding.com/code/vim/misc/

if !exists('s:version')
  let s:version = '1.1'
  let s:enoimpl = "open.vim %s: %s() hasn't been implemented for your platform! If you have suggestions, please contact peter@peterodding.com."
  let s:handlers = ['gnome-open', 'kde-open', 'exo-open', 'xdg-open']
endif

function! xolox#misc#open#file(path, ...) " {{{1
  " Given a pathname as the first argument, this opens the file with the
  " program associated with the file type. So for example a text file might
  " open in Vim, an `*.html` file would probably open in your web browser and
  " a media file would open in a media player.
  "
  " This should work on Windows, Mac OS X and most Linux distributions. If
  " this fails to find a file association, you can pass one or more external
  " commands to try as additional arguments. For example:
  "
  "     :call xolox#misc#open#file('/path/to/my/file', 'firefox', 'google-chrome')
  "
  " This generally shouldn't be necessary but it might come in handy now and
  " then.
  if xolox#misc#os#is_win()
    try
      call xolox#shell#open_with_windows_shell(a:path)
    catch /^Vim\%((\a\+)\)\=:E117/
      let command = '!start CMD /C START "" %s'
      silent execute printf(command, xolox#misc#escape#shell(a:path))
    endtry
    return
  elseif has('macunix')
    let cmd = 'open ' . shellescape(a:path) . ' 2>&1'
    call s:handle_error(cmd, system(cmd))
    return
  else
    for handler in s:handlers + a:000
      if executable(handler)
        call xolox#misc#msg#debug("open.vim %s: Using '%s' to open '%s'.", s:version, handler, a:path)
        let cmd = shellescape(handler) . ' ' . shellescape(a:path) . ' 2>&1'
        call s:handle_error(cmd, system(cmd))
        return
      endif
    endfor
  endif
  throw printf(s:enoimpl, s:script, 'xolox#misc#open#file')
endfunction

function! xolox#misc#open#url(url) " {{{1
  " Given a URL as the first argument, this opens the URL in your preferred or
  " best available web browser:
  "
  " - In GUI environments a graphical web browser will open (or a new tab will
  "   be created in an existing window)
  " - In console Vim without a GUI environment, when you have any of `lynx`,
  "   `links` or `w3m` installed it will launch a command line web browser in
  "   front of Vim (temporarily suspending Vim)
  let url = a:url
  if url !~ '^\w\+://'
    if url !~ '@'
      let url = 'http://' . url
    elseif url !~ '^mailto:'
      let url = 'mailto:' . url
    endif
  endif
  if has('unix') && !has('gui_running') && $DISPLAY == ''
    for browser in ['lynx', 'links', 'w3m']
      if executable(browser)
        execute '!' . browser fnameescape(url)
        call s:handle_error(browser . ' ' . url, '')
        return
      endif
    endfor
  endif
  call xolox#misc#open#file(url, 'firefox', 'google-chrome')
endfunction

function! s:handle_error(cmd, output) " {{{1
  if v:shell_error
    let message = "open.vim %s: Failed to execute program! (command line: %s%s)"
    let output = strtrans(xolox#misc#str#trim(a:output))
    if output != ''
      let output = ", output: " . string(output)
    endif
    throw printf(message, s:version, a:cmd, output)
  endif
endfunction

" vim: et ts=2 sw=2 fdm=marker
