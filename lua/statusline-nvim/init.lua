local M = {}

local hl = require('statusline-nvim/hl')
local bit = require('bit')

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

M.dir = function() return vim.fn.expand('%:p:h:t') end

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

M.line = function() return vim.fn.line('.') end

M.col = function() return vim.fn.col('.') end

_G.fileencoding_onclick = function() vim.cmd([[setlocal fileencoding=utf-8]]) end

M.fileencoding = function()
	local enc = vim.bo.fileencoding
	if enc == '' then enc = 'utf-8' end
	if enc ~= 'utf-8' then enc = '%#SLSuspicious#%@v:lua.fileencoding_onclick@' .. enc .. '%X%#SLDefault#' end
	return enc
end

_G.fileformat_onclick = function() vim.cmd([[setlocal fileformat=unix]]) end

M.fileformat = function()
	local fmt = vim.bo.fileformat
	if fmt ~= 'unix' then fmt = '%#SLSuspicious#%@v:lua.fileformat_onclick@' .. fmt .. '%X%#SLDefault#' end
	return fmt
end

M.filetype = function()
	local typ = vim.bo.filetype
	if typ == '' then return 'type?' end
	return typ
end

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

M.count = 0
M.prevMode = ''
M._highlight = function(init)
	if init then
		M.config._highlights = nil
		M.prevMode = ''
	end

	if M.config._highlights == nil then
		M.config._highlights = {}
		M.count = M.count + 1
		for k, v in pairs(M.config.highlights) do
			vim.api.nvim_set_hl(0, k, v)
			M.config._highlights[k] = hl.resolve(k, 'StatusLine')
		end
	end

	local mode = M.mode()

	if mode == M.prevMode then return end
	M.prevMode = mode

	local h = M.config._highlights
	h = vim.tbl_deep_extend('force', {}, M.config._highlights)

	local mode_hl = string.sub(M.mode_hl(), 3, -2)

	-- alpha blending
	for k, v in pairs(h) do
		if string.find(k, 'Mode', 1, true) then goto continue end

		--v = hl.resolve(v, 'StatusLine')
		local vv = vim.tbl_deep_extend('force', {}, v)
		local m = hl.resolve(M.config._highlights[mode_hl])

		local vr, vg, vb = bit.band(v.bg, 0xff0000), bit.band(v.bg, 0x00ff00), bit.band(v.bg, 0x0000ff)
		local mr, mg, mb = bit.band(m.bg, 0xff0000), bit.band(m.bg, 0x00ff00), bit.band(m.bg, 0x0000ff)
		local r = bit.band(vr * (1 - M.config.alpha) + mr * M.config.alpha, 0xff0000)
		local g = bit.band(vg * (1 - M.config.alpha) + mg * M.config.alpha, 0x00ff00)
		local b = bit.band(vb * (1 - M.config.alpha) + mb * M.config.alpha, 0x0000ff)
		vv.bg = r + g + b
		h[k] = vv

		::continue::
	end

	M.count = M.count + 1
	for k, v in pairs(h) do
		vim.api.nvim_set_hl(0, k, v)
	end
end

M._build = function(arr)
	local result = ''
	for i = 1, #arr do
		if type(arr[i]) == 'function' then
			result = result .. arr[i]()
		else
			result = result .. arr[i]
		end
	end
	return result
end

M.active = function()
	M._highlight()
	return M._build(M.config.active)
end

M.inactive = function()
	M._highlight()
	return M._build(M.config.inactive)
end

M.config = {
	active = {
		M.mode_hl,
		' ',
		M.mode,
		' ',
		'%#SLDefault# ',
		M.gen_modifiable('', '🔒'),
		' ',
		'%#SLDir#',
		M.dir,
		'/',
		'%#SLDefault#',
		M.file,
		' ',
		M.gen_modified('●', ''),
		M.gen_readonly('🚫', ''),
		'%=',
		M.fileencoding,
		' | ',
		M.fileformat,
		' | ',
		M.filetype,
		' | %l:%v ',
	},
	inactive = { '%t%h%q', M.gen_modified('●', '') },
	highlights = {
		SLDefault = { link = 'StatusLine' },
		SLModeNormal = { fg = '#112233', bg = '#aaddee' },
		SLModeInsert = { fg = '#113311', bg = '#aaeeaa' },
		SLModeSelect = { fg = '#333311', bg = '#bbbb77' },
		SLModeVisual = { fg = '#333311', bg = '#ffff77' },
		SLModeReplace = { fg = '#331111', bg = '#ff7777' },
		SLModeCommand = { fg = '#111111', bg = '#ffffff' },
		SLModeTerminal = { fg = '#111111', bg = '#ffffff' },
		SLDir = { fg = 'gray' },
		SLLocked = { fg = '#ffff00' },
		SLReadonly = { fg = '#dd0000' },
		SLModified = { link = 'StatusLine' },
		SLSuspicious = { fg = '#ee8888' },
	},
	alpha = 0.1,
}

M.setup = function(args)
	M.config = vim.tbl_deep_extend('force', M.config, args or {})

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
end

return M
