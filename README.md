vim-autornu
===========

A plugin for intelligently toggling line `relativenumber` originally based on
[numbers.vim][]

This plugin automatically toggles `relativenumber` smartly using autocommands.
For versions of VIM less than 7.3.1115 this means setting `number`. This
plugin makes an effort to keep track of the original value of number in a
buffer so it isn't lost. In a GUI, it also functions based on whether or not
the window has focus.

Commands are included for toggling the line numbering method and for enabling
and disabling the plugin.

#### Requirements

  - Vim 7.3+

### Installation

Using [pathogen][p] or [vundle][v] for installation is recommended.

For pathogen users, clone the repo:

    git clone https://github.com/RyanMcG/vim-autornu.git ~/.vim/bundle/vim-autornu

For vundle users, add the following to your `.vimrc` and then run
a `:BundleInstall`:

    Bundle "RyanMcG/vim-autornu"

### Usage

Once installed, no action is *required* on your part. But for convenience, you
may want to add mappings in your `.vimrc` for some of the commands, e.g.,

    nnoremap <F3> :AutornuToggle<CR>
    nnoremap <F4> :AutornuOnOff<CR>

For options and the like see [the vim documentation (`:h autornu`)][doc].

[doc]: https://github.com/RyanMcG/vim-autornu/blob/master/doc/autornu.txt
[numbers.vim]: https://github.com/myusuf3/numbers.vim
[p]: https://github.com/tpope/vim-pathogen
[v]: https://github.com/gmarik/vundle
