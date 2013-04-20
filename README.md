# Miscellaneous auto-load Vim scripts

The git repository at [github.com/xolox/vim-misc] [repository] contains Vim scripts that are used by most of the [Vim plug-ins I've written] [plugins] yet don't really belong with any single one. I include this repository as a subdirectory of my plug-in repositories using the following commands:

    $ git remote add -f vim-misc https://github.com/xolox/vim-misc.git
    $ git merge -s ours --no-commit vim-misc/master
    $ git read-tree --prefix=autoload/xolox/misc/ -u vim-misc/master
    $ git commit -m "Merge vim-misc repository as subdirectory"

The above trick is called the [subtree merge strategy] [merge-strategy]. To update a plug-in repository to the latest version of the miscellaneous auto-load scripts I execute the following command:

    $ git pull -s subtree vim-misc master

## Why make things so complex?

I came up with this solution after multiple years of back and forth between Vim Online users, the GitHub crowd and my own sanity:

1. When I started publishing my first Vim plug-ins I would prepare ZIP archives for Vim Online using makefiles. The makefiles would make sure the miscellaneous scripts were included in the uploaded distributions. This had two disadvantages: It lost git history and the repositories on GitHub were not usable out of the box, so [I got complaints from GitHub (Pathogen) users] [github-complaints].

2. My second attempt to solve the problem used git submodules which seemed like the ideal solution until I actually started doing it. Submodules are not initialized during a normal `git clone`, you need to use `git clone --recursive` instead but Vim plug-in managers like [Pathogen] [pathogen] and [Vundle] [vundle] don't do this (at least [they didn't when I tried] [vundle-discussion]) so people would end up with broken checkouts.

3. After finding out that git submodules were not going to solve my problems I searched for other inclusion strategies supported by git. After a while I came upon the [subtree merge strategy] [merge-strategy] which I have been using for more than two years now.

## Compatibility issues

Regardless of the inclusion strategies discussed above, my current scheme has a flaw: If more than one of my plug-ins are installed in a Vim profile using [Pathogen] [pathogen] or [Vundle] [vundle], the miscellaneous autoload scripts will all be loaded from the subdirectory of one single plug-in.

This means that when I break compatibility in the miscellaneous scripts, I have to make sure to merge the changes into all of my plug-ins. Even then, if a user has more than one of my plug-ins installed but updates only one of them, the other plug-ins (that are not yet up to date) can break (because of the backwards incompatible change).

The `xolox#misc#compat#check()` function makes sure that incompatibilities are detected early so that the user knows which plug-in to update if incompatibilities arise.

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/misc> and <http://github.com/xolox/vim-misc>.

## License

This software is licensed under the [MIT license] [mit].  
© 2013 Peter Odding &lt;<peter@peterodding.com>&gt;.


[github-complaints]: https://github.com/xolox/vim-easytags/issues/1
[merge-strategy]: http://www.kernel.org/pub/software/scm/git/docs/howto/using-merge-subtree.html
[mit]: http://en.wikipedia.org/wiki/MIT_License
[pathogen]: http://www.vim.org/scripts/script.php?script_id=2332
[plugins]: http://peterodding.com/code/vim/
[repository]: https://github.com/xolox/vim-misc
[vundle-discussion]: https://github.com/gmarik/vundle/pull/41
[vundle]: https://github.com/gmarik/vundle
