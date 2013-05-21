" This Vim script was modified by a Python script that I use to manage the
" inclusion of miscellaneous functions in the plug-ins that I publish to Vim
" Online and GitHub. Please don't edit this file, instead make your changes on
" the 'dev' branch of the git repository (thanks!). This file was generated on
" May 21, 2013 at 03:00.

" Vim script
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: June 11, 2011
" Related files:
"  http://peterodding.com/vim/plugin/notes.vim
"  http://peterodding.com/vim/ftplugin/notes.vim
"  http://peterodding.com/vim/syntax/notes.vim
" Required files:
"  http://peterodding.com/vim/autoload/project.vim
"  http://peterodding.com/vim/autoload/peterodding/escape.vim

" FIXME Cannot jump to notes with single quotes in their title
" TODO Create and keep up to date an index of cross references between notes
" to make it easier and faster to rename notes including cross references.
" This also enables me to remove the dialog that allows you to rename 
" enables the user to cancel
" the rename [for example because it takes to long and you don't want to
" interrupt your train of thought by waiting while Vim searches through all of
" your notes, which is >= 443

let s:script = expand('<sfile>:p:~')
let s:notes_list_bufname = '[All Notes]'
let s:notes_file_type = 'notes'

function! notes#maximize() " {{{1
	hide only
	setlocal noshowmode noruler
	let &l:titlestring = getline(1)
	let &lines = line('$') + 2
	let &columns = max(map(getline(1, '$'), 'strlen(v:val)'))
endfunction

function! notes#save_note(overwrite, arguments) abort " {{{1
	...
	" Save note under generated filename.
	silent execute 'saveas' . (overwrite ? '!' : '') a:arguments fnameescape(filename)
	if exists('b:note_fname') && b:note_fname != '' && !xolox#path#equals(b:note_fname, filename)
		" Replace references to old note with references to new note in text of other notes?
		let prompt = "Do you want to update references to `%s' in your other notes?"
		if confirm(printf(prompt, title), "&Yes\n&No", 1) == 1
			let old_title = notes#get_title_from_fname(b:note_fname)
			let pattern = '\<' . xolox#escape#pattern(old_title) . '\>'
			let notes = project#create_project_with_files(notes#get_fnames_ro())
			" HACK: Using a script-local variable to pass the new name to the
			" callback didn't work so now I'm abusing the global "__new_note_name".
			let g:__new_note_name = title
			call project#replace_in_files(notes, pattern, '\=notes#save_note_callback()', 'eg')
			unlet g:__new_note_name
			call project#delete_project(notes)
		endif
	endif
endfunction

function! notes#save_note_callback()
	" TODO Don't substitute inside code blocks?
	let [titles, keywords] = notes#get_note_name_under_cursor()
	let default = len(titles) == 1 && titles[0] ==? submatch(0) ? 1 : 2
	let message = printf("Replace `%s' with `%s'?", submatch(0), g:__new_note_name)
	redraw
	return confirm(message, "&Yes\n&No", default) == 1 ? g:__new_note_name : submatch(0)
endfunction

function! notes#remove_empty_list_items() " {{{1
	if getline('.') =~ ('^\s*' . g:notes_list_bullet . '\s*$')
		call setline('.', '')
	endif
endfunction
