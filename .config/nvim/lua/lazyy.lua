require('lazy').setup({
  { 'glacambre/firenvim', build = ":call firenvim#install(0)" },
  -- 'b0o/incline.nvim',
  'L3MON4D3/LuaSnip',
  'folke/tokyonight.nvim',  
  -- "tpope/vim-commentary",
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
 
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  }
})
