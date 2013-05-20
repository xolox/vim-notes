" Timing of long during operations.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 20, 2013
" URL: http://peterodding.com/code/vim/misc/

if !exists('g:timer_enabled')
  let g:timer_enabled = 0
endif

if !exists('g:timer_verbosity')
  let g:timer_verbosity = 1
endif

let s:has_reltime = has('reltime')

function! xolox#misc#timer#start() " {{{1
  " Start a timer. This returns a list which can later be passed to
  " `xolox#misc#timer#stop()`.
  return s:has_reltime ? reltime() : [localtime()]
endfunction

function! xolox#misc#timer#stop(...) " {{{1
  " Show a formatted debugging message to the user, if the user has enabled
  " increased verbosity by setting Vim's ['verbose'] [verbose] option to one
  " (1) or higher.
  "
  " This function has the same argument handling as Vim's [printf()] [printf]
  " function with one difference: At the point where you want the elapsed time
  " to be embedded, you write `%s` and you pass the list returned by
  " `xolox#misc#timer#start()` as an argument.
  "
  " [verbose]: http://vimdoc.sourceforge.net/htmldoc/options.html#'verbose'
  " [printf]: http://vimdoc.sourceforge.net/htmldoc/eval.html#printf()
  if (g:timer_enabled || &verbose >= g:timer_verbosity)
    call call('xolox#misc#msg#info', map(copy(a:000), 's:convert_value(v:val)'))
  endif
endfunction

function! xolox#misc#timer#force(...) " {{{1
  " Show a formatted message to the user. This function has the same argument
  " handling as Vim's [printf()] [printf] function with one difference: At the
  " point where you want the elapsed time to be embedded, you write `%s` and
  " you pass the list returned by `xolox#misc#timer#start()` as an argument.
  call call('xolox#misc#msg#info', map(copy(a:000), 's:convert_value(v:val)'))
endfunction

function! s:convert_value(value) " {{{1
  if type(a:value) != type([])
    return a:value
  elseif !empty(a:value)
    if s:has_reltime
      let ts = xolox#misc#str#trim(reltimestr(reltime(a:value)))
    else
      let ts = localtime() - a:value[0]
    endif
    return xolox#misc#timer#format_timespan(ts)
  else
    return '?'
  endif
endfunction

" Format number of seconds as human friendly description.

let s:units = [['day', 60 * 60 * 24], ['hour', 60 * 60], ['minute', 60], ['second', 1]]

function! xolox#misc#timer#format_timespan(ts) " {{{1
  " Format a time stamp (a string containing a formatted floating point
  " number) into a human friendly format, for example 70 seconds is phrased as
  " "1 minute and 10 seconds".

  " Convert timespan to integer.
  let seconds = a:ts + 0

  " Fast common case with extra precision from reltime().
  if seconds < 5
    let extract = matchstr(a:ts, '^\d\+\(\.0*[1-9][1-9]\?\)\?')
    if extract =~ '[123456789]'
      return extract . ' second' . (extract != '1' ? 's' : '')
    endif
  endif

  " Generic but slow code.
  let result = []
  for [name, size] in s:units
    if seconds >= size
      let counter = seconds / size
      let seconds = seconds % size
      let suffix = counter != 1 ? 's' : ''
      call add(result, printf('%i %s%s', counter, name, suffix))
    endif
  endfor

  " Format the resulting text?
  if len(result) == 1
    return result[0]
  else
    return join(result[0:-2], ', ') . ' and ' . result[-1]
  endif

endfunction

" vim: ts=2 sw=2 et
