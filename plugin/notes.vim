" Vim plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: December 13, 2011
" URL: http://peterodding.com/code/vim/notes/

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3375 1 :AutoInstall: notes.zip

" Don't source the plug-in when it's already been loaded or &compatible is set.
if &cp || exists('g:loaded_notes')
  finish
endif

" Initialize the configuration defaults.
call xolox#notes#init()

" User commands to create, delete and search notes.
command! -bar -bang -nargs=? -complete=customlist,xolox#notes#cmd_complete Note call xolox#notes#edit(<q-bang>, <q-args>)
command! -bar -bang -nargs=? -complete=customlist,xolox#notes#cmd_complete DeleteNote call xolox#notes#delete(<q-bang>, <q-args>)
command! -bang -nargs=? -complete=customlist,xolox#notes#keyword_complete SearchNotes call xolox#notes#search(<q-bang>, <q-args>)
command! -bar -bang RelatedNotes call xolox#notes#related(<q-bang>)
command! -bar -bang -nargs=? RecentNotes call xolox#notes#recent(<q-bang>, <q-args>)
command! -bar -count=1 ShowTaggedNotes call xolox#notes#tags#show_tags(<count>)
command! -bar IndexTaggedNotes call xolox#notes#tags#create_index()

" Checkbox toggling commands
command! -bar NoteToggleCheckbox call xolox#notes#toggle_checkbox()
command! -bar NoteToggleCheckboxTimestamp call xolox#notes#toggle_checkbox_timestamp()

" TODO Generalize this so we have one command + modifiers (like :tab)?
command! -bar -bang -range NoteFromSelectedText call xolox#notes#from_selection(<q-bang>, 'edit')
command! -bar -bang -range SplitNoteFromSelectedText call xolox#notes#from_selection(<q-bang>, 'vsplit')
command! -bar -bang -range TabNoteFromSelectedText call xolox#notes#from_selection(<q-bang>, 'tabnew')

" Automatic commands to enable the :edit note:… shortcut and load the notes file type.

augroup PluginNotes
  autocmd!
  au SwapExists * call xolox#notes#swaphack()
  au BufUnload * call xolox#notes#unload_from_cache()
  au BufReadPost,BufWritePost * call xolox#notes#refresh_syntax()
  au InsertEnter,InsertLeave * call xolox#notes#refresh_syntax()
  au CursorHold,CursorHoldI * call xolox#notes#refresh_syntax()
  " NB: "nested" is used here so that SwapExists automatic commands apply
  " to notes (which is IMHO better than always showing the E325 prompt).
  au BufReadCmd note:* nested call xolox#notes#shortcut()
  " Automatic commands to read/write notes (used for automatic renaming).
  exe 'au BufReadCmd' xolox#notes#autocmd_pattern(g:notes_shadowdir, 0) 'call xolox#notes#edit_shadow()'
  exe 'au BufWriteCmd' xolox#notes#autocmd_pattern(g:notes_directory, 1) 'call xolox#notes#save()'
augroup END

augroup filetypedetect
  let s:template = 'au BufNewFile,BufRead %s if &bt == "" | setl ft=notes | end'
  execute printf(s:template, xolox#notes#autocmd_pattern(g:notes_directory, 1))
  execute printf(s:template, xolox#notes#autocmd_pattern(g:notes_shadowdir, 0))
augroup END

" Make sure the plug-in is only loaded once.
let g:loaded_notes = 1

" vim: ts=2 sw=2 et
