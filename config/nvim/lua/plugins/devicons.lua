return {
    'nvim-tree/nvim-web-devicons',
    -- Ensure it loads early enough for dashboard/oil
    lazy = true,
    opts = {
        override = {},
        default = true,
        color_icons = true,
        strict = true
    }
}
