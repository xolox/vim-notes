" Vim file type plug-in
" Author: Peter Odding <peter@peterodding.com>
" Last Change: October 31, 2010
" URL: http://peterodding.com/code/vim/notes/

" Note: This file is encoded in UTF-8 including a byte order mark so
" that Vim loads the script using the right encoding transparently.

if exists('b:did_ftplugin')
  finish
else
  let b:did_ftplugin = 1
endif

" Disable highlighting of matching pairs.
setlocal matchpairs=
let b:undo_ftplugin = 'set matchpairs<'

" Copy indent from previous line.
setlocal autoindent
let b:undo_ftplugin .= ' autoindent<'

" Automatically change double-dash to em-dash as it is typed.
imap <buffer> -- —
let b:undo_ftplugin .= ' | execute "iunmap <buffer> --"'

" Automatically change plain quotes to curly quotes as they're typed?
imap <buffer> <expr> ' xolox#notes#insert_quote(1)
imap <buffer> <expr> " xolox#notes#insert_quote(2)
let b:undo_ftplugin .= ' | execute "iunmap <buffer> ''"'
let b:undo_ftplugin .= ' | execute ''iunmap <buffer> "'''

" Change ASCII style arrows to Unicode arrows.
imap <buffer> -> →
imap <buffer> <- ←
let b:undo_ftplugin .= ' | execute "iunmap <buffer> ->"'
let b:undo_ftplugin .= ' | execute "iunmap <buffer> <-"'

" Insert list leaders automatically.
imap <buffer> <expr> - xolox#notes#insert_bullet('-')
imap <buffer> <expr> + xolox#notes#insert_bullet('+')
imap <buffer> <expr> * xolox#notes#insert_bullet('*')
let b:undo_ftplugin .= ' | execute "iunmap <buffer> -"'
let b:undo_ftplugin .= ' | execute "iunmap <buffer> +"'
let b:undo_ftplugin .= ' | execute "iunmap <buffer> *"'

" vim: ts=2 sw=2 et bomb
