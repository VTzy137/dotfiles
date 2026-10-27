require("nvim-tree").setup({
    on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'J', '5j', opts)
        vim.keymap.set('n', 'K', '5k', opts)
        vim.keymap.set('n', '<CR>', api.node.open.edit, opts) 
        vim.keymap.set('n', '<esc>', api.node.navigate.parent_close, opts)
        vim.keymap.set('n', 'o', api.tree.change_root_to_node, opts)
        vim.keymap.set('n', 'r', api.fs.rename, opts)
    end,
    renderer = {
        icons = {
            show = {
                folder = true,
                file = true,
                git = true,
            },
        },
    },
})
-- vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-e>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
