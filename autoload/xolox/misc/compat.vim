" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: April 20, 2013
" URL: http://peterodding.com/code/vim/misc/

" The following integer will be bumped whenever a change in the miscellaneous
" scripts breaks backwards compatibility. This enables my Vim plug-ins to fail
" early when they detect an incompatible version, instead of breaking at the
" worst possible moments :-).
let g:xolox#misc#compat#version = 1

" Remember the directory where the miscellaneous scripts are loaded from
" so the user knows which plug-in to update if incompatibilities arise.
let s:misc_directory = fnamemodify(expand('<sfile>'), ':p:h')

function! xolox#misc#compat#check(plugin_name, required_version)
  if a:required_version != g:xolox#misc#compat#version
    let msg = "The %s plug-in requires version %i of the miscellaneous scripts, however version %i was loaded from %s!"
    throw printf(msg, a:plugin_name, a:required_version, g:xolox#misc#compat#version, s:misc_directory)
  endif
endfunction

" vim: ts=2 sw=2 et
