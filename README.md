# Miscellaneous auto-load Vim scripts

The git repository at [github.com/xolox/vim-misc] [repository] contains Vim scripts that are used by most of the [Vim plug-ins I've written] [plugins] yet don't really belong with any single one of the plug-ins. Basically it's an extended standard library of Vim script functions that I wrote during the development of my Vim plug-ins.

The miscellaneous scripts are bundled with each of my plug-ins using git merges, so that a repository checkout of a plug-in contains everything that's needed to get started. This means the git repository of the miscellaneous scripts is only used to track changes in a central, public place.

## How does it work?

Here's how I merge the miscellaneous scripts into a Vim plug-in repository:

1. Let git know about the `vim-misc` repository by adding the remote GitHub repository:

        git remote add -f vim-misc https://github.com/xolox/vim-misc.git

2. Merge the two directory trees without clobbering the `README.md` and/or `.gitignore` files, thanks to the selected merge strategy and options:

        git checkout master
        git merge --no-commit -s recursive -X ours vim-misc/master
        git commit -m "Merge vim-misc repository as overlay"

3. While steps 1 and 2 need to be done only once for a given repository, the following commands are needed every time I want to pull and merge the latest changes:

        git checkout master
        git fetch vim-misc master
        git merge --no-commit -s recursive -X ours vim-misc/master
        git commit -m "Merged changes to miscellaneous scripts"

## Why make things so complex?

I came up with this solution after multiple years of back and forth between Vim Online users, the GitHub crowd and my own sanity:

1. When I started publishing my first Vim plug-ins (in June 2010) I would prepare ZIP archives for Vim Online using makefiles. The makefiles would make sure the miscellaneous scripts were included in the uploaded distributions. This had two disadvantages: It lost git history and the repositories on GitHub were not usable out of the box, so [I got complaints from GitHub (Pathogen) users] [github-complaints].

2. My second attempt to solve the problem used git submodules which seemed like the ideal solution until I actually started using them in March 2011: Submodules are not initialized during a normal `git clone`, you need to use `git clone --recursive` instead but Vim plug-in managers like [Pathogen] [pathogen] and [Vundle] [vundle] don't do this (at least [they didn't when I tried] [vundle-discussion]) so people would end up with broken checkouts.

3. After finding out that git submodules were not going to solve my problems I searched for other inclusion strategies supported by git. After a while I came upon the [subtree merge strategy] [merge-strategy] which I started using in May 2011 and stuck with for more than two years (because it generally worked fine and seemed quite robust).

4. In April 2013 the flat layout of the repository started bothering me because it broke my personal workflow, so I changed it to the proper directory layout of a Vim plug-in. Why did it break my workflow? Because I couldn't get my [vim-reload] [reload] plug-in to properly reload miscellaneous scripts without nasty hacks. Note to self: [Dropbox does not respect symbolic links] [dropbox-vote-350] and Vim doesn't like them either ([E746] [E746]).

## Compatibility issues

Regardless of the inclusion strategies discussed above, my current scheme has a flaw: If more than one of my plug-ins are installed in a Vim profile using [Pathogen] [pathogen] or [Vundle] [vundle], the miscellaneous autoload scripts will all be loaded from the subdirectory of one single plug-in.

This means that when I break compatibility in the miscellaneous scripts, I have to make sure to merge the changes into all of my plug-ins. Even then, if a user has more than one of my plug-ins installed but updates only one of them, the other plug-ins (that are not yet up to date) can break (because of the backwards incompatible change).

The `xolox#misc#compat#check()` function makes sure that incompatibilities are detected early so that the user knows which plug-in to update if incompatibilities arise.

## Contact

If you have questions, bug reports, suggestions, etc. the author can be contacted at <peter@peterodding.com>. The latest version is available at <http://peterodding.com/code/vim/misc> and <http://github.com/xolox/vim-misc>.

## License

This software is licensed under the [MIT license] [mit].  
© 2013 Peter Odding &lt;<peter@peterodding.com>&gt;.


[dropbox-vote-350]: https://www.dropbox.com/votebox/350/preserve-implement-symlink-behaviour
[E746]: http://vimdoc.sourceforge.net/htmldoc/eval.html#E746
[github-complaints]: https://github.com/xolox/vim-easytags/issues/1
[merge-strategy]: http://www.kernel.org/pub/software/scm/git/docs/howto/using-merge-subtree.html
[mit]: http://en.wikipedia.org/wiki/MIT_License
[pathogen]: http://www.vim.org/scripts/script.php?script_id=2332
[plugins]: http://peterodding.com/code/vim/
[reload]: http://peterodding.com/code/vim/reload
[repository]: https://github.com/xolox/vim-misc
[vundle-discussion]: https://github.com/gmarik/vundle/pull/41
[vundle]: https://github.com/gmarik/vundle
