-- polish.lua active (guard removed)
-- Final customization layer.
-- Add small QoL improvements here.
-- Example: highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Briefly highlight yanked text",
    callback = function()
        vim.highlight.on_yank {
            higroup = "IncSearch",
            timeout = 120
        }
    end
})

-- Keymap: reopen dashboard manually
vim.keymap.set("n", "<Leader>ud", function()
    local ok = pcall(vim.cmd, "Dashboard")
    if not ok then
        vim.notify("Dashboard command not found", vim.log.levels.WARN)
    end
end, {
    desc = "Open Dashboard"
})

-- Keymap: toggle relative number
vim.keymap.set("n", "<Leader>tr", function()
    vim.o.relativenumber = not vim.o.relativenumber
    vim.notify("relativenumber = " .. tostring(vim.o.relativenumber))
end, {
    desc = "Toggle relative number"
})

-- Example: reduce updatetime for CursorHold events
vim.o.updatetime = 300

-- Environment sanity: warn if node missing or outdated (<16) which can break json-lsp/copilot installs
local function check_node()
    if vim.fn.executable("node") == 0 then
        vim.schedule(function()
            vim.notify("Node.js not found in PATH (needed for json-lsp, copilot, prettier)", vim.log.levels.WARN)
        end)
        return
    end
    local ok, out = pcall(vim.fn.systemlist, "node -v")
    if not ok or not out or not out[1] then
        return
    end
    local ver = out[1]:gsub("^v", "")
    local major = tonumber(ver:match("^(%d+)%..*$")) or 0
    if major < 16 then
        vim.schedule(function()
            vim.notify("Node.js version " .. ver .. " is old; json-lsp may fail. Consider upgrading to >=18.",
                vim.log.levels.WARN)
        end)
    end
end

check_node()

-- GUI Font Management (NeoFont)
-- Provides helper commands to manage GUI font dynamically.
-- Commands:
--  :NeoFontSet {Font Name} h{size}  (example: :NeoFontSet "MesloLGS NF" h16)
--  :NeoFontInc and :NeoFontDec      (increment/decrement size by 1)
--  :NeoFontCycle                    (cycle through predefined font families)
--  :NeoFontList                     (echo current configured font & candidate list)
-- Detection covers Neovide/goneovim/other GUIs.

local has_gui = (vim.fn.has('gui_running') == 1) or vim.g.neovide or vim.g.goneovim or vim.g.nvim_gui_shim
local NeoFont = {
    fonts = {'MesloLGS NF', 'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', 'Hack Nerd Font', 'Iosevka Nerd Font'},
    index = 1,
    size = 16
}

-- Parse current guifont if already set
if vim.o.guifont ~= '' then
    -- Use Lua pattern %d instead of nonstandard \d
    local name, sz = vim.o.guifont:match('^(.-):h(%d+)')
    if name and sz then
        NeoFont.size = tonumber(sz) or NeoFont.size
        -- try to align index with existing name
        for i, f in ipairs(NeoFont.fonts) do
            if f == name then
                NeoFont.index = i
                break
            end
        end
    end
end

local function apply_font()
    if not has_gui then
        vim.notify('NeoFont: Not in a GUI; guifont has no effect', vim.log.levels.WARN)
        return
    end
    local font = NeoFont.fonts[NeoFont.index]
    vim.o.guifont = string.format('%s:h%d', font, NeoFont.size)
    vim.notify('NeoFont -> ' .. vim.o.guifont)
end

local function set_font(name, size)
    if name and name ~= '' then
        -- if name not in list, append
        local exists = false
        for i, f in ipairs(NeoFont.fonts) do
            if f == name then
                NeoFont.index = i
                exists = true
                break
            end
        end
        if not exists then
            table.insert(NeoFont.fonts, 1, name)
            NeoFont.index = 1
        end
    end
    if size then
        NeoFont.size = size
    end
    apply_font()
end

vim.api.nvim_create_user_command('NeoFontSet', function(opts)
    if not has_gui then
        vim.notify('NeoFontSet: GUI not detected', vim.log.levels.WARN)
        return
    end
    local args = opts.args
    if args == '' then
        vim.notify('Usage: :NeoFontSet {Font Name} h{size}', vim.log.levels.INFO)
        return
    end
    -- Correct pattern: %d for digits
    local name, size = args:match('^(.-)%s+h(%d+)$')
    if not name then
        name = args
    end
    local sznum = size and tonumber(size) or nil
    set_font(vim.trim(name), sznum)
end, {
    nargs = '+',
    complete = function(_, line)
        local compl = {}
        for _, f in ipairs(NeoFont.fonts) do
            if f:lower():find(line:lower(), 1, true) then
                table.insert(compl, f)
            end
        end
        return compl
    end,
    desc = 'Set GUI font (NeoFont)'
})

vim.api.nvim_create_user_command('NeoFontInc', function()
    NeoFont.size = NeoFont.size + 1
    apply_font()
end, {
    desc = 'Increase GUI font size'
})

vim.api.nvim_create_user_command('NeoFontDec', function()
    NeoFont.size = math.max(4, NeoFont.size - 1)
    apply_font()
end, {
    desc = 'Decrease GUI font size'
})

vim.api.nvim_create_user_command('NeoFontCycle', function()
    NeoFont.index = (NeoFont.index % #NeoFont.fonts) + 1
    apply_font()
end, {
    desc = 'Cycle through predefined fonts'
})

vim.api.nvim_create_user_command('NeoFontList', function()
    local lines = {'NeoFont Candidates:'}
    for i, f in ipairs(NeoFont.fonts) do
        local marker = (i == NeoFont.index) and '*' or ' '
        table.insert(lines, string.format('%s %d. %s', marker, i, f))
    end
    table.insert(lines, string.format('Current: %s (size %d)', NeoFont.fonts[NeoFont.index], NeoFont.size))
    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end, {
    desc = 'List available fonts & current selection'
})

-- Keymaps (optional convenience)
vim.keymap.set('n', '<Leader>fi', ':NeoFontInc<CR>', {
    desc = 'Font ++'
})
vim.keymap.set('n', '<Leader>fd', ':NeoFontDec<CR>', {
    desc = 'Font --'
})
vim.keymap.set('n', '<Leader>fc', ':NeoFontCycle<CR>', {
    desc = 'Font cycle'
})

-- Apply at startup if GUI
if has_gui and vim.o.guifont == '' then
    apply_font()
end

-- =============================================================
-- Keymap Introspection Helper
-- :Keymaps                -> show all keymaps grouped by mode
-- :Keymaps n/i/v/t        -> show only specific modes (space separated)
-- :Keymaps grep=<pattern> -> filter by substring (case-insensitive)
-- :Keymaps lhs=<pattern>  -> filter by lhs match
-- <Leader>hk opens the viewer
-- =============================================================

local function collect_keymaps(modes)
    local res = {}
    for _, m in ipairs(modes) do
        for _, km in ipairs(vim.api.nvim_get_keymap(m)) do
            table.insert(res, vim.tbl_extend('force', km, { mode = m }))
        end
        -- buffer local maps (current buffer only) try-catch
        pcall(function()
            for _, km in ipairs(vim.api.nvim_buf_get_keymap(0, m)) do
                km.buffer = true
                km.mode = m
                table.insert(res, km)
            end
        end)
    end
    return res
end

local function render_keymaps(opts)
    opts = opts or {}
    local modes = opts.modes or { 'n', 'i', 'v', 'x', 's', 'o', 't', 'c' }
    local all = collect_keymaps(modes)
    local grep = opts.grep and opts.grep:lower()
    local lhs_pat = opts.lhs and opts.lhs:lower()

    local lines = {}
    table.insert(lines, 'Keymaps Viewer')
    table.insert(lines, string.rep('─', 60))
    table.insert(lines, string.format('Modes: %s', table.concat(modes, ' ')))
    if grep then table.insert(lines, 'Filter (desc/rhs): ' .. grep) end
    if lhs_pat then table.insert(lines, 'Filter (lhs): ' .. lhs_pat) end
    table.insert(lines, '')

    table.sort(all, function(a, b)
        if a.mode == b.mode then
            return (a.lhs or '') < (b.lhs or '')
        end
        return a.mode < b.mode
    end)

    for _, km in ipairs(all) do
        local desc = km.desc or km.rhs or ''
        local lhs = km.lhs or ''
        local rhs = km.rhs or ''
        local mode = km.mode
        if not (grep and not (desc:lower():find(grep, 1, true) or rhs:lower():find(grep, 1, true))) and
            not (lhs_pat and not lhs:lower():find(lhs_pat, 1, true)) then
            local flags = {}
            if km.buffer then table.insert(flags, 'buf') end
            if km.expr == 1 then table.insert(flags, 'expr') end
            if km.nowait == 1 then table.insert(flags, 'nowait') end
            if km.silent == 1 then table.insert(flags, 'silent') end
            if km.noremap == 1 then table.insert(flags, 'nore') end
            local flagstr = (#flags > 0) and (' [' .. table.concat(flags, ',') .. ']') or ''
            table.insert(lines, string.format('%s %-15s → %-25s %s%s', mode, lhs, rhs ~= '' and rhs or '⋯', desc, flagstr))
        end
    end
    if #lines == 0 then
        lines = { 'No keymaps matched filters.' }
    end
    return lines
end

local function open_keymaps_win(opts)
    local lines = render_keymaps(opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'keymaps'

    local width = math.max(80, math.floor(vim.o.columns * 0.7))
    local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.7))
    local row = math.floor((vim.o.lines - height) / 2 - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = 'rounded'
    })
    vim.keymap.set('n', 'q', function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, { buffer = buf, desc = 'Close keymaps viewer' })
end

vim.api.nvim_create_user_command('Keymaps', function(cmdopts)
    local args = cmdopts.fargs
    local modes = {}
    local grep
    local lhs
    for _, a in ipairs(args) do
        if a:match('^grep=') then
            grep = a:sub(6)
        elseif a:match('^lhs=') then
            lhs = a:sub(5)
        elseif a:match('^[nivxslotc]+$') then
            for c in a:gmatch('.') do table.insert(modes, c) end
        end
    end
    if #modes == 0 then
        modes = { 'n', 'i', 'v', 'x', 's', 'o', 't', 'c' }
    end
    open_keymaps_win({ modes = modes, grep = grep, lhs = lhs })
end, { nargs = '*', complete = function(_, line)
    local compl = { 'n', 'i', 'v', 'x', 's', 'o', 't', 'c', 'grep=', 'lhs=' }
    local out = {}
    for _, c in ipairs(compl) do
        if c:find(line, 1, true) then table.insert(out, c) end
    end
    return out
end, desc = 'Open keymaps viewer (floating)' })

-- Convenience mapping
vim.keymap.set('n', '<Leader>hk', function()
    vim.cmd('Keymaps')
end, { desc = 'Help: Keymaps viewer' })
