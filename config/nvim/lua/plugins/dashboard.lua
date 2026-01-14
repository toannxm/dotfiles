---@type LazySpec
return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local dash = require('dashboard')

        -- Mode toggle (simple vs enhanced)
        _G.DASHBOARD_MODE = _G.DASHBOARD_MODE or 'enhanced'

        -- Headers
        local big_header = {
            '███╗   ██╗███████╗██╗   ██╗██╗███╗  ██╗',
            '████╗  ██║██╔════╝██║   ██║██║████╗ ██║',
            '██╔██╗ ██║█████╗  ██║   ██║██║██╔██╗██║',
            '██║╚██╗██║██╔══╝  ╚██╗ ██╔╝██║██║╚████║',
            '██║ ╚████║███████╗ ╚████╔╝ ██║██║ ╚███║',
            '╚═╝  ╚═══╝╚══════╝  ╚═══╝  ╚═╝╚═╝  ╚══╝',
        }
        local mini_header = { 'Neo Start' }
        local function header()
            return (vim.o.columns > 100) and big_header or mini_header
        end

        -- Stats helpers
        local function plugin_stats()
            local ok, lazy = pcall(require, 'lazy')
            if not ok then return 'Lazy not loaded' end
            local s = lazy.stats()
            return string.format('⚡ %d/%d plugins in %dms', s.loaded or 0, s.count or 0, s.startuptime or 0)
        end
        local function lsp_summary()
            local c = vim.lsp.get_active_clients() or {}
            if #c == 0 then return 'LSP: none' end
            local names = {}
            for _, cl in ipairs(c) do names[#names+1] = cl.name end
            return 'LSP: ' .. table.concat(names, ', ')
        end
        local function diagnostics_summary()
            local d = {0,0,0,0}
            for _, item in ipairs(vim.diagnostic.get(0)) do d[item.severity] = d[item.severity] + 1 end
            return string.format(' %d   %d   %d   %d', d[vim.diagnostic.severity.ERROR], d[vim.diagnostic.severity.WARN], d[vim.diagnostic.severity.INFO], d[vim.diagnostic.severity.HINT])
        end
        local function git_branch()
            local ok, head = pcall(function() return vim.fn.systemlist('git symbolic-ref --short -q HEAD')[1] end)
            if not ok or not head or head == '' then return ' no-branch' end
            return ' ' .. head
        end
        local quotes = {
            'Focus on depth, not speed.',
            'Small steps > zero steps.',
            'Refactor before it hurts.',
            'Consistency beats intensity.',
            'Read the code you fear touching.',
        }
        math.randomseed(os.time())
        local function random_quote() return quotes[math.random(#quotes)] end
        local function clock() return os.date('  %H:%M') end

        -- Gradient highlight groups
        local gradient = {
            { name = 'DashboardHeaderGrad1', fg = '#89dceb' },
            { name = 'DashboardHeaderGrad2', fg = '#74c7ec' },
            { name = 'DashboardHeaderGrad3', fg = '#94e2d5' },
            { name = 'DashboardHeaderGrad4', fg = '#a6e3a1' },
            { name = 'DashboardHeaderGrad5', fg = '#f9e2af' },
            { name = 'DashboardHeaderGrad6', fg = '#f2cdcd' },
        }
        for _, g in ipairs(gradient) do pcall(vim.api.nvim_set_hl, 0, g.name, { fg = g.fg, bold = true }) end
        pcall(vim.api.nvim_set_hl, 0, 'DashboardFooter', { fg = '#7fdbca', italic = true })

        -- Icon/section highlight groups for project & MRU lists
        local function apply_section_hl()
            pcall(vim.api.nvim_set_hl, 0, 'DashboardProjectTitle', { fg = '#89b4fa', bold = true })
            pcall(vim.api.nvim_set_hl, 0, 'DashboardProjectIcon', { fg = '#fab387', bold = true })
            pcall(vim.api.nvim_set_hl, 0, 'DashboardMruTitle', { fg = '#cba6f7', bold = true })
            pcall(vim.api.nvim_set_hl, 0, 'DashboardMruIcon', { fg = '#94e2d5', bold = true })
            pcall(vim.api.nvim_set_hl, 0, 'DashboardFiles', { fg = '#a6adc8' })
            pcall(vim.api.nvim_set_hl, 0, 'DashboardShortCutIcon', { fg = '#f9e2af', bold = true })
        end
        apply_section_hl()

        local function reinforce_header()
            if _G.DASHBOARD_MODE ~= 'enhanced' then return end
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype ~= 'dashboard' then return end
            local ns = vim.api.nvim_create_namespace('DashHdr')
            local lines = vim.api.nvim_buf_get_lines(buf, 0, #big_header + 2, false)
            for i, line in ipairs(lines) do
                if line:find('███') then
                    local segs = #gradient
                    local seg_len = math.floor(#line / segs)
                        for s = 1, segs do
                            local start_col = (s - 1) * seg_len
                            local end_col = (s == segs) and #line or (s * seg_len)
                            pcall(vim.api.nvim_buf_add_highlight, buf, ns, gradient[s].name, i - 1, start_col, end_col)
                        end
                elseif line:find('Neo Start') then
                    vim.api.nvim_buf_add_highlight(buf, ns, 'DashboardHeaderGrad3', i - 1, 0, -1)
                end
            end
        end

        -- Transparency utility
        local function transparent()
            local groups = { 'Normal','NormalNC','NormalFloat','SignColumn','FloatBorder','WinSeparator','MsgArea','TelescopeNormal','TelescopeBorder','TelescopePromptNormal','TelescopePromptBorder','TelescopeResultsNormal','TelescopeResultsBorder','TelescopePreviewNormal','TelescopePreviewBorder' }
            for _, g in ipairs(groups) do pcall(vim.api.nvim_set_hl, 0, g, { bg = 'none' }) end
        end

        -- Build config depending on mode
        local function build_config()
            local base_shortcuts = {
                { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
                { icon = ' ', icon_hl='@variable', desc = 'Files', group = 'Label', action='Telescope find_files', key='f' },
                { desc = ' Grep', group = 'DiagnosticHint', action = 'Telescope live_grep', key = 'g' },
                { desc = ' Mason', group='@property', action='Mason', key='m' },
                { desc = ' Explorer', group='Label', action='Oil', key='o' },
                { desc = ' Themes', group='Number', action='Telescope colorscheme', key='t' },
            }
            local cfg = {
                week_header = { enable = true },
                shortcut = base_shortcuts,
                project = { enable = true, limit = 8, icon = ' ', label = 'Projects', action = 'Telescope find_files cwd=' },
                packages = { enable = (_G.DASHBOARD_MODE == 'simple') },
            }
            if _G.DASHBOARD_MODE == 'enhanced' then
                cfg.header = header()
                cfg.footer = function()
                    return {
                        plugin_stats(),
                        lsp_summary(),
                        diagnostics_summary(),
                        git_branch(),
                        clock() .. '  ' .. random_quote(),
                    }
                end
            end
            return cfg
        end

        dash.setup({ theme = 'hyper', change_to_vcs_root = true, config = build_config() })

        -- Autocmds
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'dashboard',
            callback = function()
                if _G.DASHBOARD_MODE == 'enhanced' then
                    vim.defer_fn(reinforce_header, 10)
                end
                transparent()
                apply_section_hl()
            end
        })
        vim.api.nvim_create_autocmd('ColorScheme', { callback = function()
            if vim.bo.filetype == 'dashboard' and _G.DASHBOARD_MODE == 'enhanced' then
                vim.defer_fn(reinforce_header, 20)
            end
            transparent()
            apply_section_hl()
        end })

        -- User commands
        vim.api.nvim_create_user_command('DashboardModeToggle', function()
            _G.DASHBOARD_MODE = (_G.DASHBOARD_MODE == 'enhanced') and 'simple' or 'enhanced'
            vim.notify('Dashboard mode -> ' .. _G.DASHBOARD_MODE)
            dash.setup({ theme = 'hyper', change_to_vcs_root = true, config = build_config() })
            if vim.bo.filetype == 'dashboard' then
                vim.cmd('Dashboard')
            end
        end, { desc = 'Toggle dashboard mode (simple/enhanced)' })

        vim.api.nvim_create_user_command('DashboardRedraw', function()
            if _G.DASHBOARD_MODE == 'enhanced' then reinforce_header() end
            transparent()
            apply_section_hl()
            vim.notify('Dashboard refreshed')
        end, { desc = 'Reapply dashboard styling' })
    end
}
