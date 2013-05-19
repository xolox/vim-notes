" Compatibility checking.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 19, 2013
" URL: http://peterodding.com/code/vim/misc/
"
" This Vim script defines a version number for the miscellaneous scripts. Each
" of my plug-ins compares their expected version of the miscellaneous scripts
" against the version number defined inside the miscellaneous scripts.
"
" The version number is incremented whenever a change in the miscellaneous
" scripts breaks backwards compatibility. This enables my Vim plug-ins to fail
" early when they detect an incompatible version, instead of breaking at the
" worst possible moments :-).
let g:xolox#misc#compat#version = 6

" Remember the directory where the miscellaneous scripts are loaded from
" so the user knows which plug-in to update if incompatibilities arise.
let s:misc_directory = fnamemodify(expand('<sfile>'), ':p:h')

function! xolox#misc#compat#check(plugin_name, required_version)
  " Expects two arguments: The name of a Vim plug-in and the version of the
  " miscellaneous scripts expected by the plug-in. When the active version of
  " the miscellaneous scripts has a different version, this will raise an
  " error message that explains what went wrong.
  if a:required_version != g:xolox#misc#compat#version
    let msg = "The %s plug-in requires version %i of the miscellaneous scripts, however version %i was loaded from %s!"
    throw printf(msg, a:plugin_name, a:required_version, g:xolox#misc#compat#version, s:misc_directory)
  endif
endfunction

" vim: ts=2 sw=2 et
