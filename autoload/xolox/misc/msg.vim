" Functions to interact with the user.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 20, 2013
" URL: http://peterodding.com/code/vim/misc/

if !exists('g:xolox_message_buffer')
  " For when I lose my :messages history :-\
  let g:xolox_message_buffer = 100
endif

if !exists('g:xolox_messages')
  let g:xolox_messages = []
endif

function! xolox#misc#msg#info(...) " {{{1
  " Show a formatted informational message to the user. This function has the
  " same argument handling as Vim's [printf()] [printf] function.
  "
  " [printf]: http://vimdoc.sourceforge.net/htmldoc/eval.html#printf()
  call s:show_message('title', a:000)
endfunction

function! xolox#misc#msg#warn(...) " {{{1
  " Show a formatted warning message to the user. This function has the same
  " argument handling as Vim's [printf()] [printf] function.
  call s:show_message('warningmsg', a:000)
endfunction

function! xolox#misc#msg#debug(...) " {{{1
  " Show a formatted debugging message to the user, if the user has enabled
  " increased verbosity by setting Vim's ['verbose'] [verbose] option to one
  " (1) or higher. This function has the same argument handling as Vim's
  " [printf()] [printf] function.
  if &vbs >= 1
    call s:show_message('question', a:000)
  endif
endfunction

function! s:show_message(hlgroup, args) " {{{1
  " The implementation of info() and warn().
  let nargs = len(a:args)
  if nargs == 1
    let message = a:args[0]
  elseif nargs >= 2
    let message = call('printf', a:args)
  endif
  if exists('message')
    try
      " Temporarily disable Vim's |hit-enter| prompt and mode display.
      if !exists('s:more_save')
        let s:more_save = &more
        let s:ruler_save = &ruler
        let s:smd_save = &showmode
      endif
      set nomore noshowmode
      if winnr('$') == 1 | set noruler | endif
      augroup PluginXoloxHideMode
        autocmd! CursorHold,CursorHoldI * call s:clear_message()
      augroup END
      execute 'echohl' a:hlgroup
      " Redraw to avoid |hit-enter| prompt.
      redraw
      for line in split(message, "\n")
        echomsg line
      endfor
      if g:xolox_message_buffer > 0
        call add(g:xolox_messages, message)
        if len(g:xolox_messages) > g:xolox_message_buffer
          call remove(g:xolox_messages, 0)
        endif
      endif
    finally
      " Always clear message highlighting, even when interrupted by Ctrl-C.
      echohl none
    endtry
  endif
endfunction

function! s:clear_message() " {{{1
  " Callback to clear message after some time has passed.
  echo ''
  let &more = s:more_save
  let &showmode = s:smd_save
  let &ruler = s:ruler_save
  unlet s:more_save s:ruler_save s:smd_save
  autocmd! PluginXoloxHideMode
  augroup! PluginXoloxHideMode
endfunction

" vim: ts=2 sw=2 et
