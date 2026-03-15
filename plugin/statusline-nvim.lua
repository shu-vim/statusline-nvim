local group = vim.api.nvim_create_augroup('statusline-nvim', { clear = true })

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = group,
  callback = function() vim.o.statusline = "%!v:lua.require('statusline-nvim').active()" end,
})

vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = group,
  callback = function() vim.wo.statusline = "%!v:lua.require('statusline-nvim').inactive()" end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function() require('statusline-nvim')._highlight(true) end,
})

vim.o.showmode = false

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
