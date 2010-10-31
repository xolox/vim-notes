" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: October 31, 2010
" URL: http://peterodding.com/code/vim/notes/

" Note: This file is encoded in UTF-8 including a byte order mark so
" that Vim loads the script using the right encoding transparently.

let s:script = expand('<sfile>:p:~')

function! xolox#notes#new(bang) " {{{1
  execute 'enew' . a:bang
  setlocal filetype=notes
  call setline(1, ['Enter a name for your note here', '', 'To save this note you can use the :SaveNote command. It will generate a filename based on the title in the first line of this note and will save the resulting file in the directory ' . g:notes_directory . '.'])
  3
  normal gqq
  setlocal nomodified
endfunction

function! xolox#notes#edit() " {{{1
  let starttime = xolox#timer#start()
  let notes = {}
  let filename = ''
  let arguments = string#trim(matchstr(expand('<afile>'), 'note:\zs.*'))
  for [fname, title] in items(xolox#notes#get_fnames_and_titles())
    " Prefer case insensitive but exact matches.
    if title ==? arguments
      let filename = fname
      break
    elseif title =~? arguments
      " Also check for substring or regex match.
      let notes[title] = fname
    endif
  endfor
  if empty(filename)
    if len(notes) == 1
      " Only matched one file using substring or regex match?
      let filename = values(notes)[0]
    elseif !empty(notes)
      " More than one file matched: ask user which to edit.
      let choices = ['Please select a note:']
      let values = ['']
      for title in sort(keys(notes))
        call add(choices, ' ' . len(choices) . ') ' . title)
        call add(values, notes[title])
      endfor
      let choice = inputlist(choices)
      if choice <= 0 || choice >= len(choices)
        " User did not select a valid note.
        return
      endif
      let filename = values[choice]
    endif
  endif
  if empty(filename)
    echoerr "No matching notes!"
  else
    execute 'edit' . (v:cmdbang ? '!' : '') v:cmdarg fnameescape(filename)
    setlocal filetype=notes
    call xolox#timer#stop('%s: Opened note in %s.', s:script, starttime)
  endif
endfunction

function! xolox#notes#save(bang) " {{{1
  " Generate filename from note title (1st line).
  let title = getline(1)
  let filename = xolox#notes#title_to_fname(title)
  if empty(filename)
    echoerr printf("%s: Invalid note title %s!", s:script, title)
    return
  endif
  " Validate notes directory, create it if necessary.
  let directory = fnamemodify(filename, ':h')
  if !isdirectory(directory)
    try
      call mkdir(directory, 'p')
    catch
      echoerr printf("%s: Failed to create notes directory at %s!", s:script, directory)
      return
    endtry
  endif
  if filewritable(directory) != 2
    echoerr printf("%s: The notes directory %s isn't writable!", s:script, directory)
    return
  endif
  " Write the buffer to the selected location.
  silent execute 'saveas' . a:bang fnameescape(filename)
  " Add the note to the internal cache.
  call xolox#notes#add_to_cache(filename, title)
endfunction

function! xolox#notes#search(bang, pattern, excluded) " {{{1
  let starttime = xolox#timer#start()
  silent cclose
  let args = [fnameescape(a:pattern)]
  for fname in xolox#notes#get_fnames()
    if index(a:excluded, fname) == -1
      call add(args, fnameescape(fname))
    endif
  endfor
  try
    let ei_save = &eventignore
    set eventignore=all
    execute 'vimgrep' . a:bang join(args)
  finally
    let &eventignore = ei_save
  endtry
  silent cwindow
  if &buftype == 'quickfix'
    let w:quickfix_title = 'Notes matching ' . a:pattern
    let pattern = a:pattern
    if pattern =~ '^/.*/$'
      let pattern = substitute(pattern[1 : len(pattern) - 2], '\\/', '/', 'g')
    endif
    let pattern = '/\c' . escape(pattern, '/') . '/'
    execute 'match IncSearch' pattern
  endif
  call xolox#timer#stop('%s: Searched notes in %s.', s:script, starttime)
endfunction

function! xolox#notes#related(bang) " {{{1
  let excluded = []
  if xolox#path#equals(g:notes_directory, expand('%:h'))
    let filename = xolox#notes#title_to_fname(getline(1))
    let pattern = xolox#escape#pattern(getline(1))
    call add(excluded, filename)
  else
    let filename = xolox#path#absolute(expand('%'))
    let pattern = xolox#escape#pattern(filename)
    if filename[0 : len($HOME)-1] == $HOME
      let relative = xolox#path#relative(filename, xolox#path#absolute($HOME))
      let pattern = '\(' . pattern . '\|\~/' . relative . '\)'
    endif
  endif
  let pattern = '/' . escape(pattern, '/') . '/'
  " call confirm(pattern)
  call xolox#notes#search(a:bang, pattern, excluded)
  if &buftype == 'quickfix'
    let w:quickfix_title = 'Notes related to ' . fnamemodify(filename, ':~')
  endif
endfunction

" Miscellaneous functions. {{{1

" Getters for filenames and titles of existing notes. {{{2

function! xolox#notes#get_fnames() " {{{3
  " Get a list with the filenames of all existing notes.
  if !s:have_cached_names
    let starttime = xolox#timer#start()
    let pattern = xolox#path#merge(g:notes_directory, '*')
    let listing = glob(xolox#path#absolute(pattern))
    call extend(s:cached_fnames, split(listing, '\n'))
    let s:have_cached_names = 1
    call xolox#timer#stop('%s: Cached note filenames in %s.', s:script, starttime)
  endif
  return copy(s:cached_fnames)
endfunction

if !exists('s:cached_fnames')
  let s:have_cached_names = 0
  let s:cached_fnames = []
endif

function! xolox#notes#get_titles() " {{{3
  " Get a list with the titles of all existing notes.
  if !s:have_cached_titles
    let starttime = xolox#timer#start()
    for filename in xolox#notes#get_fnames()
      call add(s:cached_titles, xolox#notes#fname_to_title(filename))
    endfor
    let s:have_cached_titles = 1
    call xolox#timer#stop('%s: Cached note titles in %s.', s:script, starttime)
  endif
  return copy(s:cached_titles)
endfunction

if !exists('s:cached_titles')
  let s:have_cached_titles = 0
  let s:cached_titles = []
endif

function! xolox#notes#get_fnames_and_titles() " {{{3
  if !s:have_cached_items
    let starttime = xolox#timer#start()
    let fnames = xolox#notes#get_fnames()
    let titles = xolox#notes#get_titles()
    let limit = len(fnames)
    let index = 0
    while index < limit
      let s:cached_pairs[fnames[index]] = titles[index]
      let index += 1
    endwhile
    let s:have_cached_items = 1
    call xolox#timer#stop('%s: Cached note filenames and titles in %s.', s:script, starttime)
  endif
  return s:cached_pairs
endfunction

if !exists('s:cached_pairs')
  let s:have_cached_items = 0
  let s:cached_pairs = {}
endif

function! xolox#notes#fname_to_title(filename) " {{{3
  " Return the title of a note given its absolute filename.
  return xolox#path#decode(fnamemodify(a:filename, ':t'))
endfunction

function! xolox#notes#title_to_fname(title) " {{{3
  " Return the absolute filename of a note given its title.
  let filename = xolox#path#encode(a:title)
  if filename != ''
    let pathname = xolox#path#merge(g:notes_directory, filename)
    return xolox#path#absolute(pathname)
  endif
  return ''
endfunction

function! xolox#notes#add_to_cache(filename, title) " {{{3
  " Add filename and title of newly created note to cache.
  let filename = xolox#path#absolute(a:filename)
  if index(s:cached_fnames, filename) == -1
    call add(s:cached_fnames, filename)
    if !empty(s:cached_titles)
      call add(s:cached_titles, a:title)
    endif
    if !empty(s:cached_pairs)
      call add(s:cached_pairs, [filename, a:title])
    endif
  endif
endfunction

" Functions called by the file type plug-in and syntax script. {{{2

function! xolox#notes#insert_quote(style) " {{{3
  " If I pass the below string constants as arguments from the file type
  " plug-in the resulting strings contain mojibake (UTF-8 interpreted as
  " latin1?) even if both scripts contain a UTF-8 BOM. Bug in Vim?!
  if a:style == 1
    let open_quote = '‘'
    let close_quote = '’'
  else
    let open_quote = '“'
    let close_quote = '”'
  endif
  return getline('.')[col('.')-2] =~ '\S$' ? close_quote : open_quote
endfunction

function! xolox#notes#insert_bullet(c) " {{{3
  return getline('.')[0 : max([0, col('.') - 2])] =~ '^\s*$' ? '•' : a:c
endfunction

function! xolox#notes#highlight_names(group) " {{{3
  let starttime = xolox#timer#start()
  let titles = filter(xolox#notes#get_titles(), '!empty(v:val)')
  call map(titles, 's:transform_note_names(v:val)')
  call sort(titles, 's:sort_longest_to_shortest')
  execute 'syntax match' a:group '/\c\%>2l\%(' . join(titles, '\|') . '\)/'
  call xolox#timer#stop("%s: Highlighted note names in %s.", s:script, starttime)
endfunction

function! s:transform_note_names(name)
  let escaped = escape(xolox#escape#pattern(v:val), "/")
  return substitute(escaped, '\s\+', '\\_s\\+', 'g')
endfunction

function! s:sort_longest_to_shortest(a, b)
  return len(a:a) < len(a:b) ? 1 : -1
endfunction

function! xolox#notes#highlight_sources(sg, eg) " {{{3
  let starttime = xolox#timer#start()
  let lines = getline(1, '$')
  let filetypes = {}
  for line in getline(1, '$')
    let ft = matchstr(line, '{{' . '{\zs\w\+\>')
    if ft !~ '^\d*$' | let filetypes[ft] = 1 | endif
  endfor
  for ft in keys(filetypes)
    let group = 'notesSnippet' . toupper(ft)
    let include = s:syntax_include(ft)
    let command = 'syntax region %s matchgroup=%s start="{{{%s" matchgroup=%s end="}}}" keepend contains=%s'
    execute printf(command, group, a:sg, ft, a:eg, include)
  endfor
  call xolox#timer#stop("%s: Highlighted embedded sources in %s.", s:script, starttime)
endfunction

function! s:syntax_include(filetype)
  " Include the syntax highlighting of another file type.
  let grouplistname = '@' . toupper(a:filetype)
  " Unset the name of the current syntax while including the other syntax
  " because some syntax scripts do nothing when b:current_syntax is set.
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

function! xolox#notes#find_at_cursor() " {{{3
  let matches = []
  let notes = copy(xolox#notes#get_fnames_and_titles())
  let pattern = xolox#escape#pattern(expand('<cword>'))
  call filter(notes, 'v:val =~ pattern')
  if !empty(notes)
    let filtered_notes = items(notes)
    let lnum = line('.')
    for range in range(3)
      let line1 = lnum - range
      let line2 = lnum + range
      call xolox#debug("%s: Scanning range %i-%i..", s:script, line1, line2)
      let text = s:normalize_ws(join(getline(line1, line2), "\n"))
      for [fname, title] in filtered_notes
        if text =~? xolox#escape#pattern(s:normalize_ws(title))
          call add(matches, fname)
        endif
      endfor
      if !empty(matches)
        break
      endif
    endfor
  endif
  return matches
endfunction

function! s:normalize_ws(s)
  return xolox#trim(substitute(a:s, '\_s\+', '', 'g'))
endfunction

function! xolox#notes#goto_note() " {{{3
  let notes = xolox#notes#find_at_cursor()
  if !empty(notes)
    execute 'edit' fnameescape(notes[0])
  endif
endfunction

" vim: ts=2 sw=2 et bomb
