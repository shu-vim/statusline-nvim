local M = {}

local bit = require('bit')
local hl = require('statusline-nvim/hl')
local c = require('statusline-nvim/components')

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

	local mode = c.mode()

	if mode == M.prevMode then return end
	M.prevMode = mode

	local h = vim.tbl_deep_extend('force', {}, M.config._highlights)

	local mode_hl = string.sub(c.mode_hl(), 3, -2)

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
		c.mode_hl,
		' ',
		c.mode,
		' ',
		'%#SLDefault# ',
		c.gen_modifiable('', '🔒'),
		' ',
		'%#SLDir#',
		c.dir,
		'/',
		'%#SLDefault#',
		c.file,
		' ',
		c.gen_modified('●', ''),
		c.gen_readonly('🚫', ''),
		'%=',
		c.fileencoding,
		' | ',
		c.fileformat,
		' | ',
		c.filetype,
		' | %l:%v ',
	},
	inactive = { '%t%h%q', c.gen_modified('●', '') },
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
		SLLSPError = { link = 'DiagnosticError' },
		SLLSPWarn = { link = 'DiagnosticWarn' },
		SLLSPInfo = { link = 'DiagnosticInfo' },
		SLLSPHint = { link = 'DiagnosticHint' },
	},
	alpha = 0.1,
}

M.setup = function(args) M.config = vim.tbl_deep_extend('force', M.config, args or {}) end

return M
