local group = vim.api.nvim_create_augroup('statusline-nvim', { clear = true })

vim.api.nvim_create_autocmd({ 'FocusGained', 'WinEnter', 'BufEnter', 'BufModifiedSet', 'OptionSet', 'ModeChanged' }, {
  group = group,
  callback = function()
    local statusline = require('statusline-nvim').active()
    vim.o.statusline = statusline
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = group,
  callback = function()
    local statusline = require('statusline-nvim').inactive()
    vim.wo.statusline = statusline
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function() require('statusline-nvim')._highlight(true) end,
})

vim.o.showmode = false

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
