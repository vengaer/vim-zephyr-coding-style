" Vim plugin to fit the Zephyr coding style and help kernel development.
"
" Originally written by Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
" adapted for Zephyr by Vilhelm Engström <vilhelm.engstrom@tuta.io>.
" License:      Distributed under the same terms as Vim itself.
"
" For those who want to apply these options conditionally, you can define an
" array of patterns in your vimrc and these options will be applied only if
" the buffer's path matches one of the pattern. In the following example,
" options will be applied only if "/zephyr/" or "/kernel" is in buffer's path.
"
"   let g:zephyrsty_patterns = [ "/zephyr/", "/kernel/" ]
"
" By default, the plugin enables cindent for relevant files. This can be
" disabled by setting the g:zephyrsty_nocindent variable to 0 in your vimrc
"
"   let g:zephyrsty_cindent = 0
"
" Use the ZephyrCopyright function to insert a Zephyr-compatible copyright
" notice at the top of the file. The copyright holder may be configured by
" setting the g:zephyrsty_copyright_holder variable in your vimrc. If the
" variable is unset, the user.name value from your git configuration is used.

if exists("g:loaded_zephyrsty")
    finish
endif
let g:loaded_zephyrsty = 1

augroup zephyrsty
    autocmd!

    autocmd FileType c,cpp,dts,asm call s:ZephyrConfigure()
    autocmd FileType diff setlocal ts=8
    autocmd FileType rst setlocal ts=8 sw=8 sts=8 noet
    autocmd FileType kconfig setlocal ts=8 sw=8 sts=8 noet
augroup END

function s:ZephyrConfigure()
    let apply_style = 0

    if exists("g:zephyrsty_patterns")
        let path = expand('%:p')
        for p in g:zephyrsty_patterns
            if path =~ p
                let apply_style = 1
                break
            endif
        endfor
    else
        let apply_style = 1
    endif

    if apply_style
        call s:ZephyrCodingStyle()
    endif
endfunction

command! ZephyrCodingStyle call s:ZephyrCodingStyle()

function! s:ZephyrCodingStyle()
    call s:ZephyrFormatting()
    if index(["c", "cpp", "h"], &filetype) >= 0
        call s:ZephyrKeywords()
    endif
    call s:ZephyrHighlighting()
endfunction

function s:ZephyrFormatting()
    setlocal tabstop=8
    setlocal shiftwidth=8
    setlocal softtabstop=8
    setlocal textwidth=100
    setlocal noexpandtab

    if !exists("g:zephyrsty_cindent") || g:zephyrsty_cindent
        setlocal cindent
    endif
    setlocal cinoptions=:0,l1,t0,g0,(0
endfunction

function s:ZephyrKeywords()
    syn keyword cStatement __fallthrough
    syn keyword cOperator likely unlikely
endfunction

function s:ZephyrHighlighting()
    highlight default link ZephyrError ErrorMsg

    syn match ZephyrError / \+\ze\t/     " spaces before tab
    syn match ZephyrError /\%>100v[^()\{\}\[\]<>]\+/ " virtual column 101 and more

    if index(["c", "h", "cpp"], &filetype) >= 0
        syn match ZephyrError /\v0(b|B)[^;]*/  " Binary literals
    endif

    if index(["c", "h", "cpp", "dts", "asm"], &filetype) >= 0
        syn match ZephyrError /\/\/.*/  " C++/C99-style single-line comments
    endif

    " Highlight trailing whitespace, unless we're in insert mode and the
    " cursor's placed right after the whitespace. This prevents us from having
    " to put up with whitespace being highlighted in the middle of typing
    " something
    autocmd InsertEnter * match ZephyrError /\s\+\%#\@<!$/
    autocmd InsertLeave * match ZephyrError /\s\+$/
endfunction

function ZephyrCopyright()
    let l:cursorpos = winsaveview()

    if !exists("g:zephyrsty_copyright_holder")
        let g:zephyrsty_copyright_holder = trim(system("git config get user.name"))
    endif
    let l:notice = "Copyright (c) " ..  strftime("%Y") .. " " ..  g:zephyrsty_copyright_holder
    let l:license = "SPDX-License-Identifier: Apache-2.0"

    let l:comment = v:null

    if index(["c", "h", "cpp", "dts", "asm"], &filetype) >= 0
        let l:comment = ["/*", " * " .. l:notice, " *", " * " .. l:license, " */"]
    elseif index(["kconfig", "cmake"], &filetype) >= 0
        let l:comment = ["# " .. l:notice, "#", "# " .. l:license]
    else
        echon "\r\r"
        echohl ErrorMsg
        echon "Unknown filetype " .. &filetype
        echohl None
    endif

    if l:comment isnot v:null
        call append('^', l:comment)
        echon "\r\r" .. "Copyright notice for " .. g:zephyrsty_copyright_holder  .. " added"
    endif

    call winrestview(l:cursorpos)
endfunction
