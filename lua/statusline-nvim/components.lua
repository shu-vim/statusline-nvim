local M = {}

M._mode_map = {
  ['n'] = { name = 'NORMAL', hl = '%#SLModeNormal#' },
  ['i'] = { name = 'INSERT', hl = '%#SLModeInsert#' },
  ['v'] = { name = 'VISUAL', hl = '%#SLModeVisual#' },
  ['V'] = { name = 'V-LINE', hl = '%#SLModeVisual#' },
  ['\22'] = { name = 'V-BLOCK', hl = '%#SLModeVisual#' },
  ['s'] = { name = 'SELECT', hl = '%#SLModeSelect#' },
  ['S'] = { name = 'SELECT', hl = '%#SLModeSelect#' },
  ['\23'] = { name = 'V-SELECT', hl = '%#SLModeVisual#' },
  ['R'] = { name = 'REPLACE', hl = '%#SLModeReplace#' },
  ['r'] = { name = 'REPLACE', hl = '%#SLModeReplace#' },
  ['c'] = { name = 'COMMAND', hl = '%#SLModeCommand#' },
  ['t'] = { name = 'TERMINAL', hl = '%#SLModeTerminal#' },
}

M._mode = function() return string.lower(string.sub(vim.api.nvim_get_mode().mode, 1, 1)) end

--- Returns the statusline highlight group name based on the current mode. (e.g., "%#SLModeNormal#")
M.mode_hl = function()
  local current = M._mode_map[M._mode()] or { name = ' UNKNOWN ', hl = '%#SLDefault#' }
  return current.hl
end

--- Returns the first character of the current mode name. (e.g., 'n' for Normal, 'i' for Insert)
M.mode = function()
  local current = M._mode_map[M._mode()] or { name = ' UNKNOWN ', hl = '%#SLDefault#' }
  return current.name
end

----------

--- Returns the parent directory of the current buffer.
M.dir = function() return vim.fn.expand('%:p:h:t') end

----------

--- Returns the name of the current buffer.
M.file = function()
  local bt = vim.bo.buftype

  if bt == 'quickfix' then
    return 'quickfix'
  elseif bt == 'help' then
    return 'help'
  else
    local name = vim.fn.expand('%:t')
    if name == '' then
      return 'No Name'
    else
      return name
    end
  end
end

----------

M.line = function() return vim.fn.line('.') end

----------

M.col = function() return vim.fn.col('.') end

----------

_G.fileencoding_onclick = function() vim.cmd([[setlocal fileencoding=utf-8]]) end

--- Returns the buffer's fileencoding.
---
--- Applies the 'SLSuspicious' highlight group if the encoding is not UTF-8.
--- Clicking this area will change the file encoding to UTF-8.
M.fileencoding = function()
  local enc = vim.bo.fileencoding
  if enc == '' then enc = 'utf-8' end
  if enc ~= 'utf-8' then enc = '%#SLSuspicious#%@v:lua.fileencoding_onclick@' .. enc .. '%X%#SLDefault#' end
  return enc
end

----------

_G.fileformat_onclick = function() vim.cmd([[setlocal fileformat=unix]]) end

--- Returns the buffer's fileformat. (unix/dos/mac)
---
--- Applies the 'SLSuspicious' highlight group if the fileformat is not unix.
--- Clicking this area will change the fileformat to unix.
M.fileformat = function()
  local fmt = vim.bo.fileformat
  if fmt ~= 'unix' then fmt = '%#SLSuspicious#%@v:lua.fileformat_onclick@' .. fmt .. '%X%#SLDefault#' end
  return fmt
end

----------

--- Returns the buffer's filetype.
local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
M.filetype = function()
  local typ = vim.bo.filetype
  if typ == '' then
    return 'type?'
  elseif devicons_ok then
    local icon = devicons.get_icon('', typ)
    if icon == nil then
      icon = ''
    else
      icon = icon .. ' '
    end
    typ = icon .. typ
  end
  return typ
end

----------

--- Returns a function that returns yesChar(highlighted with SLReadonly) or noChar.
M.gen_readonly = function()
  return function()
    local statusline = require('statusline-nvim')
    local m = vim.bo.readonly
    if m then
      return '%#SLReadonly#' .. statusline.config.symbols.Readonly .. '%#SLDefault#'
    else
      return ''
    end
  end
end

----------

--- Returns a function that returns yesChar(highlighted with SLLocked) or noChar.
M.gen_modifiable = function()
  return function()
    local statusline = require('statusline-nvim')
    local m = vim.bo.modifiable
    if not m then
      return '%#SLLocked#' .. statusline.config.symbols.NoModifiable .. '%#SLDefault#'
    else
      return ''
    end
  end
end

----------

--- Returns a function that returns yesChar(highlighted with SLModified) or noChar.
M.gen_modified = function()
  return function()
    local statusline = require('statusline-nvim')
    local m = vim.bo.modified
    if m then
      return '%#SLModified#' .. statusline.config.symbols.Modified .. '%#SLDefault#'
    else
      return ''
    end
  end
end

----------

_G.lsp_onclick = function() vim.diagnostic.setqflist() end

--- Returns a function that returns LSP diagnostic.
M.gen_lsp = function()
  return function()
    local statusline = require('statusline-nvim')

    local severities = {
      { severity = vim.diagnostic.severity.ERROR, hl = '%#SLLspError#', sym = statusline.config.symbols.LSPError },
      { severity = vim.diagnostic.severity.WARN, hl = '%#SLLspWarn#', sym = statusline.config.symbols.LSPWarn },
      { severity = vim.diagnostic.severity.INFO, hl = '%#SLLspInfo#', sym = statusline.config.symbols.LSPInfo },
      { severity = vim.diagnostic.severity.HINT, hl = '%#SLLspHint#', sym = statusline.config.symbols.LSPHint },
    }

    local result = ''
    for i = 1, #severities do
      local s = severities[i]
      local count = #vim.diagnostic.get(vim.fn.bufnr('%'), { severity = s.severity })
      if count > 0 then
        local char = s.sym or ''
        result = result .. s.hl .. char .. count .. '%#SLDefault#'
      end
    end

    if result ~= '' then result = '%@v:lua.lsp_onclick@' .. result .. '%X' end

    return result
  end
end

----------

M.gen_git_branch = function()
  local executable = vim.fn.executable('git') == 1
  if not executable then
    return function() return '' end
  end

  local branch = ''
  local unpushed = 0
  local unpulled = 0

  local group = vim.api.nvim_create_augroup('statusline-nvim.git.branch', { clear = true })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
    group = group,
    callback = function()
      ---@type string
      local path = vim.fn.expand('%:p')
      local exclude_patterns = M.exclude_patterns or {}
      for i = 1, #exclude_patterns do
        if path:find(exclude_patterns[i]) then
          vim.notify('excluded')
          branch = ''
          unpushed = 0
          unpulled = 0
          return
        end
      end

      local obj = vim.system({ 'git', 'branch', '--show-current' }, { text = true }):wait()
      if obj.code ~= 0 then branch = '' end
      branch = obj.stdout:gsub('\n', '')

      unpushed = 0
      if branch ~= '' then
        obj = vim.system({ 'git', 'rev-list', '--count', '@{u}..HEAD' }, { text = true }):wait()
        if obj.code ~= 0 then unpushed = 0 end
        unpushed = tonumber(obj.stdout) or 0
      end

      unpulled = 0
      if branch ~= '' then
        obj = vim.system({ 'git', 'rev-list', '--count', 'HEAD..@{u}' }, { text = true }):wait()
        if obj.code ~= 0 then unpulled = 0 end
        unpulled = tonumber(obj.stdout) or 0
      end
    end,
  })

  return function()
    local statusline = require('statusline-nvim')
    if branch == '' then
      return ''
    else
      local result = '%#SLGitBranch#' .. statusline.config.symbols.GitBranch .. branch .. '%#SLDefault#'
      if unpulled + unpushed ~= 0 then result = result .. ' ' end
      if unpulled ~= 0 then
        result = result .. '%#SLGitUnpulled#' .. statusline.config.symbols.GitUnpulled .. unpulled .. '%#SLDefault#'
      end
      if unpushed ~= 0 then
        result = result .. '%#SLGitUnpushed#' .. statusline.config.symbols.GitUnpushed .. unpushed .. '%#SLDefault#'
      end
      return result .. ' '
    end
  end
end

----------

return M

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
