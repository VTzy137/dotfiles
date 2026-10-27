
require("toggleterm").setup({
  size = 50,
  open_mapping = [[<C-'>]],
  direction = "horizontal",
})
vim.api.nvim_set_keymap("n", "<A-'>", ":ToggleTerm direction=horizontal<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<A-'>", ":ToggleTermToggleAll<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-`>", ":ToggleTerm direction=float<CR>", { noremap = true, silent = true })

vim.keymap.set("t", '<esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
