local group = vim.api.nvim_create_augroup('statusline-nvim', { clear = true })

vim.api.nvim_create_autocmd({
  'BufEnter',
  'BufLeave',
  'BufModifiedSet',
  'CursorHold',
  'DirChanged',
  'FocusGained',
  'ModeChanged',
  'OptionSet',
  'WinEnter',
  'WinLeave',
}, {
  group = group,
  callback = function(ev) require('statusline-nvim').set_statusline(ev.buf, vim.api.nvim_get_current_win()) end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function() require('statusline-nvim')._highlight(true) end,
})

vim.o.showmode = false

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
