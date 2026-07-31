# zephyrsty.vim

This is a fork of Vivien's excellent 
[Linux style plugin](https://github.com/vivien/vim-linux-coding-style) adapted for
[Zephyr's coding style](https://docs.zephyrproject.org/latest/contribute/style/code.html).

Much like the original Linux plugin, zephyrsty.vim configures indentation and various 
syntax highlights automatically for .c, .h and Kconfig files.
 
## Installation

Place zephyrsty.vim in ~/.vim/plugin.

## Usage

Just like the original linux plugin, zephyrsty is automatically enabled for C, C++, 
diff, rst, Kconfig and dst files. Applying the plugin to files only in a specified
few directories can be done by setting the `g:zephyrsty_patterns` array in your vimrc.

    let g:zephyrsty_patterns = [ "/zephyr", "/usr/src/" ]

If you want to enable the coding style on demand without checking the filetype, 
you can use the :ZephyrCodingStyle command. 

## License

Copyright (c) 2012-2026 Vivien Didelot.   
Copyright (c) 2026 Vilhelm Engström.  

Distributed under the same terms as Vim itself. 
See :help license.
