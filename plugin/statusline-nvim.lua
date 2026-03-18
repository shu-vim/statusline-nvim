local group = vim.api.nvim_create_augroup('statusline-nvim', { clear = true })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'OptionSet', 'ModeChanged' }, {
  group = group,
  callback = function()
    require('statusline-nvim')._dirty()
    local statusline = "%!v:lua.require('statusline-nvim').active()"
    if vim.o.statusline ~= statusline then vim.o.statusline = statusline end
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = group,
  callback = function()
    require('statusline-nvim')._dirty()
    local statusline = "%!v:lua.require('statusline-nvim').inactive()"
    if vim.wo.statusline ~= statusline then vim.wo.statusline = statusline end
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function()
    require('statusline-nvim')._dirty()
    require('statusline-nvim')._highlight(true)
  end,
})

vim.o.showmode = false

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
