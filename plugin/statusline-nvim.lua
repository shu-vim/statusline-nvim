local group = vim.api.nvim_create_augroup('statusline-nvim', { clear = true })

vim.api.nvim_create_autocmd({
  'BufEnter',
  'CursorHold',
  'DirChanged',
  'FocusGained',
  'ModeChanged',
  'TextChanged',
  'WinEnter',
}, {
  group = group,
  callback = function(ev) require('statusline-nvim').set_statusline(ev.buf, vim.api.nvim_get_current_win()) end,
})

vim.api.nvim_create_autocmd({
  'BufLeave',
  'WinLeave',
}, {
  group = group,
  callback = function(ev) require('statusline-nvim').set_statusline(ev.buf, -1) end,
})

vim.api.nvim_create_autocmd({
  'User',
}, {
  group = group,
  pattern = 'StatulineNvimUpdate',
  callback = function(ev) require('statusline-nvim').set_statusline(ev.buf, vim.api.nvim_get_current_win()) end,
})

vim.api.nvim_create_autocmd({
  'OptionSet',
}, {
  group = group,
  callback = function()
    vim.api.nvim_exec_autocmds('User', {
      pattern = 'StatulineNvimUpdate',
    })
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = function() require('statusline-nvim')._highlight(true) end,
})

vim.o.showmode = false

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
