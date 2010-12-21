# Easy note taking in Vim

The `notes.vim` plug-in for the [Vim text editor](http://www.vim.org/) makes it easy to manage your notes in Vim:

 * To **start a note** execute `:NewNote` - this will create a new buffer and load the appropriate file type and syntax
 * To **save a note** you can just use Vim's [:write](http://vimdoc.sourceforge.net/htmldoc/editing.html#:write) and [:update](http://vimdoc.sourceforge.net/htmldoc/editing.html#:update) commands
 * If you want to **delete a note** execute `:DeleteNote`
 * You can **search your notes** for patterns/keywords using `:SearchNotes /pattern/` and `:SearchNotes keyword …`
 * The `:RelatedNotes` command makes it easy to **find related notes** for the current file
 * The file type plug-in redefines [gf](http://vimdoc.sourceforge.net/htmldoc/editing.html#gf) to **jump between notes** and the syntax script **highlights note names** as hyper links
 * The file type plug-in contains mappings for automatic curly quotes, arrows and list bullets
 * The syntax script supports **embedded highlighting** using blocks marked with `{{{type … }}}`, this allows you to embed highlighted code and configuration snippets in your notes

## Install & usage

Unzip the most recent ZIP archive file inside your Vim profile directory (usually this is `~/.vim` on UNIX and `%USERPROFILE%\vimfiles` on Windows), restart Vim and execute the command `:helptags ~/.vim/doc` (use `:helptags ~\vimfiles\doc` instead on Windows). To get started execute `:NewNote`.

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/notes/> and <http://github.com/xolox/vim-notes>.

## License

This software is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).  
© 2010 Peter Odding &lt;<peter@peterodding.com>&gt;.
