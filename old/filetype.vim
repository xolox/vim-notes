" This Vim script was modified by a Python script that I use to manage the
" inclusion of miscellaneous functions in the plug-ins that I publish to Vim
" Online and GitHub. Please don't edit this file, instead make your changes on
" the 'dev' branch of the git repository (thanks!). This file was generated on
" May 21, 2013 at 03:00.

﻿" Vim file type plug-in
" Maintainer: Peter Odding <peter@peterodding.com>
" Last Change: May 22, 2011
" URL: http://peterodding.com/vim/ftplugin/notes.vim
" Supports: http://peterodding.com/vim/plugin/notes.vim
" Requires: http://peterodding.com/vim/autoload/notes.vim
" Requires: http://peterodding.com/vim/autoload/escape.vim

" Note: This file is encoded in UTF-8 including a byte order mark so
" that Vim sources the script using the right encoding transparently.

if exists('b:did_ftplugin')
 finish
else
 let b:did_ftplugin = 1
endif

" Set the tabstop and shiftwidth options for bulleted lists. {{{1
setlocal tabstop=3 shiftwidth=3 expandtab
let b:undo_ftplugin = 'set tabstop< shiftwidth< expandtab<'

" Set the breakat option to customize text wrapping. {{{1
setlocal breakat=
let b:undo_ftplugin = 'set breakat<'

" I save a lot of URLs in my notes and without the above, the URLs are
" partially wrapped and Vim draws the underline even where there's no text
" because of wrapping (between where the URL is visually wrapped and where
" the next visual line continues).

" Set the breakindent and breakindentshift options? {{{1
if exists('&breakindent')
  setlocal breakindent breakindentshift=2
  let b:undo_ftplugin .= ' breakindent< breakindentshift<'
endif

" Automatic formatting for bulleted lists. {{{1
setlocal commentstring=\ •\ %s
setlocal comments=:\ •\ 
let b:undo_ftplugin .= ' commentstring< comments<'

" Automatically remove empty list items. {{{1
" FIXME When &columns <= +/- 50 this never produces a line break?!
inoremap <buffer> <CR> <C-o>:call notes#remove_empty_list_items()<CR><CR>
let b:undo_ftplugin .= ' | execute "iunmap <buffer> <CR>"'

" Start a new line without a bullet point using Shift-Enter.
inoremap <buffer> <S-CR> <CR><C-o>:call setline('.', substitute(getline('.'), '•', ' ', 'g') . ' ')<CR><C-o>$
