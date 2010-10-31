" Vim syntax script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: October 31, 2010
" URL: http://peterodding.com/code/vim/notes/

" Note: This file is encoded in UTF-8 including a byte order mark so
" that Vim loads the script using the right encoding transparently.

" Quit when a syntax file was already loaded.
if exists('b:current_syntax')
  finish
endif

" Check for spelling errors in all text.
syntax spell toplevel

" Cluster of elements which never contain a newline character.
syntax cluster notesInline contains=@Spell,notesName,notesTextURL,notesFullURL,notesEmailAddr,notesUnixPath,notesWindowsPath

" The first line contains the note's title.
syntax match notesTitle /^.*\%1l.*$/ contains=@notesInline
highlight def link notesTitle ModeMsg

" The names of all notes are rendered as hyper links.
call xolox#notes#highlight_names('notesName')
highlight def link notesName Underlined

" Highlight short sentences ending in a colon as headings.
syntax match notesShortHeading /^\s*\zs\u.\{2,60}:\ze\(\s\|$\)/ contains=@notesInline
highlight def link notesShortHeading Title

" Highlight list bullets and numbers.
syntax match notesListBullet /^\s*\zs•/
syntax match notesListNumber /^\s*\zs\d\+[[:punct:]]\?\ze\s/
highlight def link notesListBullet Comment
highlight def link notesListNumber Comment

" Highlight domain names, URL's, e-mail addresses and filenames.
syntax match notesTextURL @\<www\.\(\S*\w\)\+[/?#]\?@
syntax match notesFullURL @\<\(mailto:\|javascript:\|\w\{3,}://\)\(\S*\w\)\+[/?#]\?@
syntax match notesEmailAddr /\<\w[^@ \t\r]*\w@\w[^@ \t\r]\+\w\>/
syntax match notesUnixPath @[/~]\S\+\(/\|[^[:punct:]]\)@ contains=notesName | " <- UNIX style pathnames
syntax match notesWindowsPath @\<[A-Za-z]:\S\+\([\\/]\|[^[:punct:]]\)@ contains=notesName | " <- Windows style pathnames
highlight def link notesTextURL Underlined
highlight def link notesFullURL Underlined
highlight def link notesEmailAddr Underlined
highlight def link notesUnixPath Directory
highlight def link notesWindowsPath Directory

" Highlight e-mail style block quotes.
syntax match notesBlockQuote /\(^\s*>.*\n\)\+/ contains=@notesInline
highlight def link notesBlockQuote Comment

" Highlight embedded blocks of source code, log file messages, basically
" anything Vim can highlight.
syntax match notesCodeStart /{{{\w*/
syntax match notesCodeEnd /}}}/
highlight link notesCodeStart Comment
highlight link notesCodeEnd Comment
call xolox#notes#highlight_sources('notesCodeStart', 'notesCodeEnd')

" Hide mode line at end of file.
syntax match notesModeLine /\_^vim:.*\_s*\%$/
highlight def link notesModeLine LineNr

" Set the currently loaded syntax mode.
let b:current_syntax = 'notes'

" vim: ts=2 sw=2 et bomb
