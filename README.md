# Easy note taking in Vim

The notes.vim plug-in for the [Vim text editor] [vim] makes it easy to manage your notes in Vim:

 * **Starting a new note:** Execute the `:Note` command to create a new buffer and load the appropriate file type and syntax
 * **Saving notes:** Just use Vim's [:write] [write] and [:update] [update] commands, you don't need to provide a filename because it will be set based on the title (first line) of your note (you also don't need to worry about special characters, they'll be escaped)
 * **Editing existing notes:** Execute `:Note anything` to edit a note containing `anything` in its title (if no notes are found a new one is created with its title set to `anything`)
 * **Deleting notes:** The `:DeleteNote` command enables you to delete the current note
 * **Searching notes:** `:SearchNotes keyword …` searches for keywords and `:SearchNotes /pattern/` searches for regular expressions
   * **Back-references:** The `:RelatedNotes` command find all notes referencing the current file
   * A [Python 2] [python] script is included that accelerates keyword searches using an [SQLite] [sqlite] database
 * **Navigating between notes:** The included file type plug-in redefines [gf] [gf] to jump between notes and the syntax script highlights note names as hyper links
 * **Writing aids:** The included file type plug-in contains mappings for automatic curly quotes, arrows and list bullets
 * **Embedded file types:** The included syntax script supports embedded highlighting using blocks marked with `{{{type … }}}` which allows you to embed highlighted code and configuration snippets in your notes

Here's a screen shot of the syntax mode using the [slate] [slate] color scheme:

![Syntax mode screen shot](http://peterodding.com/code/vim/notes/syntax.png)

## Install & usage

Unzip the most recent [ZIP archive] [download] file inside your Vim profile directory (usually this is `~/.vim` on UNIX and `%USERPROFILE%\vimfiles` on Windows), restart Vim and execute the command `:helptags ~/.vim/doc` (use `:helptags ~\vimfiles\doc` instead on Windows). To get started execute `:Note` or `:edit note:`, this will start a new note that contains instructions on how to continue from there (and how to use the plug-in in general).

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/notes/> and <http://github.com/xolox/vim-notes>. If you like the script please vote for it on [Vim Online] [vim_online].

## License

This software is licensed under the [MIT license] [mit].  
© 2011 Peter Odding &lt;<peter@peterodding.com>&gt;.

[vim]: http://www.vim.org/
[write]: http://vimdoc.sourceforge.net/htmldoc/editing.html#:write
[update]: http://vimdoc.sourceforge.net/htmldoc/editing.html#:update
[python]: http://python.org/
[sqlite]: http://sqlite.org/
[gf]: http://vimdoc.sourceforge.net/htmldoc/editing.html#gf
[slate]: http://code.google.com/p/vim/source/browse/runtime/colors/slate.vim
[download]: http://peterodding.com/code/vim/downloads/notes.zip
[vim_online]: http://www.vim.org/scripts/script.php?script_id=3375
[mit]: http://en.wikipedia.org/wiki/MIT_License
