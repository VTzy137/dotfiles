
require('configg')

require('lazy').setup({
  { 'glacambre/firenvim', build = ":call firenvim#install(0)" },
  -- 'b0o/incline.nvim',
  'L3MON4D3/LuaSnip',
  'folke/tokyonight.nvim',  
  'easymotion/vim-easymotion',
  'tpope/vim-surround',
  'bkad/CamelCaseMotion',
  'nvim-treesitter/nvim-treesitter',
  'akinsho/toggleterm.nvim',
  'feline-nvim/feline.nvim',
  'ggandor/lightspeed.nvim',
  'nvim-telescope/telescope.nvim',
  'nvim-telescope/telescope-file-browser.nvim',
  'nvim-tree/nvim-web-devicons',
  'nvim-tree/nvim-tree.lua',
  'norcalli/nvim-colorizer.lua',

  'hrsh7th/nvim-cmp',
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'numToStr/Comment.nvim',
 
  "folke/which-key.nvim",
  "windwp/nvim-autopairs",
  "rafamadriz/friendly-snippets",
})


require('nvim-autopairs').setup()
require("snippets.lua") 

local builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<A-f>', builtin.find_files, { desc = 'Telescope find files' })

vim.o.guicursor = "n-v-c:hor20,i-ci-ve:ver25,r-cr:hor20,o:hor50"
vim.o.guifont = "Fira Code:h12"

-- require("telescope").load_extension("file_browser")
require("tokyonightt")
require("nvimtreee")
require('feline').setup()
require('firenvimm')
require('cmpp')
require('toggletermm')
require('colorizerr')
require('commentt')
require('luasnipp')
