" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: June 23, 2013
" URL: http://peterodding.com/code/vim/notes/

function! xolox#notes#markdown#view() " {{{1
  " Convert the current note to a Markdown document and show the converted text.
  let note_text = join(getline(1, '$'), "\n")
  let markdown_text = xolox#notes#markdown#convert_note(note_text)
  vnew
  call setline(1, split(markdown_text, "\n"))
  setlocal filetype=markdown
endfunction

function! xolox#notes#markdown#convert_note(note_text) " {{{1
  " Convert a note's text to the [Markdown text format] [markdown]. The syntax
  " used by vim-notes has a lot of similarities with Markdown, but there are
  " some notable differences like the note title and the way code blocks are
  " represented. This function takes the text of a note (the first argument)
  " and converts it to the Markdown format, returning a string.
  "
  " [markdown]: http://en.wikipedia.org/wiki/Markdown
  let starttime = xolox#misc#timer#start()
  let blocks = xolox#notes#parser#parse_note(a:note_text)
  call map(blocks, 'xolox#notes#markdown#convert_block(v:val)')
  let markdown = join(blocks, "\n\n")
  call xolox#misc#timer#stop("notes.vim %s: Converted note to Markdown in %s.", g:xolox#notes#version, starttime)
  return markdown
endfunction

function! xolox#notes#markdown#convert_block(block) " {{{1
  " Convert a single block produced by `xolox#misc#notes#parser#parse_note()`
  " (the first argument, expected to be a dictionary) to the [Markdown text
  " format] [markdown]. Returns a string.
  if a:block.type == 'title'
    return printf("# %s", a:block.text)
  elseif a:block.type == 'heading'
    return printf("%s %s", repeat('#', 1 + a:block.level), a:block.text)
  elseif a:block.type == 'code'
    let text = xolox#misc#str#dedent(a:block.text)
    return xolox#misc#str#indent(text, 4)
  elseif a:block.type == 'divider'
    return '* * *'
  elseif a:block.type == 'list'
    let items = []
    if a:block.ordered
      let counter = 1
      for item in a:block.items
        call add(items, printf("%d. %s", counter, item))
        let counter += 1
      endfor
    else
      for item in a:block.items
        call add(items, printf("- %s", item))
      endfor
    endif
    return join(items, "\n\n")
  elseif a:block.type == 'paragraph'
    return a:block.text
  else
    let msg = "Encountered unsupported block: %s!"
    throw printf(msg, string(a:block))
  endif
endfunction
