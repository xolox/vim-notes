" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: June 4, 2011
" URL: http://peterodding.com/code/vim/notes/

" Note: This file is encoded in UTF-8 including a byte order mark so
" that Vim loads the script using the right encoding transparently.

let s:script = expand('<sfile>:p:~')

function! xolox#notes#shortcut() " {{{1
  " The "note:" pseudo protocol is just a shortcut for the :Note command.
  let name = matchstr(expand('<afile>'), 'note:\zs.*')
  call xolox#notes#edit(v:cmdbang ? '!' : '', name)
endfunction

function! xolox#notes#edit(bang, title) abort " {{{1
  " Edit an existing note or create a new one with the :Note command.
  let starttime = xolox#misc#timer#start()
  let title = xolox#misc#str#trim(a:title)
  if title != ''
    let fname = xolox#notes#select(title)
    if fname != ''
      execute 'edit' . a:bang fnameescape(fname)
      if !xolox#notes#unicode_enabled() && xolox#misc#path#equals(fnamemodify(fname, ':h'), g:notes_shadowdir)
        call s:transcode_utf8_latin1()
      endif
      setlocal filetype=notes
      call xolox#misc#timer#stop('%s: Opened note in %s.', s:script, starttime)
      return
    endif
  else
    let title = 'New note'
  endif
  let fname = xolox#notes#title_to_fname(title)
  execute 'edit' . a:bang fnameescape(fname)
  setlocal filetype=notes
  if line('$') == 1 && getline(1) == ''
    let fname = xolox#misc#path#merge(g:notes_shadowdir, 'New note')
    execute 'silent read' fnameescape(fname)
    1delete
    if !xolox#notes#unicode_enabled()
      call s:transcode_utf8_latin1()
    endif
    setlocal nomodified
  endif
  if title != 'New note'
    call setline(1, title)
  endif
  doautocmd BufReadPost
  call xolox#misc#timer#stop('%s: Started new note in %s.', s:script, starttime)
endfunction

function! xolox#notes#edit_shadow() " {{{1
  " People using latin1 don't like the UTF-8 curly quotes and bullets used in
  " the predefined notes because there are no equivalent characters in latin1,
  " resulting in the characters being shown as garbage or a question mark.
  execute 'edit' fnameescape(expand('<amatch>'))
  if !xolox#notes#unicode_enabled()
    call s:transcode_utf8_latin1()
  endif
  setlocal filetype=notes
endfunction

function! xolox#notes#unicode_enabled()
  return &encoding == 'utf-8'
endfunction

function! s:transcode_utf8_latin1()
  let view = winsaveview()
  silent %s/\%xe2\%x80\%x98/`/eg
  silent %s/\%xe2\%x80\%x99/'/eg
  silent %s/\%xe2\%x80[\x9c\x9d]/"/eg
  silent %s/\%xe2\%x80\%xa2/\*/eg
  setlocal nomodified
  call winrestview(view)
endfunction

function! xolox#notes#select(filter) " {{{1
  " Interactively select an existing note whose title contains {filter}.
  let notes = {}
  let filter = xolox#misc#str#trim(a:filter)
  for [fname, title] in items(xolox#notes#get_fnames_and_titles())
    if title ==? filter
      return fname
    elseif title =~? filter
      let notes[fname] = title
    endif
  endfor
  if len(notes) == 1
    return keys(notes)[0]
  elseif !empty(notes)
    let choices = ['Please select a note:']
    let values = ['']
    for fname in sort(keys(notes))
      call add(choices, ' ' . len(choices) . ') ' . notes[fname])
      call add(values, fname)
    endfor
    let choice = inputlist(choices)
    if choice > 0 && choice < len(choices)
      return values[choice]
    endif
  endif
  return ''
endfunction

function! xolox#notes#complete(arglead, cmdline, cursorpos) " {{{1
  " Vim's support for custom command completion is a real mess, specifically
  " the completion of multi word command arguments. With or without escaping
  " of spaces, arglead will only contain the last word in the arguments passed
  " to :Note, and worse, the completion candidates we return only replace the
  " last word on the command line.
  " XXX This isn't a real command line parser; it will break on quoted pipes.
  let cmdline = split(a:cmdline, '\\\@<!|')
  let cmdargs = substitute(cmdline[-1], '^\s*\w\+\s\+', '', '')
  let arguments = split(cmdargs)
  let titles = xolox#notes#get_titles()
  if a:arglead != '' && len(arguments) == 1
    " If we are completing a single argument and we are able to replace it
    " (the user didn't type <Space><Tab> after the argument) we can select the
    " completion candidates using a substring match on the first argument
    " instead of a prefix match (I consider this to be more user friendly).
    let pattern = xolox#misc#escape#pattern(cmdargs)
    call filter(titles, "v:val =~ pattern")
  else
    " If we are completing more than one argument or the user has typed
    " <Space><Tab> after the first argument, we must select completion
    " candidates using a prefix match on all arguments because Vim doesn't
    " support replacing previous arguments (selecting completion candidates
    " using a substring match would result in invalid note titles).
    let pattern = '^' . xolox#misc#escape#pattern(cmdargs)
    call filter(titles, "v:val =~ pattern")
    " Remove the given arguments as the prefix of every completion candidate
    " because Vim refuses to replace previous arguments.
    let prevargs = '^' . xolox#misc#escape#pattern(cmdargs[0 : len(cmdargs) - len(a:arglead) - 1])
    call map(titles, 'substitute(v:val, prevargs, "", "")')
  endif
  return titles
endfunction

function! xolox#notes#save() abort " {{{1
  " When the current note's title is changed, automatically rename the file.
  if &filetype == 'notes'
    let title = getline(1)
    let oldpath = expand('%:p')
    let newpath = xolox#notes#title_to_fname(title)
    if newpath == ''
      echoerr "Invalid note title"
    endif
    let bang = v:cmdbang ? '!' : ''
    execute 'saveas' bang fnameescape(newpath)
    if !xolox#misc#path#equals(oldpath, newpath)
      call delete(oldpath)
    endif
    call xolox#notes#cache_del(oldpath)
    call xolox#notes#cache_add(newpath, title)
  endif
endfunction

function! xolox#notes#delete(bang) " {{{1
  " Delete the current note, close the associated buffer & window.
  let filename = expand('%:p')
  if filereadable(filename) && delete(filename)
    call xolox#misc#msg#warn("%s: Failed to delete %s!", s:script, filename)
    return
  endif
  call xolox#notes#cache_del(filename)
  execute 'bdelete' . a:bang
endfunction

function! xolox#notes#search(bang, input) " {{{1
  " Search all notes for the pattern or keywords {input} (current word if none given).
  let input = a:input
  if input == ''
    let input = s:tag_under_cursor()
    if input == ''
      call xolox#misc#msg#warn("No string under cursor")
      return
    endif
  endif
  if input =~ '^/.\+/$'
    call s:internal_search(a:bang, input, '', '')
    if &buftype == 'quickfix'
      let w:quickfix_title = 'Notes matching the pattern ' . input
    endif
  else
    let keywords = split(input)
    let all_keywords = s:match_all_keywords(keywords)
    let any_keyword = s:match_any_keyword(keywords)
    call s:internal_search(a:bang, all_keywords, input, any_keyword)
    if &buftype == 'quickfix'
      call map(keywords, '"`" . v:val . "''"')
      let w:quickfix_title = printf('Notes containing the word%s %s', len(keywords) == 1 ? '' : 's',
          \ len(keywords) > 1 ? (join(keywords[0:-2], ', ') . ' and ' . keywords[-1]) : keywords[0])
    endif
  endif
endfunction

function! s:tag_under_cursor() " {{{2
  try
    let isk_save = &isk
    set iskeyword+=@-@
    return expand('<cword>')
  finally
    let &isk = isk_save
  endtry
endfunction

function! s:match_all_keywords(keywords) " {{{2
  " Create a regex that matches when a file contains all {keywords}.
  let results = copy(a:keywords)
  call map(results, '''\_^\_.*'' . xolox#misc#escape#pattern(v:val)')
  return '/' . escape(join(results, '\&'), '/') . '/'
endfunction

function! s:match_any_keyword(keywords)
  " Create a regex that matches every occurrence of all {keywords}.
  let results = copy(a:keywords)
  call map(results, 'xolox#misc#escape#pattern(v:val)')
  return '/' . escape(join(results, '\|'), '/') . '/'
endfunction

function! xolox#notes#swaphack() " {{{1
  " Selectively ignore the dreaded E325 interactive prompt.
  if exists('s:swaphack_enabled')
    let v:swapchoice = 'o'
  endif
endfunction

function! xolox#notes#related(bang) " {{{1
  " Find all notes related to the current note or file.
  let bufname = bufname('%')
  if bufname == ''
    call xolox#misc#msg#warn("%s: :RelatedNotes only works on named buffers!", s:script)
  else
    let filename = xolox#misc#path#absolute(bufname)
    if &filetype == 'notes' && xolox#misc#path#equals(g:notes_directory, expand('%:h'))
      let pattern = '\<' . s:words_to_pattern(getline(1)) . '\>'
      let keywords = getline(1)
    else
      let pattern = s:words_to_pattern(filename)
      let keywords = filename
      if filename[0 : len($HOME)-1] == $HOME
        let relative = filename[len($HOME) + 1 : -1]
        let pattern = '\(' . pattern . '\|\~/' . s:words_to_pattern(relative) . '\)'
        let keywords = relative
      endif
    endif
    let pattern = '/' . escape(pattern, '/') . '/'
    let friendly_path = fnamemodify(filename, ':~')
    try
      call s:internal_search(a:bang, pattern, keywords, '')
      if &buftype == 'quickfix'
        let w:quickfix_title = 'Notes related to ' . friendly_path
      endif
    catch /^Vim\%((\a\+)\)\=:E480/
      call xolox#misc#msg#warn("%s: No related notes found for %s", s:script, friendly_path)
    endtry
  endif
endfunction

" Miscellaneous functions. {{{1

function! s:is_empty_buffer() " {{{2
  " Check if the buffer is an empty, unchanged buffer which can be reused.
  return !&modified && expand('%') == '' && line('$') <= 1 && getline(1) == ''
endfunction

function! s:internal_search(bang, pattern, keywords, phase2) " {{{2
  " Search notes for {pattern} regex, try to accelerate with {keywords} search.
  let starttime = xolox#misc#timer#start()
  let bufnr_save = bufnr('%')
  let pattern = a:pattern
  silent cclose
  " Find all notes matching the given keywords or regex.
  let notes = []
  let phase2_needed = 1
  if a:keywords != '' && s:run_scanner(a:keywords, notes)
    if notes == []
      call xolox#misc#msg#warn("E480: No matches")
      return
    endif
    let pattern = a:phase2 != '' ? a:phase2 : pattern
  else
    call s:vimgrep_wrapper(a:bang, a:pattern, xolox#notes#get_fnames())
    let notes = s:qflist_to_filenames()
    if a:phase2 != ''
      let pattern = a:phase2
    else
      let phase2_needed = 0
    endif
  endif
  " If we performed a keyword search using the scanner.py script we need to
  " run :vimgrep to populate the quick-fix list. If we're emulating keyword
  " search using :vimgrep we need to run :vimgrep another time to get the
  " quick-fix list in the right format :-|
  if phase2_needed
    call s:vimgrep_wrapper(a:bang, pattern, notes)
  endif
  if a:bang == '' && bufnr('%') != bufnr_save
    " If :vimgrep opens the first matching file while &eventignore is still
    " set the file will be opened without activating a file type plug-in or
    " syntax script. Here's a workaround:
    doautocmd filetypedetect BufRead
  endif
  silent cwindow
  if &buftype == 'quickfix'
    setlocal ignorecase
    execute 'match IncSearch' pattern
  endif
  call xolox#misc#timer#stop('%s: Searched notes in %s.', s:script, starttime)
endfunction

function! s:vimgrep_wrapper(bang, pattern, files) " {{{2
  " Search for {pattern} in {files} using :vimgrep.
  let args = map(copy(a:files), 'fnameescape(v:val)')
  call insert(args, a:pattern . 'j')
  let s:swaphack_enabled = 1
  try
    let ei_save = &eventignore
    set eventignore=syntax,bufread
    execute 'vimgrep' . a:bang join(args)
  finally
    let &eventignore = ei_save
    unlet s:swaphack_enabled
  endtry
endfunction

function! s:qflist_to_filenames() " {{{2
  " Get filenames of matched notes from quick-fix list.
  let names = {}
  for entry in getqflist()
    let names[xolox#misc#path#absolute(bufname(entry.bufnr))] = 1
  endfor
  return keys(names)
endfunction

function! s:run_scanner(keywords, matches) " {{{2
  " Try to run scanner.py script to find notes matching {keywords}.
  let scanner = xolox#misc#path#absolute(g:notes_indexscript)
  let python = 'python'
  if executable('python2')
    let python = 'python2'
  endif
  if !(executable(python) && filereadable(scanner))
    call xolox#misc#msg#debug("%s: The %s script isn't executable.", s:script, scanner)
  else
    let arguments = [scanner, g:notes_indexfile, g:notes_directory, g:notes_shadowdir, a:keywords]
    call map(arguments, 'shellescape(v:val)')
    let output = xolox#misc#str#trim(system(join([python] + arguments)))
    if !v:shell_error
      call extend(a:matches, split(output, '\n'))
      return 1
    else
      call xolox#misc#msg#warn("%s: scanner.py failed with output: %s", s:script, output)
    endif
  endif
endfunction

" Getters for filenames & titles of existing notes. {{{2

if !exists('s:cache_mtime')
  let s:have_cached_names = 0
  let s:have_cached_titles = 0
  let s:have_cached_items = 0
  let s:cached_fnames = []
  let s:cached_titles = []
  let s:cached_pairs = {}
  let s:cache_mtime = 0
endif

function! xolox#notes#get_fnames() " {{{3
  " Get list with filenames of all existing notes.
  if !s:have_cached_names
    let starttime = xolox#misc#timer#start()
    for directory in [g:notes_shadowdir, g:notes_directory]
      let pattern = xolox#misc#path#merge(directory, '*')
      let listing = glob(xolox#misc#path#absolute(pattern))
      call extend(s:cached_fnames, split(listing, '\n'))
    endfor
    let s:have_cached_names = 1
    call xolox#misc#timer#stop('%s: Cached note filenames in %s.', s:script, starttime)
  endif
  return copy(s:cached_fnames)
endfunction

function! xolox#notes#get_titles() " {{{3
  " Get list with titles of all existing notes.
  if !s:have_cached_titles
    let starttime = xolox#misc#timer#start()
    for filename in xolox#notes#get_fnames()
      call add(s:cached_titles, xolox#notes#fname_to_title(filename))
    endfor
    let s:have_cached_titles = 1
    call xolox#misc#timer#stop('%s: Cached note titles in %s.', s:script, starttime)
  endif
  return copy(s:cached_titles)
endfunction

function! xolox#notes#get_fnames_and_titles() " {{{3
  " Get dictionary of filename => title pairs of all existing notes.
  if !s:have_cached_items
    let starttime = xolox#misc#timer#start()
    let fnames = xolox#notes#get_fnames()
    let titles = xolox#notes#get_titles()
    let limit = len(fnames)
    let index = 0
    while index < limit
      let s:cached_pairs[fnames[index]] = titles[index]
      let index += 1
    endwhile
    let s:have_cached_items = 1
    call xolox#misc#timer#stop('%s: Cached note filenames and titles in %s.', s:script, starttime)
  endif
  return s:cached_pairs
endfunction

function! xolox#notes#fname_to_title(filename) " {{{3
  " Convert absolute note {filename} to title.
  return xolox#misc#path#decode(fnamemodify(a:filename, ':t'))
endfunction

function! xolox#notes#title_to_fname(title) " {{{3
  " Convert note {title} to absolute filename.
  let filename = xolox#misc#path#encode(a:title)
  if filename != ''
    let pathname = xolox#misc#path#merge(g:notes_directory, filename)
    return xolox#misc#path#absolute(pathname)
  endif
  return ''
endfunction

function! xolox#notes#cache_add(filename, title) " {{{3
  " Add {filename} and {title} of new note to cache.
  let filename = xolox#misc#path#absolute(a:filename)
  if index(s:cached_fnames, filename) == -1
    call add(s:cached_fnames, filename)
    if !empty(s:cached_titles)
      call add(s:cached_titles, a:title)
    endif
    if !empty(s:cached_pairs)
      let s:cached_pairs[filename] = a:title
    endif
    let s:cache_mtime = localtime()
  endif
endfunction

function! xolox#notes#cache_del(filename) " {{{3
  " Delete {filename} from cache.
  let filename = xolox#misc#path#absolute(a:filename)
  let index = index(s:cached_fnames, filename)
  if index >= 0
    call remove(s:cached_fnames, index)
    if !empty(s:cached_titles)
      call remove(s:cached_titles, index)
    endif
    if !empty(s:cached_pairs)
      call remove(s:cached_pairs, filename)
    endif
    let s:cache_mtime = localtime()
  endif
endfunction

function! xolox#notes#unload_from_cache() " {{{3
  let bufname = expand('<afile>:p')
  if !filereadable(bufname)
    call xolox#notes#cache_del(bufname)
  endif
endfunction

" Functions called by the file type plug-in and syntax script. {{{2

function! xolox#notes#insert_quote(style) " {{{3
  " XXX When I pass the below string constants as arguments from the file type
  " plug-in the resulting strings contain mojibake (UTF-8 interpreted as
  " latin1?) even if both scripts contain a UTF-8 BOM! Maybe a bug in Vim?!
  if xolox#notes#unicode_enabled()
    let [open_quote, close_quote] = a:style == 1 ? ['‘', '’'] : ['“', '”']
  else
    let [open_quote, close_quote] = a:style == 1 ? ['`', "'"] : ['"', '"']
  endif
  return getline('.')[col('.')-2] =~ '\S$' ? close_quote : open_quote
endfunction

function! xolox#notes#insert_bullet(chr) " {{{3
  " Insert a UTF-8 list bullet when the user types "*".
  if xolox#notes#unicode_enabled()
    if getline('.')[0 : max([0, col('.') - 2])] =~ '^\s*$'
      return '•'
    endif
  endif
  return a:chr
endfunction

function! xolox#notes#indent_list(command, line1, line2) " {{{3
  " Change indent of list items from {line1} to {line2} using {command}.
  if a:line1 == a:line2 && getline(a:line1) == ''
    call setline(a:line1, repeat(' ', &tabstop))
  else
    execute a:line1 . ',' . a:line2 . 'normal' a:command
    if getline('.') =~ '\(•\|\*\)$'
      call setline('.', getline('.') . ' ')
    endif
  endif
  normal $
endfunction

function! xolox#notes#highlight_names(force) " {{{3
  " Highlight the names of all notes as "notesName" (linked to "Underlined").
  if a:force || !(exists('b:notes_names_last_highlighted') && b:notes_names_last_highlighted > s:cache_mtime)
    let starttime = xolox#misc#timer#start()
    let titles = filter(xolox#notes#get_titles(), '!empty(v:val)')
    call map(titles, 's:words_to_pattern(v:val)')
    call sort(titles, 's:sort_longest_to_shortest')
    syntax clear notesName
    execute 'syntax match notesName /\c\%>2l\<\%(' . escape(join(titles, '\|'), '/') . '\)\>/'
    let b:notes_names_last_highlighted = localtime()
    call xolox#misc#timer#stop("%s: Highlighted note names in %s.", s:script, starttime)
  endif
endfunction

function! s:words_to_pattern(words)
  " Quote regex meta characters, enable matching of hard wrapped words.
  return substitute(xolox#misc#escape#pattern(a:words), '\s\+', '\\_s\\+', 'g')
endfunction

function! s:sort_longest_to_shortest(a, b)
  " Sort note titles by length, starting with the shortest.
  return len(a:a) < len(a:b) ? 1 : -1
endfunction

function! xolox#notes#highlight_sources(sg, eg) " {{{3
  " Syntax highlight source code embedded in notes.
  let starttime = xolox#misc#timer#start()
  let lines = getline(1, '$')
  let filetypes = {}
  for line in getline(1, '$')
    let ft = matchstr(line, '{{' . '{\zs\w\+\>')
    if ft !~ '^\d*$' | let filetypes[ft] = 1 | endif
  endfor
  for ft in keys(filetypes)
    let group = 'notesSnippet' . toupper(ft)
    let include = s:syntax_include(ft)
    let command = 'syntax region %s matchgroup=%s start="{{{%s" matchgroup=%s end="}}}" keepend contains=%s%s'
    execute printf(command, group, a:sg, ft, a:eg, include, has('conceal') ? ' concealends' : '')
  endfor
  call xolox#misc#timer#stop("%s: Highlighted embedded sources in %s.", s:script, starttime)
endfunction

function! s:syntax_include(filetype)
  " Include the syntax highlighting of another {filetype}.
  let grouplistname = '@' . toupper(a:filetype)
  " Unset the name of the current syntax while including the other syntax
  " because some syntax scripts do nothing when "b:current_syntax" is set.
  if exists('b:current_syntax')
    let syntax_save = b:current_syntax
    unlet b:current_syntax
  endif
  try
    execute 'syntax include' grouplistname 'syntax/' . a:filetype . '.vim'
    execute 'syntax include' grouplistname 'after/syntax/' . a:filetype . '.vim'
  catch /E484/
    " Ignore missing scripts.
  endtry
  " Restore the name of the current syntax.
  if exists('syntax_save')
    let b:current_syntax = syntax_save
  elseif exists('b:current_syntax')
    unlet b:current_syntax
  endif
  return grouplistname
endfunction

function! xolox#notes#include_expr(fname) " {{{3
  " Translate string {fname} to absolute filename of note.
  " TODO Use inputlist() when more than one note matches?!
  let notes = copy(xolox#notes#get_fnames_and_titles())
  let pattern = xolox#misc#escape#pattern(a:fname)
  call filter(notes, 'v:val =~ pattern')
  if !empty(notes)
    let filtered_notes = items(notes)
    let lnum = line('.')
    for range in range(3)
      let line1 = lnum - range
      let line2 = lnum + range
      let text = s:normalize_ws(join(getline(line1, line2), "\n"))
      for [fname, title] in filtered_notes
        if text =~? xolox#misc#escape#pattern(s:normalize_ws(title))
          return fname
        endif
      endfor
    endfor
  endif
  return ''
endfunction

function! s:normalize_ws(s)
  " Enable string comparison that ignores differences in whitespace.
  return xolox#misc#str#trim(substitute(a:s, '\_s\+', '', 'g'))
endfunction

function! xolox#notes#foldexpr() " {{{3
  " Folding expression to fold atx style Markdown headings.
  let lastlevel = foldlevel(v:lnum - 1)
  let nextlevel = match(getline(v:lnum), '^#\+\zs')
  if lastlevel <= 0 && nextlevel >= 1
    return '>' . nextlevel
  elseif nextlevel >= 1
    if lastlevel > nextlevel
      return '<' . nextlevel
    else
      return '>' . nextlevel
    endif
  endif
  return '='
endfunction

function! xolox#notes#foldtext() " {{{3
  " Replace atx style "#" markers with "-" fold marker.
  let line = getline(v:foldstart)
  if line == ''
    let line = getline(v:foldstart + 1)
  endif
  let matches = matchlist(line, '^\(#\+\)\s*\(.*\)$')
  if len(matches) >= 3
    let prefix = repeat('-', len(matches[1]))
    return prefix . ' ' . matches[2] . ' '
  else
    return line
  endif
endfunction

" vim: ts=2 sw=2 et bomb
