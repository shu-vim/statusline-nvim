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

M.mode_hl = function()
	local current = M._mode_map[M._mode()] or { name = ' UNKNOWN ', hl = '%#SLDefault#' }
	return current.hl
end

M.mode = function()
	local current = M._mode_map[M._mode()] or { name = ' UNKNOWN ', hl = '%#SLDefault#' }
	return current.name
end

----------

M.dir = function() return vim.fn.expand('%:p:h:t') end

----------

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

M.fileencoding = function()
	local enc = vim.bo.fileencoding
	if enc == '' then enc = 'utf-8' end
	if enc ~= 'utf-8' then enc = '%#SLSuspicious#%@v:lua.fileencoding_onclick@' .. enc .. '%X%#SLDefault#' end
	return enc
end

----------

_G.fileformat_onclick = function() vim.cmd([[setlocal fileformat=unix]]) end

M.fileformat = function()
	local fmt = vim.bo.fileformat
	if fmt ~= 'unix' then fmt = '%#SLSuspicious#%@v:lua.fileformat_onclick@' .. fmt .. '%X%#SLDefault#' end
	return fmt
end

----------

M.filetype = function()
	local typ = vim.bo.filetype
	if typ == '' then return 'type?' end
	return typ
end

----------

M.gen_readonly = function(yesChar, noChar)
	return function()
		local m = vim.bo.readonly
		if m then
			return '%#SLReadonly#' .. yesChar .. '%#SLDefault#'
		else
			return noChar
		end
	end
end

----------

M.gen_modifiable = function(yesChar, noChar)
	return function()
		local m = vim.bo.modifiable
		if m then
			return '%#SLLocked#' .. yesChar .. '%#SLDefault#'
		else
			return noChar
		end
	end
end

----------

M.gen_modified = function(yesChar, noChar)
	return function()
		local m = vim.bo.modified
		if m then
			return '%#SLModified#' .. yesChar .. '%#SLDefault#'
		else
			return noChar
		end
	end
end

return M
