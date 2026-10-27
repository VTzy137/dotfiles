
-- require('firenvimm')
vim.g.firenvim_config = {
    globalSettings = { alt = "all" },
    localSettings = {
        [".*"] = {
            takeover = "never",
            css = "body { background-color: #1e1e1e; color: #1e1e1e; }"
        }
    }
}
            
if vim.g.started_by_firenvim then
    vim.opt.laststatus = 0
    vim.opt.number = true
    -- vim.opt.relativenumber = false
    vim.opt.showmode = false
    -- vim.opt.background = 'dark'
    vim.opt.termguicolors = true
    -- vim.cmd('set winblend=0')  -- Disable transparency
    -- vim.cmd('highlight Normal guibg=#1E1E1E')  -- Set to dark grey
    vim.o.autowriteall = true
end
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    if vim.g.started_by_firenvim then
      if vim.o.lines < 10 then
        vim.o.lines = 10
      end
    end
  end,
})

