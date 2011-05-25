" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 25, 2011
" URL: http://peterodding.com/code/vim/misc/

if !exists('s:script')
  let s:script = expand('<sfile>:p:~')
  let s:enoimpl = "%s: %s() hasn't been implemented for your platform!"
  let s:enoimpl .= " If you have suggestions, please contact peter@peterodding.com."
  let s:handlers = ['gnome-open', 'kde-open', 'exo-open', 'xdg-open']
endif

function! xolox#misc#open#file(path, ...)
  if xolox#misc#os#is_win()
    try
      call xolox#shell#open_with_windows_shell(a:path)
    catch /^Vim\%((\a\+)\)\=:E117/
      let command = '!start CMD /C START "" %s'
      silent execute printf(command, shellescape(a:path))
    endtry
    return
  elseif has('macunix')
    let cmd = 'open ' . shellescape(a:path) . ' 2>&1'
    call s:handle_error(cmd, system(cmd))
    return
  else
    for handler in s:handlers + a:000
      if executable(handler)
        call xolox#misc#msg#debug("%s: Using `%s' to open %s", s:script, handler, a:path)
        let cmd = shellescape(handler) . ' ' . shellescape(a:path) . ' 2>&1'
        call s:handle_error(cmd, system(cmd))
        return
      endif
    endfor
  endif
  throw printf(s:enoimpl, s:script, 'xolox#misc#open#file')
endfunction

function! xolox#misc#open#url(url)
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

function! s:handle_error(cmd, output)
  if v:shell_error
    let message = "%s: Failed to execute program! (command line: %s%s)"
    let output = strtrans(xolox#misc#str#trim(a:output))
    if output != ''
      let output = ", output: " . string(output)
    endif
    throw printf(message, s:script, a:cmd, output)
  endif
endfunction

" vim: et ts=2 sw=2 fdm=marker
