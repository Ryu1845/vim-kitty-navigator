" Maps <C-c/t/s/r> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to kitty.

if exists("g:loaded_kitty_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_kitty_navigator = 1

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

if !get(g:, 'kitty_navigator_no_mappings', 0)
  nnoremap <silent> <c-c> :KittyNavigateLeft<cr>
  nnoremap <silent> <c-t> :KittyNavigateDown<cr>
  nnoremap <silent> <c-s> :KittyNavigateUp<cr>
  nnoremap <silent> <c-r> :KittyNavigateRight<cr>
endif

command! KittyNavigateLeft     call s:KittyAwareNavigate('c')
command! KittyNavigateDown     call s:KittyAwareNavigate('t')
command! KittyNavigateUp       call s:KittyAwareNavigate('s')
command! KittyNavigateRight    call s:KittyAwareNavigate('r')

function! s:KittyCommand(args)
  let cmd = 'kitty @ ' . a:args
  return system(cmd)
endfunction

let s:kitty_is_last_pane = 0

augroup kitty_navigator
  au!
  autocmd WinEnter * let s:kitty_is_last_pane = 0
augroup END

function! s:KittyAwareNavigate(direction)
  let nr = winnr()
  let kitty_last_pane = (a:direction == 'p' && s:kitty_is_last_pane)
  if !kitty_last_pane
    call s:VimNavigate(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())

  if kitty_last_pane || at_tab_page_edge
    let mappings = {
    \   "c": "left",
    \   "t": "bottom",
    \   "s": "top",
    \   "r": "right"
    \ }
    let args = 'kitten neighboring_window.py' . ' ' . mappings[a:direction]
    silent call s:KittyCommand(args)
    let s:kitty_is_last_pane = 1
  else
    let s:kitty_is_last_pane = 0
  endif
endfunction
