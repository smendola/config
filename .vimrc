autocmd FileType javascript setlocal equalprg=eslint-pretty
set ts=4
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Consolas\ 10
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Consolas:9:cANSI
  endif
endif

if &t_Co > 1
   let g:zenburn_high_Contrast=1
   syntax enable
   colorscheme zenburn
endif

