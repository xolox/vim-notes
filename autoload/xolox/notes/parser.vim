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
    let chr = context.peek(1)
    if chr == '#'
      let block = s:parse_heading(context)
    elseif chr == '{' && context.peek(3) == "\{\{\{"
      let block = s:parse_code_block(context)
    else
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
  function context.peek(n)
    if self.has_more()
      return self.text[self.index : self.index + (a:n - 1)]
    endif
    return ''
  endfunction
  " The next() method returns the next character and consumes it.
  function context.next(n)
    let result = self.peek(a:n)
    let self.index += a:n
    return result
  endfunction
  " The next_line() method returns the current line and consumes it.
  function context.next_line()
    let line = ''
    while self.has_more()
      let chr = self.next(1)
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
  while a:context.peek(1) == '#'
    let level += 1
    call a:context.next(1)
  endwhile
  let text = xolox#misc#str#trim(a:context.next_line())
  return {'type': 'heading', 'level': level, 'text': text}
endfunction

function! s:parse_code_block(context) " {{{1
  " Parse the upcoming code block in the input stream.
  let language = ''
  let text = ''
  " Skip the start marker.
  call a:context.next(3)
  " Get the optional language name.
  while a:context.peek(1) =~ '\w'
    let language .= a:context.next(1)
  endwhile
  " Skip the whitespace separating the start marker and/or language name from
  " the text.
  while a:context.peek(1) =~ '[ \t]'
    call a:context.next(1)
  endwhile
  " Get the text inside the code block.
  while a:context.has_more()
    let chr = a:context.next(1)
    if chr == '}' && a:context.peek(2) == '}}'
      call a:context.next(2)
      break
    endif
    let text .= chr
  endwhile
  " Strip trailing whitespace.
  let text = substitute(text, '\_s\+$', '', '')
  return {'type': 'code', 'language': language, 'text': text}
endfunction

function! s:parse_paragraph(context) " {{{1
  " Parse the upcoming paragraph in the input stream.
  let lines = []
  let done = 0
  " Outer loop to consume multiple lines.
  while a:context.has_more()
    let line = ''
    " Inner loop to consume the current line.
    while a:context.has_more()
      let chr = a:context.peek(1)
      if chr == '{' && a:context.peek(3) == "\{\{\{"
        " XXX The start of a code block implies the end of the paragraph. The
        " marker above contains back slashes so that Vim doesn't apply folding
        " because of the marker :-).
        let done = 1
        break
      elseif chr == "\n"
        call a:context.next(1)
        break
      else
        let line .= a:context.next(1)
      endif
    endwhile
    " An empty line finishes the paragraph.
    if empty(line)
      break
    endif
    call add(lines, line)
    if done
      break
    endif
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
  call xolox#misc#test#wrap('xolox#notes#parser#test_parsing_of_code_blocks')
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

function! xolox#notes#parser#test_parsing_of_code_blocks()
  call xolox#misc#test#assert_equals([{'type': 'title', 'text': 'Just the title'}, {'type': 'code', 'language': '', 'text': "This is a code block\nwith two lines"}], xolox#notes#parser#parse_note("Just the title\n\n{{{ This is a code block\nwith two lines }}}"))
endfunction

call xolox#notes#parser#run_tests()
