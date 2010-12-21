" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: December 21, 2010
" URL: http://peterodding.com/code/vim/notes/
" License: MIT
" Version: 0.7.1

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('g:loaded_notes')
  finish
endif

" Define the default location where the user's notes are saved?
if !exists('g:notes_directory')
  if xolox#is_windows()
    let g:notes_directory = '~/vimfiles/misc/notes/user'
  else
    let g:notes_directory = '~/.vim/misc/notes/user'
  endif
endif

" Define the default location of the shadow directory with predefined notes?
if !exists('g:notes_shadowdir')
  if xolox#is_windows()
    let g:notes_shadowdir = '~/vimfiles/misc/notes/shadow'
  else
    let g:notes_shadowdir = '~/.vim/misc/notes/shadow'
  endif
endif

" Define the default location for the full text index.
if !exists('g:notes_indexfile')
  if xolox#is_windows()
    let g:notes_indexfile = '~/vimfiles/misc/notes/index.sqlite3'
  else
    let g:notes_indexfile = '~/.vim/misc/notes/index.sqlite3'
  endif
endif

" Define the default location for the keyword scanner script.
if !exists('g:notes_indexscript')
  if xolox#is_windows()
    let g:notes_indexscript = '~/vimfiles/misc/notes/scanner.py'
  else
    let g:notes_indexscript = '~/.vim/misc/notes/scanner.py'
  endif
endif

" Define user commands to create notes.
command! -bar -bang NewNote call xolox#notes#new(<q-bang>)
command! -bar -bang DeleteNote call xolox#notes#delete(<q-bang>)
command! -bar -bang -nargs=1 SearchNotes call xolox#notes#search(<q-bang>, <q-args>)
command! -bar -bang RelatedNotes call xolox#notes#related(<q-bang>)

" Install an automatic command to edit notes using filenames like "note:todo".
augroup PluginNotes
  autocmd!
  " NB: "nested" is used here so that SwapExists automatic commands apply
  " to notes (which is IMHO better than always showing the E325 prompt).
  au BufReadCmd note:* nested call xolox#notes#edit()
  au SwapExists * call xolox#notes#swaphack()
augroup END

" Install automatic commands that recognize the notes file type.

function! s:NewAutoCmd(directory)
  " Resolve the path to the directory with notes. Because Vim matches filename
  " patterns in automatic commands after resolving the filename, this makes sure
  " the automatic command below always applies, even in case of symbolic links.
  let directory = xolox#path#absolute(a:directory)
  let pattern = xolox#path#merge(fnameescape(directory), '*')
  augroup filetypedetect
    exe 'au BufNewFile,BufRead,BufWritePost' pattern 'if &bt == "" | setl ft=notes | endif'
  augroup END
endfunction

call s:NewAutoCmd(g:notes_directory)
call s:NewAutoCmd(g:notes_shadowdir)

" Make sure the plug-in is only loaded once.
let g:loaded_notes = 1

" vim: ts=2 sw=2 et
