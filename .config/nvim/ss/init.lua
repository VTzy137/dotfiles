-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins
require("lazy").setup({
    { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } },
    { 'glacambre/firenvim', build = ':call firenvim#install(0)' },
    -- Add other plugins here
    {
        'glacambre/firenvim',
        build = ':call firenvim#install(0)',
        config = function()
            vim.g.firenvim_config = {
                globalSettings = { alt = 'all' },
                localSettings = {
                    ['.*'] = {
                        takeover = 'always',
                    }
                }
            }
        end
    },
})
build = ':call firenvim#install(0)'
vim.g.firenvim_config = {
    globalSettings = { alt = 'all' },
    localSettings = {
        ['.*'] = {
            takeover = 'always',  -- Options: 'never', 'always', 'same'
        }
    }
}

vim.o.syntax = 'on'
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
