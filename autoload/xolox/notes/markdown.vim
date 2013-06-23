" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: June 23, 2013
" URL: http://peterodding.com/code/vim/notes/

function! xolox#notes#markdown#convert_note(note_text)
  " Convert a note's text to the [Markdown text format] [markdown]. The syntax
  " used by vim-notes has a lot of similarities with Markdown, but there are
  " some notable differences like the note title and the way code blocks are
  " represented. This function takes the text of a note (the first argument)
  " and converts it to the Markdown format, returning a string.
  "
  " [markdown]: http://en.wikipedia.org/wiki/Markdown
  let blocks = xolox#notes#parser#parse_note(a:note_text)
  call map(blocks, 'xolox#notes#markdown#convert_block(v:val)')
  return join(blocks, "\n\n")
endfunction

function! xolox#notes#markdown#convert_block(block)
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
  elseif a:block.type == 'paragraph'
    return a:block.text
  else
    let msg = "Encountered unsupported block: %s!"
    throw printf(msg, string(a:block))
  endif
endfunction
