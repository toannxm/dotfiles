return {
    "stevearc/oil.nvim",
    cmd = {"Oil"},
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {
        default_file_explorer = true,
        columns = {"icon"},
        view_options = {
            show_hidden = true
        },
        skip_confirm_for_simple_edits = true
    }
}
