# statusline-nvim

Neovim plugin to customize the statusline.

![screenshot](https://raw.githubusercontent.com/shu-vim/statusline-nvim/main/screenshots/ss1.png)

## Install

### lazy.nvim

```lua
return { "shu-vim/statusline-nvim" }
```

with devicons
```lua
return {
    "shu-vim/statusline-nvim"
    dependencies = { 'nvim-tree/nvim-web-devicons' },
}
```

## Usage

Enabled by default on startup.

## Setup/Config

### Default config

```lua
return {
    "shu-vim/hzzh-nvim",
    opts = {
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
        alpha = 0.1, -- blendes 10% of mode color
    }
}
```

### Full

```lua
return {
    "shu-vim/statusline-nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
        local c = require('statusline-nvim/components')

        local severities = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
            [vim.diagnostic.severity.HINT] = '󰌵 ',
        }

        return {
            active = {
                c.mode_hl,
                ' ',
                c.mode,
                ' ',
                '%#SLDefault# ',
                c.gen_git_branch(),
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
                ' ',
                c.gen_lsp(severities),
                '%=',
                c.fileencoding,
                ' | ',
                c.fileformat,
                ' | ',
                c.filetype,
                ' | %l:%v ',
            },
            inactive = {
                '%#SLDir#',
                c.dir,
                '/',
                '%#SLDefault#',
                '%t%h%q',
                c.gen_modified('●', '')
            },
            highlights = {
                SLDefault = { link = 'StatusLine' },
                SLModeNormal = { fg = '#112233', bg = '#aaddee' },
                SLModeInsert = { fg = '#113311', bg = '#aaeeaa' },
                SLModeSelect = { fg = '#333311', bg = '#bbbb77' },
                SLModeVisual = { fg = '#333311', bg = '#ffff77' },
                SLModeReplace = { fg = '#331111', bg = '#ff7777' },
                SLModeCommand = { fg = '#ffffff', bg = '#111111' },
                SLModeTerminal = { fg = '#ffffff', bg = '#111111' },
                SLDir = { fg = 'gray' },
                SLLocked = { fg = '#ffff00' },
                SLReadonly = { fg = '#dd0000' },
                SLModified = { link = 'StatusLine' },
                SLSuspicious = { fg = '#ee8888' },
            },
            alpha = 0.2,
        }
    end,
}
```

---

Maintainer: Shuhei Kubota <kubota.shuhei+vim@gmail.com>
