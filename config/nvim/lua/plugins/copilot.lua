---@type LazySpec
return {
    "zbirenbaum/copilot.lua",
    optional = true, -- imported through astrocommunity
    opts = function(_, opts)
        -- Node detection logic
        local function exists(cmd)
            return vim.fn.executable(cmd) == 1
        end

        local node_cmd = nil

        -- 1. Respect user override env
        if vim.env.COPILOT_NODE_CMD and vim.fn.executable(vim.env.COPILOT_NODE_CMD) == 1 then
            node_cmd = vim.env.COPILOT_NODE_CMD
        end

        -- 2. Common managers
        if not node_cmd and exists("node") then
            node_cmd = "node"
        end
        if not node_cmd and exists("fnm") then
            local fnm = vim.fn.trim(vim.fn.system("fnm which node"))
            if vim.v.shell_error == 0 and fnm ~= "" and vim.fn.filereadable(fnm) == 1 then
                node_cmd = fnm
            end
        end
        if not node_cmd and exists("volta") then
            local volta = vim.fn.trim(vim.fn.system("volta which node"))
            if vim.v.shell_error == 0 and volta ~= "" and vim.fn.filereadable(volta) == 1 then
                node_cmd = volta
            end
        end
        if not node_cmd and vim.env.NVM_DIR then
            local nvm_node = vim.env.NVM_DIR .. "/versions/node/" .. (vim.env.NODE_VERSION or "") .. "/bin/node"
            if vim.fn.filereadable(nvm_node) == 1 then
                node_cmd = nvm_node
            end
        end
        -- Asdf
        if not node_cmd and exists("asdf") then
            local asdf = vim.fn.trim(vim.fn.system("asdf which node"))
            if vim.v.shell_error == 0 and asdf ~= "" and vim.fn.filereadable(asdf) == 1 then
                node_cmd = asdf
            end
        end

        -- Last resort: common macOS Homebrew path
        if not node_cmd then
            local hb = "/opt/homebrew/bin/node"
            if vim.fn.filereadable(hb) == 1 then
                node_cmd = hb
            end
        end

        if node_cmd then
            vim.g.copilot_node_command = node_cmd
        else
            vim.schedule(function()
                vim.notify("Copilot: Could not detect a working Node.js binary. Set COPILOT_NODE_CMD or install Node.",
                    vim.log.levels.WARN)
            end)
        end

        opts = opts or {}
        -- ensure panel + suggestion are enabled (can tweak later)
        opts.panel = opts.panel or {
            enabled = true
        }
        opts.suggestion = opts.suggestion or {
            enabled = true,
            auto_trigger = true
        }

        return opts
    end
}
