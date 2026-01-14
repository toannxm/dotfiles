-- AstroCore active (guard removed)
-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing
---@type LazySpec
return {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
        -- Configure core features of AstroNvim
        features = {
            large_buf = {
                size = 1024 * 256,
                lines = 10000
            }, -- set global limits for large files for disabling features like treesitter
            autopairs = true, -- enable autopairs at start
            cmp = true, -- enable completion at start
            diagnostics = {
                virtual_text = true,
                virtual_lines = false
            }, -- diagnostic settings on startup
            highlighturl = true, -- highlight URLs at start
            notifications = true -- enable notifications at start
        },
        -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
        diagnostics = {
            virtual_text = true,
            underline = true
        },
        -- passed to `vim.filetype.add`
        filetypes = {
            -- see `:h vim.filetype.add` for usage
            extension = {
                foo = "fooscript"
            },
            filename = {
                [".foorc"] = "fooscript"
            },
            pattern = {
                [".*/etc/foo/.*"] = "fooscript"
            }
        },
        -- vim options can be configured here
        options = {
            opt = { -- vim.opt.<key>
                relativenumber = true, -- sets vim.opt.relativenumber
                number = true, -- sets vim.opt.number
                spell = false, -- sets vim.opt.spell
                signcolumn = "yes", -- sets vim.opt.signcolumn to yes
                wrap = false -- sets vim.opt.wrap
            },
            g = { -- vim.g.<key>
                -- configure global vim variables (vim.g)
                -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
                -- This can be found in the `lua/lazy_setup.lua` file
            }
        },
        -- Mappings can be configured through AstroCore as well.
        -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
        mappings = {
            -- first key is the mode
            n = {
                -- second key is the lefthand side of the map

                -- navigate buffer tabs
                ["]b"] = {
                    function()
                        require("astrocore.buffer").nav(vim.v.count1)
                    end,
                    desc = "Next buffer"
                },
                ["[b"] = {
                    function()
                        require("astrocore.buffer").nav(-vim.v.count1)
                    end,
                    desc = "Previous buffer"
                },

                -- mappings seen under group name "Buffer"
                ["<Leader>bd"] = {
                    function()
                        require("astroui.status.heirline").buffer_picker(function(bufnr)
                            require("astrocore.buffer").close(bufnr)
                        end)
                    end,
                    desc = "Close buffer from tabline"
                }

                -- tables with just a `desc` key will be registered with which-key if it's installed
                -- this is useful for naming menus
                -- ["<Leader>b"] = { desc = "Buffers" },

                -- setting a mapping to false will disable it
                -- ["<C-S>"] = false,
            },
            i = {
                -- Smart Tab: Copilot > completion > snippet jump > fallback
                ["<Tab>"] = {
                    function()
                        -- 1. Copilot inline suggestion accept if visible
                        local ok_copilot, cp = pcall(require, 'copilot.suggestion')
                        if ok_copilot and cp.is_visible() then
                            cp.accept()
                            return
                        end
                        -- 2. nvim-cmp completion navigation / confirm first item
                        local ok_cmp, cmp = pcall(require, 'cmp')
                        if ok_cmp then
                            local cmp_visible = false
                            -- Some versions expose cmp.visible(); if not, check internal view
                            if type(cmp.visible) == 'function' then
                                local ok_vis, vis = pcall(cmp.visible)
                                cmp_visible = ok_vis and vis or false
                            elseif cmp.core and cmp.core.view and type(cmp.core.view.visible) == 'function' then
                                local ok_vis, vis = pcall(cmp.core.view.visible, cmp.core.view)
                                cmp_visible = ok_vis and vis or false
                            elseif cmp.core and cmp.core.view and type(cmp.core.view.visible) == 'boolean' then
                                cmp_visible = cmp.core.view.visible
                            end
                            if cmp_visible then
                                local ok_sel = pcall(cmp.select_next_item, { behavior = cmp.SelectBehavior.Select })
                                if ok_sel then return end
                            end
                            local entry_ok, entry = pcall(cmp.get_active_entry)
                            if entry_ok and entry then
                                local ok_conf = pcall(cmp.confirm, { select = true })
                                if ok_conf then return end
                            end
                        end
                        -- 3. luasnip jump forward if available
                        local ok_snip, ls = pcall(require, 'luasnip')
                        if ok_snip and ls.expand_or_jumpable() then
                            ls.expand_or_jump()
                            return
                        end
                        -- 4. fallback to literal tab or indentation
                        local col = vim.fn.col('.') - 1
                        if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
                        else
                            -- trigger completion if cmp available
                            if ok_cmp then
                                cmp.complete()
                            else
                                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
                            end
                        end
                    end,
                    desc = 'Smart Tab (Copilot/Completion/Snippet)'
                },
                ["<S-Tab>"] = {
                    function()
                        local ok_copilot, cp = pcall(require, 'copilot.suggestion')
                        -- just dismiss Copilot on Shift-Tab if visible
                        if ok_copilot and cp.is_visible() then
                            cp.dismiss()
                            return
                        end
                        local ok_cmp, cmp = pcall(require, 'cmp')
                        if ok_cmp then
                            local cmp_visible = false
                            if type(cmp.visible) == 'function' then
                                local ok_vis, vis = pcall(cmp.visible)
                                cmp_visible = ok_vis and vis or false
                            elseif cmp.core and cmp.core.view and type(cmp.core.view.visible) == 'function' then
                                local ok_vis, vis = pcall(cmp.core.view.visible, cmp.core.view)
                                cmp_visible = ok_vis and vis or false
                            elseif cmp.core and cmp.core.view and type(cmp.core.view.visible) == 'boolean' then
                                cmp_visible = cmp.core.view.visible
                            end
                            if cmp_visible then
                                local ok_sel = pcall(cmp.select_prev_item, { behavior = cmp.SelectBehavior.Select })
                                if ok_sel then return end
                            end
                        end
                        local ok_snip, ls = pcall(require, 'luasnip')
                        if ok_snip and ls.jumpable(-1) then
                            ls.jump(-1)
                            return
                        end
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Tab>', true, false, true), 'n', false)
                    end,
                    desc = 'Smart Shift-Tab'
                },
                -- Dedicated Copilot accept (full suggestion) on Ctrl-j
                ["<C-j>"] = {
                    function()
                        local ok_copilot, cp = pcall(require, 'copilot.suggestion')
                        if ok_copilot and cp.is_visible() then
                            cp.accept()
                        else
                            -- fallback to cmp confirm if menu open
                            local ok_cmp, cmp = pcall(require, 'cmp')
                            local cmp_visible = false
                            if ok_cmp then
                                if type(cmp.visible) == 'function' then
                                    local ok_vis, vis = pcall(cmp.visible)
                                    cmp_visible = ok_vis and vis or false
                                elseif cmp.core and cmp.core.view and type(cmp.core.view.visible) == 'function' then
                                    local ok_vis, vis = pcall(cmp.core.view.visible, cmp.core.view)
                                    cmp_visible = ok_vis and vis or false
                                elseif cmp.core and cmp.core.view and type(cmp.core.view.visible) == 'boolean' then
                                    cmp_visible = cmp.core.view.visible
                                end
                            end
                            if cmp_visible then
                                local ok_conf = pcall(cmp.confirm, { select = true })
                                if not ok_conf then
                                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-j>', true, false, true), 'n', false)
                                end
                            else
                                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-j>', true, false, true), 'n', false)
                            end
                        end
                    end,
                    desc = 'Accept Copilot or confirm completion'
                },
            },
            c = {},
        },
        -- Add a small on_config hook to create a :CompletionStatus command after setup
        on_config = function()
            vim.api.nvim_create_user_command('CompletionStatus', function()
                local parts = {}
                local ok_cmp, cmp = pcall(require, 'cmp')
                local cmp_state = 'missing'
                if ok_cmp then
                    local cmp_visible = false
                    if type(cmp.visible) == 'function' then
                        local ok_vis, vis = pcall(cmp.visible)
                        cmp_visible = ok_vis and vis or false
                    elseif cmp.core and cmp.core.view then
                        local v = cmp.core.view
                        if type(v.visible) == 'function' then
                            local ok_vis, vis = pcall(v.visible, v)
                            cmp_visible = ok_vis and vis or false
                        elseif type(v.visible) == 'boolean' then
                            cmp_visible = v.visible
                        end
                    end
                    cmp_state = cmp_visible and 'MENU' or 'idle'
                end
                table.insert(parts, 'cmp=' .. cmp_state)
                local ok_cp, cp = pcall(require, 'copilot.suggestion')
                if ok_cp then
                    local vis = cp.is_visible() and 'visible' or 'hidden'
                    table.insert(parts, 'copilot=' .. vis)
                else
                    table.insert(parts, 'copilot=missing')
                end
                local ok_ls, ls = pcall(require, 'luasnip')
                if ok_ls then
                    local jump_f = ls.expand_or_jumpable() and '>' or '-'
                    local jump_b = ls.jumpable(-1) and '<' or '-'
                    table.insert(parts, ('snip=%s%s'):format(jump_b, jump_f))
                else
                    table.insert(parts, 'snip=missing')
                end
                vim.notify(table.concat(parts, ' | '), vim.log.levels.INFO, { title = 'CompletionStatus' })
            end, { desc = 'Show completion / Copilot status' })
        end,
    },
}
