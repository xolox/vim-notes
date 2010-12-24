" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: December 24, 2010
" URL: http://peterodding.com/code/vim/notes/
" License: MIT
" Version: 0.7.11

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3375 1 :AutoInstall: session.zip

" Don't source the plug-in when its already been loaded or &compatible is set.
if &cp || exists('g:loaded_notes')
  finish
endif

" Make sure the default paths below are compatible with Pathogen.
let s:plugindir = expand('<sfile>:p:h') . '/../misc/notes'

" Define the default location where the user's notes are saved?
if !exists('g:notes_directory')
  let g:notes_directory = s:plugindir . '/user'
endif

" Define the default location of the shadow directory with predefined notes?
if !exists('g:notes_shadowdir')
  let g:notes_shadowdir = s:plugindir . '/shadow'
endif

" Define the default location for the full text index.
if !exists('g:notes_indexfile')
  let g:notes_indexfile = s:plugindir . '/index.sqlite3'
endif

" Define the default location for the keyword scanner script.
if !exists('g:notes_indexscript')
  let g:notes_indexscript = s:plugindir . '/scanner.py'
endif

" User commands to create, delete and search notes.
command! -bar -bang NewNote call xolox#notes#new(<q-bang>)
command! -bar -bang DeleteNote call xolox#notes#delete(<q-bang>)
command! -bar -bang -nargs=1 SearchNotes call xolox#notes#search(<q-bang>, <q-args>)
command! -bar -bang RelatedNotes call xolox#notes#related(<q-bang>)

" Automatic commands to enable the :edit note:… shortcut and load the notes file type.

function! s:DefAutoCmd(events, directory, command)
  " Resolve the path to the directory with notes; Vim matches filename
  " patterns in automatic commands after resolving filenames, which means
  " the automatic commands will also apply when symbolic links are used.
  let directory = xolox#path#absolute(a:directory)
  let pattern = xolox#path#merge(fnameescape(directory), '*')
  execute 'autocmd' a:events pattern a:command
endfunction

augroup PluginNotes
  autocmd!
  " NB: "nested" is used here so that SwapExists automatic commands apply
  " to notes (which is IMHO better than always showing the E325 prompt).
  au BufReadCmd note:* nested call xolox#notes#shortcut()
  au SwapExists * call xolox#notes#swaphack()
  au WinEnter * if &ft == 'notes' | call xolox#notes#highlight_names() | endif
  call s:DefAutoCmd('BufWritePost', g:notes_directory, 'call xolox#notes#cleanup()')
augroup END

augroup filetypedetect
  call s:DefAutoCmd('BufNewFile,BufRead,BufWritePost', g:notes_directory, 'if &bt == "" | setl ft=notes | endif')
  call s:DefAutoCmd('BufNewFile,BufRead,BufWritePost', g:notes_shadowdir, 'if &bt == "" | setl ft=notes | endif')
augroup END

" Make sure the plug-in is only loaded once.
let g:loaded_notes = 1

" vim: ts=2 sw=2 et
