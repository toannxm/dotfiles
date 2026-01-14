-- Mason customization active (guard removed)
-- Customize Mason
---@type LazySpec
return { -- use mason-tool-installer for automatically installing Mason packages
{
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
        -- Make sure to use the names found in `:Mason`
        ensure_installed = { -- install language servers
        "lua-language-server", "json-lsp", "pyright", "rust-analyzer", "bash-language-server",
        "typescript-language-server", -- install formatters
        "stylua", "prettier", "ruff", -- install debuggers
        "debugpy", "codelldb", -- install any other package
        "tree-sitter-cli", "eslint_d"}
    }
}}
