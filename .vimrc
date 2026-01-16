autocmd FileType javascript setlocal equalprg=eslint-pretty
set ts=4
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Meslo\ LG\ S
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Meslo LG S:10:cANSI
  endif
endif

if &t_Co > 1
   let g:zenburn_high_Contrast=1
   colorscheme zenburn
endif

execute pathogen#infect()

syntax enable
colorscheme habamax 
