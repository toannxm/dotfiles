return {
    "xiyaowong/transparent.nvim",
    -- We want this automatically, not only when a command is run
    event = "VeryLazy", -- load after UI & colorscheme so we can clear safely
    opts = {
        groups = { -- Core UI
        "Normal", "NormalNC", "NormalFloat", "FloatBorder", "WinSeparator", "SignColumn", "LineNr", "CursorLine",
        "CursorLineNr", "FoldColumn", "EndOfBuffer", "MsgArea", "StatusLine", "StatusLineNC", "VertSplit",
        -- Popups / menus
        "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb", "WhichKeyFloat", "WhichKeyNormal", -- Telescope
        "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal", "TelescopePromptBorder",
        "TelescopeResultsNormal", "TelescopeResultsBorder", "TelescopePreviewNormal", "TelescopePreviewBorder",
        -- Dashboard
        "DashboardHeader", "DashboardCenter", "DashboardFooter", "DashboardShortCut", "DashboardProjectTitle",
        "DashboardProjectTitleIcon", "DashboardProjectIcon", "DashboardMruTitle", "DashboardMruIcon", "DashboardFiles",
        "DashboardShortCutIcon", -- Tabline / winbar
        "TabLine", "TabLineFill", "TabLineSel", "WinBar", "WinBarNC", -- Misc common plugin groups
        "NeoTreeNormal", "NeoTreeNormalNC", "FloatTitle", "NoiceCmdlinePopup", "NoicePopup"},
        extra_groups = {},
        exclude_groups = {}
    },
    config = function(_, opts)
        local ok, transparent = pcall(require, "transparent")
        if not ok then
            return
        end
        transparent.setup(opts)

        local function force_clear()
            -- Explicitly wipe backgrounds for a few critical groups in case colorscheme re-applied
            local force = {"Normal", "NormalNC", "NormalFloat", "SignColumn", "LineNr", "EndOfBuffer", "FloatBorder",
                           "WinSeparator"}
            for _, g in ipairs(force) do
                pcall(vim.api.nvim_set_hl, 0, g, {
                    bg = "none"
                })
            end
            -- Use plugin's enable to clear the rest (handles links & previously set groups)
            pcall(transparent.enable)
        end

        -- Initial clear (after a slight defer to ensure colorscheme did its thing)
        vim.defer_fn(force_clear, 30)

        -- Reapply whenever colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("ReTransparent", {
                clear = true
            }),
            callback = function()
                vim.defer_fn(force_clear, 10)
            end
        })

        -- User command to hard refresh transparency if something overrides later
        vim.api.nvim_create_user_command("TransparencyRefresh", force_clear, {
            desc = "Reapply background transparency"
        })
    end
}
