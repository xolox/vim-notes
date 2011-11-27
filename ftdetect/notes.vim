" Vim file type detection script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: November 26, 2011
" URL: http://peterodding.com/code/vim/notes

" Initialize the configuration defaults.
call xolox#notes#init()

" Define the automatic commands used to recognize notes.
for s:directory in [g:notes_directory, g:notes_shadowdir]
  execute 'autocmd BufNewFile,BufRead'
        \ xolox#notes#autocmd_pattern(s:directory)
        \ 'if empty(&buftype) | setlocal filetype=notes | endif'
endfor

" vim: ts=2 sw=2 et
