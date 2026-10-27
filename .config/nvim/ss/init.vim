set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Map Tr to open NvimTree
nnoremap Tr :NvimTreeOpen<CR>

let g:firenvim_config = {
    \ 'globalSettings': {'alt': 'all'},
    \ 'localSettings': {
        \ '.*': {
            \ 'takeover': 'never',
            \ 'css': 'body { background-color: #1e1e1e; color: #ffffff; }'
        \ }
    \ }
\ }

let g:neoformat_vim = {
    \ 'exe': 'vim',
    \ 'args': ['-E', '-s', '-c', 'normal gg=G', '-c', 'wq', '%'],
    \ 'tempfile': 1,
    \ }


" Disable netrw at the very start
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" Optionally enable 24-bit color
set termguicolors

" Empty setup using defaults
lua require("nvim-tree").setup()
lua << EOF
require'nvim-tree'.setup {
  renderer = {
    icons = {
      show = {
        folder = true,
        file = true,
        git = true,
      },
    },
  },
}
EOF

