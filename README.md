# Easy note taking in Vim

The `notes.vim` plug-in for the [Vim text editor](http://www.vim.org/) makes it easy to manage your notes in Vim:

 * **Starting a new note:** Execute the `:NewNote` command to create a new buffer and load the appropriate file type and syntax
 * **Saving notes:** Just use Vim's [:write](http://vimdoc.sourceforge.net/htmldoc/editing.html#:write) and [:update](http://vimdoc.sourceforge.net/htmldoc/editing.html#:update) commands, you don't need to provide a filename because it will already have been set based on the title (first line) of your note (you also don't need to worry about special characters, they'll be escaped)
 * **Deleting notes:** The `:DeleteNote` command enables you to delete the current or given note
 * **Searching notes:** `:SearchNotes keyword …` searches for keywords and `:SearchNotes /pattern/` searches for regular expressions
  * **Back-references:** The `:RelatedNotes` command find all notes referencing the current file
  * A [Python](http://python.org/) script is included that accelerates keyword searches using an [SQLite](http://sqlite.org/) database
 * **Navigating between notes:** The included file type plug-in redefines [gf](http://vimdoc.sourceforge.net/htmldoc/editing.html#gf) to jump between notes and the syntax script highlights note names as hyper links
 * **Writing aids:** The included file type plug-in contains mappings for automatic curly quotes, arrows and list bullets
 * **Embedded file types:** The included syntax script supports embedded highlighting using blocks marked with `{{{type … }}}` which allows you to embed highlighted code and configuration snippets in your notes

## Install & usage

Unzip the most recent ZIP archive file inside your Vim profile directory (usually this is `~/.vim` on UNIX and `%USERPROFILE%\vimfiles` on Windows), restart Vim and execute the command `:helptags ~/.vim/doc` (use `:helptags ~\vimfiles\doc` instead on Windows). To get started execute `:NewNote`.

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/notes/> and <http://github.com/xolox/vim-notes>.

## License

This software is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).  
© 2010 Peter Odding &lt;<peter@peterodding.com>&gt;.
