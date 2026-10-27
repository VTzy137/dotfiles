require("tokyonight").setup({
    style = "storm", -- Options: "storm", "moon", "night", "day"
    transparent = true, -- Enable transparent background
    terminal_colors = true, -- Configure colors for terminal
    styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { bold = true },
        variables = {},
    },
    sidebars = { "qf", "help" }, -- Set specific background for certain sidebars
})
vim.cmd[[colorscheme tokyonight]]
