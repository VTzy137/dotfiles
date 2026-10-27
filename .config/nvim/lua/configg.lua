
vim.keymap.set('n', 'qp', ':q<CR>', { noremap = true, 
silent = true })

-- Set runtimepath to include ~/.vim and ~/.vim/after
vim.opt.runtimepath:append("~/.vim")
vim.opt.runtimepath:append("~/.vim/after")
vim.opt.packpath = vim.o.runtimepath

-- Source .vimrc (if needed, though it's better to migrate everything to Lua)
vim.cmd("source ~/.vimrc")

-- Enable 24-bit color
vim.opt.termguicolors = true
-- Disable netrw at the very start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Neoformat Vim configuration
vim.g.nvim_tree_change_dir = 1
vim.g.neoformat_vim = {
    exe = "vim",
    args = { "-E", "-s", "-c", "normal gg=G", "-c", "wq", "%" },
    tempfile = 1
}
