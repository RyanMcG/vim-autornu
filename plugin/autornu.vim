" File:           autornu
" Maintainer:     Ryan McGowan ryan@ryanmcg.com
" Original Author:Mahdi Yusuf yusuf.mahdi@gmail.com (number.vim)
" Version:        0.1.1
" Description:    Automatically toggle relativenumber in an intelligent way.
" Last Change:    26 June, 2012
" License:        MIT License
" Location:       plugin/autornu.vim
" Website:        https://github.com/RyanMcG/vim-autornu
"
" See autornu.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help autornu
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:autornu_version = '0.1.1'

if exists("g:autornu_loaded") && g:autornu_loaded
    finish
endif
let g:autornu_loaded = 1

if !exists('g:autornu_enable')
    let g:autornu_enable = 1
endif

if !exists('g:autornu_buffer_blacklist')
    " some sane defaults for blacklisting
    let g:autornu_buffer_blacklist = [
                \'^NERD_tree_\d\+$',
                \'^__Tagbar__$',
                \'^__Gundo\(_Preview\)\?__$']
endif

if !exists('g:autornu_filetype_blacklist')
    " some sane defaults for blacklisting
    let g:autornu_filetype_blacklist = [
                \'qf',
                \'git',
                \'fugitiveblame',
                \'gitcommit',
                \'nerdtree',
                \'help',
                \'tagbar',
                \'gundo']
endif

if v:version < 703 || &cp
    echomsg "autornu.vim: you need at least Vim 7.3 and 'nocp' set"
    echomsg "Failed loading autornu.vim"
    finish
endif

"Allow use of line continuation
let s:save_cpo = &cpo
set cpo&vim

function! s:blacklisted_buffer()
    let bufname = bufname('%')
    return !empty(filter(copy(g:autornu_buffer_blacklist), "match(bufname, v:val) != -1"))
endfunction

function! s:blacklisted_filetype()
    return index(g:autornu_filetype_blacklist, &filetype) >= 0
endfunction

function! s:blacklisted()
    return s:blacklisted_filetype() || s:blacklisted_buffer()
endfunction

let s:has_focus = 1 " Off the bat assume we have focus

function! s:relative_off()
    if v:version > 703 || (v:version == 703 && has('patch1115'))
        set norelativenumber
    else
        " Ensure that old_number exists. This should be set previously when
        " relative number was turned on.
        if !exists('b:autornu_old_number')
            let b:autornu_old_number = 1
        end
        let &l:number = b:autornu_old_number
    endif
endfunction

function! s:reset()
    if !exists('b:autornu_control')
        " Keeps track of whether or not this plugin should control the given
        " buffer
        let b:autornu_control = !s:blacklisted()
    endif
    if !exists('b:autornu_rnu')
        " Track whether the current buffer should be relative or not
        let b:autornu_rnu = 1
    endif

    if g:autornu_enable && b:autornu_control
        if !s:has_focus
            call s:relative_off()
        elseif b:autornu_rnu
            " Store old value of number before setting relativenumber to
            " support pre 7.3.1115 versions of VIM
            let b:autornu_old_number = &l:number
            set relativenumber
        else
            call s:relative_off()
        endif
    endif
endfunction

function! s:set_focus(focus)
    let s:has_focus = a:focus
    call s:reset()
endfunction

function! s:set_rnu(rnu)
    let b:autornu_rnu = a:rnu
    call s:reset()
endfunction

function! AutornuToggle()
    " Toggle b:autornu_control between 0 and 1
    " NOTE: This relies on b:autornu_control existing already.
    let b:autornu_control = (b:autornu_control + 1) % 2

    if b:autornu_control
        call s:reset()
    else
        call s:relative_off()
    end
endfunction

function! AutornuEnable()
    let g:autornu_enable = 1

    " Remember the user's settings for nu and rnu so we can reset it later
    let s:old_number = &number
    let s:old_relativenumber = &relativenumber
endfunction

function! AutornuDisable()
    let g:autornu_enable = 0

    " Reset nu and rnu to what it was before AutornuEnable was called.
    if exists('s:old_number') && exists('s:old_relativenumber')
        let &number = s:old_number
        let &relativenumber = s:old_relativenumber
    endif
endfunction

function! AutornuOnOff()
    if g:autornu_enable
        call AutornuDisable()
    else
        call AutornuEnable()
    endif
endfunction

" Always set up auto command group so that b:autornu_control and s:has_focus
" are up to date.
augroup AutornuAug
    au!
    autocmd InsertEnter * :call s:set_rnu(0)
    autocmd InsertLeave * :call s:set_rnu(1)
    autocmd BufNewFile  * :call s:reset()
    autocmd BufReadPost * :call s:reset()
    autocmd FocusLost   * :call s:set_focus(0)
    autocmd FocusGained * :call s:set_focus(1)
    autocmd WinEnter    * :call s:set_rnu(1)
    autocmd WinLeave    * :call s:set_rnu(0)
augroup END

" Commands
command! -nargs=0 AutornuToggle call AutornuToggle()
command! -nargs=0 AutornuEnable call AutornuEnable()
command! -nargs=0 AutornuDisable call AutornuDisable()
command! -nargs=0 AutornuOnOff call AutornuOnOff()

" reset &cpo back to users setting
let &cpo = s:save_cpo

if g:autornu_enable
    call AutornuEnable()
endif
