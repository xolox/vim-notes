" Vim auto-load script
" Author: Anthony Naddeo <anthony.naddeo@gmail.com>
" Last Change: December 29, 2014
" URL: https://github.com/naddeoa

function! xolox#notes#mediawiki#view() " {{{1
  " Convert the current note to a Mediawiki document and show the converted text.
  let note_text = join(getline(1, '$'), "\n")
  let mediawiki_text = xolox#notes#mediawiki#convert_note(note_text)
  vnew
  call setline(1, split(mediawiki_text, "\n"))
  setlocal filetype=mediawiki
endfunction

function! xolox#notes#mediawiki#convert_note(note_text) " {{{1
  " Convert a note's text to the [Mediawiki text format] [mediawiki]. The syntax
  " used by vim-notes has a lot of similarities with Mediawiki, but there are
  " some notable differences like the note title and the way code blocks are
  " represented. This function takes the text of a note (the first argument)
  " and converts it to the Mediawiki format, returning a string.
  "
  " [mediawiki]: https://www.mediawiki.org/wiki/MediaWiki
  let starttime = xolox#misc#timer#start()
  let blocks = xolox#notes#parser#parse_note(a:note_text)
  call map(blocks, 'xolox#notes#mediawiki#convert_block(v:val)')
  let mediawiki = join(blocks, "\n\n")
  call xolox#misc#timer#stop("notes.vim %s: Converted note to Mediawiki syntax in %s.", g:xolox#notes#version, starttime)
  return mediawiki
endfunction

function! xolox#notes#mediawiki#convert_block(block) " {{{1
  " Convert a single block produced by `xolox#misc#notes#parser#parse_note()`
  " (the first argument, expected to be a dictionary) to the [Mediawiki text
  " format] [mediawiki]. Returns a string.
  if a:block.type == 'title'
    let text = s:make_urls_explicit(a:block.text)
    return ""
  elseif a:block.type == 'heading'
    let marker = repeat('=', 1 + a:block.level)
    let text = s:make_urls_explicit(a:block.text)
    return printf("%s %s %s", marker, text, marker)
  elseif a:block.type == 'code'
    return printf('<syntaxhighlight lang="%s">%s</syntaxhighlight>', a:block.language, a:block.text)
  elseif a:block.type == 'divider'
    return '----'
  elseif a:block.type == 'list'
    let items = []
    if a:block.ordered
      for item in a:block.items
        let indent = repeat('#', item.indent + 1)
        let text = s:make_urls_explicit(item.text)
        let text = s:highlight_task_markers(text)
        if text =~# "DONE"
          call add(items, printf("%s <del>%s</del>", indent, text))
        else
          call add(items, printf("%s %s", indent, text))
        endif
      endfor
    else
      for item in a:block.items
        let indent = repeat('*', item.indent + 1)
        let text = s:make_urls_explicit(item.text)
        let text = s:highlight_task_markers(text)
        if text =~# "DONE"
          call add(items, printf("%s <del>%s</del>", indent, text))
        else
          call add(items, printf("%s %s", indent, text))
        endif
      endfor
    endif
    return join(items, "\n")
  elseif a:block.type == 'block-quote'
    let lines = []
    for line in a:block.lines
      let prefix = repeat('>', line.level)
      call add(lines, printf('%s %s', prefix, line.text))
    endfor
    return join(lines, "\n")
  elseif a:block.type == 'paragraph'
    let text = s:make_urls_explicit(a:block.text)
    if len(text) <= 50 && text =~ ':$'
      let text = printf("'''%s'''", text)
    endif
    return text
  else
    let msg = "Encountered unsupported block: %s!"
    throw printf(msg, string(a:block))
  endif
endfunction

function! s:highlight_task_markers(text)
  " Highlight `TODO`, `DONE` and `XXX` markers with color in the Mediawiki
  " output similar to how the markers are highlighted by vim-notes.
  let highlighted = a:text
  let highlighted = substitute(highlighted, '\C\<XXX\>', '<span style="color:red">XXX</span>', "")
  let highlighted = substitute(highlighted, '\C\<TODO\>', '<span style="color:red">TODO</span>', "")
  let highlighted = substitute(highlighted, '\C\<DONE\>', '<span style="color:green">DONE</span>', "")
  return highlighted
endfunction

function! s:make_urls_explicit(text) " {{{1
  " In the vim-notes syntax, URLs are implicitly hyperlinks.
  " In Mediawiki syntax they have to be wrapped in [[markers]].
  return substitute(a:text, g:xolox#notes#url_pattern, '\= s:url_callback(submatch(0))', 'g')
endfunction

function! s:url_callback(url)
  let label = substitute(a:url, '^\w\+:\(//\)\?', '', '')
  return printf('[%s %s]', a:url, label)
endfunction
