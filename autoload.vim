" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: October 31, 2010
" URL: http://peterodding.com/code/vim/notes/

let s:script = expand('<sfile>:p:~')

function! xolox#notes#new(bang) " {{{1
  execute 'enew' . a:bang
  setlocal filetype=notes
endfunction

function! xolox#notes#edit() " {{{1
 	let starttime = xolox#timer#start()
	let notes = {}
	let filename = ''
	let arguments = string#trim(matchstr(expand('<afile>'), 'note:\zs.*'))
	for [fname, title] in xolox#notes#get_fnames_and_titles()
		if title ==? arguments
      " Found a case insensitive but otherwise exact match!
			let filename = fname
			break
		elseif title =~? arguments
      " Found a substring / regular expression match.
			let notes[title] = fname
		endif
	endfor
	if empty(filename)
		if len(notes) == 1
      " Only matched one filename using substring / regex match?
			let filename = values(notes)[0]
		elseif !empty(notes)
      " More than one note matched: ask user which to edit.
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

" Miscellaneous functions. {{{1

function! xolox#notes#get_fnames() " {{{2
	" Get a list with the filenames of all existing notes.
	if !s:have_cached_names
		let starttime = xolox#timer#start()
		let pattern = printf(g:notes_location, '*')
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

function! xolox#notes#get_titles() " {{{2
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

function! xolox#notes#get_fnames_and_titles() " {{{2
	" Get a list of lists with the title and filename of each existing note.
	" This function is intended to be used with Vim's :for statement:
	"  :for [filename, title] in xolox#notes#get_fnames_and_titles()
	"    ...
	"  :endfor
  " For efficiency this function caches the generated list after the first
  " call so if you want to modify it please make a copy with deepcopy().
	if !s:have_cached_items
		let starttime = xolox#timer#start()
		let fnames = xolox#notes#get_fnames()
		let titles = xolox#notes#get_titles()
		let limit = len(fnames)
		let index = 0
		while index < limit
			call add(s:cached_items, [fnames[index], titles[index]])
			let index += 1
		endwhile
		let s:have_cached_items = 1
		call xolox#timer#stop('%s: Cached note filenames and titles in %s.', s:script, starttime)
	endif
	return s:cached_items
endfunction

if !exists('s:cached_items')
	let s:have_cached_items = 0
	let s:cached_items = []
endif

function! xolox#notes#fname_to_title(filename) " {{{2
  " Return the title of a note given its absolute filename.
	return xolox#path#decode(fnamemodify(a:filename, ':t'))
endfunction

function! xolox#notes#title_to_fname(title) " {{{2
  " Return the absolute filename of a note given its title.
  let filename = xolox#path#encode(a:title)
  if filename != ''
    let pathname = printf(g:notes_location, filename)
    return xolox#path#absolute(pathname)
  endif
  return ''
endfunction

function! xolox#notes#add_to_cache(filename, title) " {{{2
	" Add filename and title of newly created note to cache.
	let filename = xolox#path#absolute(a:filename)
  if index(s:cached_fnames, filename) == -1
    call add(s:cached_fnames, filename)
    if !empty(s:cached_titles)
      call add(s:cached_titles, a:title)
    endif
    if !empty(s:cached_items)
      call add(s:cached_items, [filename, a:title])
    endif
  endif
endfunction

" vim: ts=2 sw=2 et nowrap
