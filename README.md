# Miscellaneous auto-load Vim scripts

The git repository at <http://github.com/xolox/vim-misc> contains Vim scripts that are used by most of the [Vim plug-ins I've written] [plugins] yet don't really belong with any single one. I include this repository as a subdirectory of my plug-in repositories using the following commands:

    $ git remote add -f vim-misc https://github.com/xolox/vim-misc.git
    $ git merge -s ours --no-commit vim-misc/master
    $ git read-tree --prefix=autoload/xolox/misc/ -u vim-misc/master
    $ git commit -m "Merge vim-misc repository as subdirectory"

To update a plug-in repository to the latest versions of the miscellaneous auto-load scripts I execute the following command:

    $ git pull -s subtree vim-misc master

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/misc> and <http://github.com/xolox/vim-misc>.

## License

This software is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).  
© 2011 Peter Odding &lt;<peter@peterodding.com>&gt;.


[plugins]: http://peterodding.com/code/vim/
