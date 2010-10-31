" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: October 31, 2010
" URL: http://peterodding.com/code/vim/notes/
" License: MIT
" Version: 0.6

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('g:loaded_notes')
  finish
endif

" Define the default location where notes are saved?
if !exists('g:notes_location')
	if xolox#is_windows()
		let g:notes_location = '~/vimfiles/notes/%s'
	else
		let g:notes_location = '~/.vim/notes/%s'
	endif
endif

" Define user commands to create notes.
command! -bar -bang NewNote call xolox#notes#new(<q-bang>)
command! -bar -bang SaveNote call xolox#notes#save(<q-bang>)

" Install an automatic command to edit notes using filenames like "note:todo".
augroup PluginNotes
	autocmd!
  " NB: "nested" is used here so that any SwapExists automatic command applies
  " to your notes (which is IMHO better than always showing the E325 prompt).
	au BufReadCmd note:* nested call xolox#notes#edit()
augroup END

" Resolve the path to the directory with notes. Because Vim matches filename
" patterns in automatic commands after resolving the filename, this makes sure
" the automatic command below always applies, even in case of symbolic links.
let s:directory = xolox#path#absolute(fnamemodify(g:notes_location, ':h'))
let s:basename = printf(fnamemodify(g:notes_location, ':t'), '*')
let s:pattern = xolox#path#merge(fnameescape(s:directory), s:basename)

" Install an automatic command that sets the notes file type for files
" inside the directory configured by the g:notes_location option.
augroup filetypedetect
	exe 'au BufNewFile,BufRead,BufWritePost' s:pattern 'setl ft=notes'
augroup END

unlet s:directory s:basename s:pattern

" Make sure the plug-in is only loaded once.
let g:loaded_notes = 1

" vim: ts=2 sw=2 et
