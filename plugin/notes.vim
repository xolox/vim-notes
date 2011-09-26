" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: September 4, 2011
" URL: http://peterodding.com/code/vim/notes/

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3375 1 :AutoInstall: notes.zip

" Don't source the plug-in when it's already been loaded or &compatible is set.
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

" Define the default suffix for note filenames.
if !exists('g:notes_suffix')
  let g:notes_suffix = ''
endif

" Define the default location for the tag name index (used for completion).
if !exists('g:notes_tagsindex')
  let g:notes_tagsindex = s:plugindir . '/tags.txt'
endif

" User commands to create, delete and search notes.
command! -bar -bang -nargs=? -complete=customlist,xolox#notes#cmd_complete Note call xolox#notes#edit(<q-bang>, <q-args>)
command! -bar -bang -range NoteFromSelectedText call xolox#notes#from_selection(<q-bang>)
command! -bar -bang -nargs=? -complete=customlist,xolox#notes#cmd_complete DeleteNote call xolox#notes#delete(<q-bang>, <q-args>)
command! -bang -nargs=? SearchNotes call xolox#notes#search(<q-bang>, <q-args>)
command! -bar -bang RelatedNotes call xolox#notes#related(<q-bang>)
command! -bar -bang -nargs=? RecentNotes call xolox#notes#recent(<q-bang>, <q-args>)
command! -bar -count=1 ShowTaggedNotes call xolox#notes#tags#show_tags(<count>)
command! -bar IndexTaggedNotes call xolox#notes#tags#create_index()

" Automatic commands to enable the :edit note:… shortcut and load the notes file type.

function! s:DAC(events, directory, command)
  " Define automatic command for {events} in {directory} with {command}.
  " Resolve the path to the directory with notes so that the automatic command
  " also applies to symbolic links pointing to notes (Vim matches filename
  " patterns in automatic commands after resolving filenames).
  let directory = xolox#misc#path#absolute(a:directory)
  " On Windows we have to replace backslashes with forward slashes.
  if xolox#misc#os#is_win()
    let directory = substitute(directory, '\\', '/', 'g')
  endif
  let pattern = fnameescape(directory) . '/*'
  " On Windows the pattern won't match if it contains repeating slashes.
  let pattern = substitute(pattern, '/\+', '/', 'g')
  execute 'autocmd' a:events pattern a:command
endfunction

augroup PluginNotes
  autocmd!
  " NB: "nested" is used here so that SwapExists automatic commands apply
  " to notes (which is IMHO better than always showing the E325 prompt).
  au BufReadCmd note:* nested call xolox#notes#shortcut()
  call s:DAC('BufReadCmd', g:notes_shadowdir, 'call xolox#notes#edit_shadow()')
  call s:DAC('BufWriteCmd', g:notes_directory, 'call xolox#notes#save()')
  au SwapExists * call xolox#notes#swaphack()
  au WinEnter * if &ft == 'notes' | call xolox#notes#highlight_names(0) | endif
  au BufReadPost * if &ft == 'notes' | unlet! b:notes_names_last_highlighted | endif
  au BufUnload * if &ft == 'notes' | call xolox#notes#unload_from_cache() | endif
augroup END

augroup filetypedetect
  call s:DAC('BufNewFile,BufRead', g:notes_directory, 'if &bt == "" | setl ft=notes | endif')
  call s:DAC('BufNewFile,BufRead', g:notes_shadowdir, 'if &bt == "" | setl ft=notes | endif')
augroup END

delfunction s:DAC

" Make sure the plug-in is only loaded once.
let g:loaded_notes = 1

" vim: ts=2 sw=2 et
