local M = {}

M.resolve = function(hlname, default)
  local hl
  if type(hlname) == 'table' then
    hl = hlname
  else
    hl = vim.api.nvim_get_hl(0, { name = hlname })
  end
  local link = hl['link']
  if link ~= nil then hl = M.resolve(link, default) end
  if hl.reverse then
    hl.fg, hl.bg = hl.bg, hl.fg
  end
  if hl.bg == nil or hl.bg == 'NONE' then
    local defhl = M.resolve(default)
    hl.bg = defhl.bg
  end
  return hl
end

return M

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
