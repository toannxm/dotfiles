-- Treesitter customization active (guard removed)
-- Customize Treesitter
---@type LazySpec
return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = {"lua", "vim", "vimdoc", "javascript", "typescript", "json", "yaml", "markdown",
                            "markdown_inline", "bash", "python", "rust", "toml", "gitignore", "gitcommit"}
    }
}
