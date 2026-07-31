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

if exists("g:loaded_zephyrsty")
    finish
endif
let g:loaded_zephyrsty = 1

augroup zephyrsty
    autocmd!

    autocmd FileType c,cpp call s:ZephyrConfigure()
    autocmd FileType diff setlocal ts=8
    autocmd FileType rst setlocal ts=8 sw=8 sts=8 noet
    autocmd FileType kconfig setlocal ts=8 sw=8 sts=8 noet
    autocmd FileType dts setlocal ts=8 sw=8 sts=8 noet
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
    call s:ZephyrKeywords()
    call s:ZephyrHighlighting()
endfunction

function s:ZephyrFormatting()
    setlocal tabstop=8
    setlocal shiftwidth=8
    setlocal softtabstop=8
    setlocal textwidth=100
    setlocal noexpandtab

    setlocal cindent
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
        syn match ZephyrError /\/\/.*/
        syn match ZephyrError /\v0(b|B)[^;]*/
    endif

    " Highlight trailing whitespace, unless we're in insert mode and the
    " cursor's placed right after the whitespace. This prevents us from having
    " to put up with whitespace being highlighted in the middle of typing
    " something
    autocmd InsertEnter * match ZephyrError /\s\+\%#\@<!$/
    autocmd InsertLeave * match ZephyrError /\s\+$/
endfunction
