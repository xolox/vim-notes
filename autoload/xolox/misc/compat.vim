" Compatibility checking.
"
" Author: Peter Odding <peter@peterodding.com>
" Last Change: May 20, 2013
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
let g:xolox#misc#compat#version = 7

" Remember the directory where the miscellaneous scripts are loaded from
" so the user knows which plug-in to update if incompatibilities arise.
let s:misc_directory = fnamemodify(expand('<sfile>'), ':~:h')

function! xolox#misc#compat#check(plugin_name, plugin_version, required_version)
  " Expects three arguments:
  "
  " 1. The name of the Vim plug-in that is using the miscellaneous scripts
  " 2. The version of the Vim plug-in that is using the miscellaneous scripts
  " 3. The version of the miscellaneous scripts expected by the plug-in
  "
  " When the loaded version of the miscellaneous scripts is different from the
  " version expected by the plug-in, this function will raise an error message
  " that explains what went wrong.
  if a:required_version != g:xolox#misc#compat#version
    let msg = "The %s %s plug-in expects version %i of the miscellaneous scripts, however version %i was loaded from the directory %s! Please upgrade your plug-ins to the latest releases to resolve this problem."
    throw printf(msg, a:plugin_name, a:plugin_version, a:required_version, g:xolox#misc#compat#version, s:misc_directory)
  endif
endfunction

" vim: ts=2 sw=2 et
