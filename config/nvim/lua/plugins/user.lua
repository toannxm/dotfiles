-- User plugin specifications (cleaned)
---@type LazySpec
return { -- Presence
"andweeb/presence.nvim", -- LSP signature help
{
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function()
        require("lsp_signature").setup()
    end
}, -- Disable Snacks dashboard (we will supply our own dashboard plugin spec separately)
{
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            enabled = false
        }
    }
}, -- LuaSnip customizations
{
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
        require "astronvim.plugins.configs.luasnip"(plugin, opts)
        local luasnip = require "luasnip"
        luasnip.filetype_extend("javascript", {"javascriptreact"})
    end
}, -- Autopairs extra rules
{
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
        require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts)
        local npairs = require "nvim-autopairs"
        local Rule = require "nvim-autopairs.rule"
        local cond = require "nvim-autopairs.conds"
        npairs.add_rules({Rule("$", "$", {"tex", "latex"}):with_pair(cond.not_after_regex "%%"):with_pair(
            cond.not_before_regex("xxx", 3)):with_move(cond.none()):with_del(cond.not_after_regex "xx"):with_cr(
            cond.none())}, Rule("a", "a", "-vim"))
    end
}, -- Example of disabling a default plugin
{
    "max397574/better-escape.nvim",
    enabled = false
}, -- Telescope fzf-native for faster sorting (conditionally builds if make available)
{
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
        return vim.fn.executable("make") == 1
    end,
    dependencies = {"nvim-telescope/telescope.nvim"},
    config = function()
        local ok, telescope = pcall(require, "telescope")
        if ok then
            pcall(telescope.load_extension, "fzf")
        end
    end
}, -- Indentation guides (disable to remove vertical bars)
{
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
    main = "ibl",
    -- If you want to keep it but make it subtle instead of disabling, remove `enabled = false` and use:
    -- opts = {
    --   indent = { char = "·" }, -- or " " (space) for effectively invisible
    --   whitespace = { remove_blankline_trail = true },
    --   scope = { enabled = false },
    -- }
}
}
