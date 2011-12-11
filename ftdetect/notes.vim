" Vim file type detection script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: December 11, 2011
" URL: http://peterodding.com/code/vim/notes

" Initialize the configuration defaults.
call xolox#notes#init()

" Define the automatic commands used to recognize notes.

execute 'autocmd BufNewFile,BufRead'
        \ xolox#notes#autocmd_pattern(g:notes_directory, 1)
        \ 'if empty(&buftype) | setlocal filetype=notes | endif'

execute 'autocmd BufNewFile,BufRead'
        \ xolox#notes#autocmd_pattern(g:notes_shadowdir, 0)
        \ 'if empty(&buftype) | setlocal filetype=notes | endif'

" vim: ts=2 sw=2 et
