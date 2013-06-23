" Vim auto-load script
" Author: Peter Odding <peter@peterodding.com>
" Last Change: June 23, 2013
" URL: http://peterodding.com/code/vim/notes/

function! xolox#notes#parser#parse_note(text) " {{{1
  " Parser for the note taking syntax used by vim-notes.
  let context = s:create_parse_context(a:text)
  let note_title = context.next_line()
  let blocks = [{'type': 'title', 'text': note_title}]
  while context.has_more()
    let chr = context.peek()
    if chr == '#'
      " Parse the upcoming heading in the input stream.
      let block = s:parse_heading(context)
    else
      " Parse the upcoming paragraph in the input stream.
      let block = s:parse_paragraph(context)
    endif
    " Don't include empty blocks in the output.
    if !empty(block)
      call add(blocks, block)
    endif
  endwhile
  return blocks
endfunction

function! s:create_parse_context(text) " {{{1
  " Create an object to encapsulate the lowest level of parser state.
  let context = {'text': a:text, 'index': 0}
  " The has_more() method returns 1 (true) when more input is available, 0
  " (false) otherwise.
  function context.has_more()
    return self.index < len(self.text)
  endfunction
  " The peek() method returns the next character without consuming it.
  function context.peek()
    return self.has_more() ? self.text[self.index] : ''
  endfunction
  " The next() method returns the next character and consumes it.
  function context.next()
    let chr = self.peek()
    let self.index += 1
    return chr
  endfunction
  " The next_line() method returns the current line and consumes it.
  function context.next_line()
    let line = ''
    while self.has_more()
      let chr = self.next()
      if chr == "\n" || chr == ""
        " We hit the end of line or input.
        return line
      else
        " The line continues.
        let line .= chr
      endif
    endwhile
    return line
  endfunction
  return context
endfunction

function! s:parse_heading(context) " {{{1
  " Parse the upcoming heading in the input stream.
  let level = 0
  while a:context.peek() == '#'
    let level += 1
    call a:context.next()
  endwhile
  let text = xolox#misc#str#trim(a:context.next_line())
  return {'type': 'heading', 'level': level, 'text': text}
endfunction

function! s:parse_paragraph(context) " {{{1
  " Parse the upcoming paragraph in the input stream.
  let lines = []
  while a:context.has_more()
    let line = a:context.next_line()
    if empty(line)
      break
    endif
    call add(lines, line)
  endwhile
  " Don't include empty paragraphs in the output.
  let text = join(lines, "\n")
  if text =~ '\S'
    return {'type': 'paragraph', 'text': text}
  else
    return {}
  endif
endfunction

function! xolox#notes#parser#run_tests() " {{{1
  " Tests for the note taking syntax parser.
  call xolox#misc#test#reset()
  call xolox#misc#test#wrap('xolox#notes#parser#test_parsing_of_note_titles')
  call xolox#misc#test#wrap('xolox#notes#parser#test_parsing_of_headings')
  call xolox#misc#test#wrap('xolox#notes#parser#test_parsing_of_paragraphs')
  call xolox#misc#test#summarize()
endfunction

function! xolox#notes#parser#test_parsing_of_note_titles()
  call xolox#misc#test#assert_equals([{'type': 'title', 'text': 'Just the title'}], xolox#notes#parser#parse_note('Just the title'))
endfunction

function! xolox#notes#parser#test_parsing_of_headings()
  call xolox#misc#test#assert_equals([{'type': 'title', 'text': 'Just the title'}, {'type': 'heading', 'level': 1, 'text': 'This is a heading'}], xolox#notes#parser#parse_note("Just the title\n\n# This is a heading"))
endfunction

function! xolox#notes#parser#test_parsing_of_paragraphs()
  call xolox#misc#test#assert_equals([{'type': 'title', 'text': 'Just the title'}, {'type': 'paragraph', 'text': 'This is a paragraph'}], xolox#notes#parser#parse_note("Just the title\n\nThis is a paragraph"))
  call xolox#misc#test#assert_equals([{'type': 'title', 'text': 'Just the title'}, {'type': 'paragraph', 'text': 'This is a paragraph'}, {'type': 'paragraph', 'text': "And here's another paragraph!"}], xolox#notes#parser#parse_note("Just the title\n\nThis is a paragraph\n\n\n\nAnd here's another paragraph!"))
endfunction

call xolox#notes#parser#run_tests()
