" Vim file type plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: December 21, 2010
" URL: http://peterodding.com/code/vim/notes/

if exists('b:did_ftplugin')
  finish
else
  let b:did_ftplugin = 1
endif

" Remember the original title of the current note.
call xolox#notes#remember_title()

" Disable highlighting of matching pairs. {{{1
setlocal matchpairs=
let b:undo_ftplugin = 'set matchpairs<'

" Copy indent from previous line. {{{1
setlocal autoindent
let b:undo_ftplugin .= ' autoindent<'

" Automatic formatting for bulleted lists. {{{1
let &l:comments = ': • ,:> '
let &l:commentstring = '> %s'
setlocal formatoptions=tcron
let b:undo_ftplugin .= ' commentstring< comments< formatoptions<'

" Automatic text folding based on headings. {{{1
setlocal foldmethod=expr
setlocal foldexpr=xolox#notes#foldexpr()
setlocal foldtext=xolox#notes#foldtext()
let b:undo_ftplugin .= ' foldmethod< foldexpr< foldtext<'

" Change <cfile> to jump to notes by name. {{{1
setlocal includeexpr=xolox#notes#cfile(1,v:fname)
let b:undo_ftplugin .= ' includeexpr<'

" Change double-dash to em-dash as it is typed. {{{1
imap <buffer> -- —
let b:undo_ftplugin .= ' | execute "iunmap <buffer> --"'

" Change plain quotes to curly quotes as they're typed. {{{1
imap <buffer> <expr> ' xolox#notes#insert_quote(1)
imap <buffer> <expr> " xolox#notes#insert_quote(2)
let b:undo_ftplugin .= ' | execute "iunmap <buffer> ''"'
let b:undo_ftplugin .= ' | execute ''iunmap <buffer> "'''

" Change ASCII style arrows to Unicode arrows. {{{1
imap <buffer> -> →
imap <buffer> <- ←
let b:undo_ftplugin .= ' | execute "iunmap <buffer> ->"'
let b:undo_ftplugin .= ' | execute "iunmap <buffer> <-"'

" Convert ASCII list bullets to Unicode bullets. {{{1
imap <buffer> <expr> - xolox#notes#insert_bullet('-')
imap <buffer> <expr> + xolox#notes#insert_bullet('+')
imap <buffer> <expr> * xolox#notes#insert_bullet('*')
let b:undo_ftplugin .= ' | execute "iunmap <buffer> -"'
let b:undo_ftplugin .= ' | execute "iunmap <buffer> +"'
let b:undo_ftplugin .= ' | execute "iunmap <buffer> *"'

" Automatically (re)name buffers containing notes. {{{1
autocmd! CursorMoved,CursorMovedI <buffer> call xolox#notes#rename()
let b:undo_ftplugin .= ' | execute "autocmd! CursorMoved,CursorMovedI <buffer> "'

" vim: ts=2 sw=2 et
