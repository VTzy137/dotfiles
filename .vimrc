
" VIM Configuration Profile

" Use the PowerLine plugin. Change Python directory if needed.
set rtp+=/usr/lib/python3/dist-packages/powerline/bindings/vim/

" always show statusline
set laststatus=2

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" Always show the command as it is being typed.
set showcmd

:set number

:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END

call plug#begin('~/.vim/plugged')
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'bkad/CamelCaseMotion'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdcommenter'
Plug 'sbdchd/neoformat'
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'} 
Plug 'nvim-lua/plenary.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'folke/lazy.nvim'
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-fugitive'
Plug 'rbong/vim-flog'

call plug#end()

" nnoremap o i<cr><esc>
nnoremap qw :wq<cr>
nnoremap qq :q!<cr>
nnoremap w $
xnoremap w $
" nnoremap s :w<cr> 
nnoremap t <C-r> 
nnoremap <space> a<space><esc>
nnoremap <enter> i<enter><esc>
nnoremap J 3j
xnoremap J 3j
nnoremap K 3k
xnoremap K 3k
nnoremap L L5j
xnoremap L L5j
nnoremap H H5k
xnoremap H H5k
nnoremap d "ad
xnoremap d "ad
nnoremap x "ax
nnoremap 0 ^
nnoremap die ggdG
nnoremap yie ggyG
map <esc>j gT
map <esc>k gt
map <esc>t :tabnew<cr>

" nmap // <Plug>NERDCommenterToggle
" vmap // <Plug>NERDCommenterToggle
nmap ff <Plug>(easymotion-overwin-w)
" nnoremap h :execute "normal! ".(col('.') == 1 ? 'k$l' : 'h')<CR>
" nnoremap l :exec 'normal! '.(col('.') == col('$') ? 'j0' : 'l')<CR>
" set virtualedit+=onemore
set expandtab        " Convert tabs to spaces
set tabstop=2         " Number of spaces that a <Tab> counts for
set shiftwidth=2      " Number of spaces to use for each step of (auto)indent
set softtabstop=2     " Number of spaces that a <Tab> counts for while editing
set autoindent
set clipboard=unnamedplus
" set cursorline
set ignorecase

" let &t_VE = "\e[2 q" 
let &t_SI = "\e[6 q" 
let &t_EI = "\e[2 q" 

map <leader>w <Plug>CamelCaseMotion_w
map <leader>e <Plug>CamelCaseMotion_e
map <leader>b <Plug>CamelCaseMotion_b
autocmd TextChanged,TextChangedI * silent! write

let g:saved_ibus_engine = system('ibus engine')
augroup IbusSwitch
  autocmd!
  " autocmd InsertEnter * call system('ibus engine Unikey')
  autocmd InsertLeave * call system('ibus engine xkb:us::eng')
  autocmd InsertEnter * call system('ibus engine ' . g:saved_ibus_engine)
augroup END
call system('ibus engine xkb:us::eng')
