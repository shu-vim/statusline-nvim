vim.api.nvim_exec(
  [[
       augroup Statusline
       au!
       au WinEnter,BufEnter * set statusline=%!v:lua.require('statusline-nvim').active()
       au WinLeave,BufLeave * setlocal statusline=%!v:lua.require('statusline-nvim').inactive()
       au ColorScheme * lua require('statusline-nvim')._highlight(true)
       augroup END
     ]],
  false
)
vim.o.showmode = false

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
