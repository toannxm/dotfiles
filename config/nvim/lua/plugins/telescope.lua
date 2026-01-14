---@type LazySpec
return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- track latest
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = function()
        return {
            defaults = {
                prompt_prefix = "   ",
                selection_caret = " ",
                layout_config = {
                    horizontal = {
                        preview_width = 0.55
                    }
                }
            }
        }
    end,
    config = function(_, opts)
        if vim.fn.has("nvim-0.9.0") ~= 1 then
            vim.notify("Telescope requires Neovim >= 0.9.0", vim.log.levels.ERROR)
            return
        end
        local telescope = require "telescope"
        telescope.setup(opts)

        -- Highlight groups
        local highlights = {
            TelescopeSelection = {
                link = "Visual"
            },
            TelescopeSelectionCaret = {
                link = "TelescopeSelection"
            },
            TelescopeMultiSelection = {
                link = "Type"
            },
            TelescopeMultiIcon = {
                link = "Identifier"
            },
            TelescopeNormal = {
                link = "Normal"
            },
            TelescopePreviewNormal = {
                link = "TelescopeNormal"
            },
            TelescopePromptNormal = {
                link = "TelescopeNormal"
            },
            TelescopeResultsNormal = {
                link = "TelescopeNormal"
            },
            TelescopeBorder = {
                link = "TelescopeNormal"
            },
            TelescopePromptBorder = {
                link = "TelescopeBorder"
            },
            TelescopeResultsBorder = {
                link = "TelescopeBorder"
            },
            TelescopePreviewBorder = {
                link = "TelescopeBorder"
            },
            TelescopeTitle = {
                link = "TelescopeBorder"
            },
            TelescopePromptTitle = {
                link = "TelescopeTitle"
            },
            TelescopeResultsTitle = {
                link = "TelescopeTitle"
            },
            TelescopePreviewTitle = {
                link = "TelescopeTitle"
            },
            TelescopePromptCounter = {
                link = "NonText"
            },
            TelescopeMatching = {
                link = "Special"
            },
            TelescopePromptPrefix = {
                link = "Identifier"
            },
            TelescopePreviewLine = {
                link = "Visual"
            },
            TelescopePreviewMatch = {
                link = "Search"
            },
            TelescopePreviewDirectory = {
                link = "Directory"
            },
            TelescopePreviewLink = {
                link = "Special"
            },
            TelescopePreviewSocket = {
                link = "Statement"
            },
            TelescopePreviewRead = {
                link = "Constant"
            },
            TelescopePreviewWrite = {
                link = "Statement"
            },
            TelescopePreviewExecute = {
                link = "String"
            },
            TelescopeResultsClass = {
                link = "Function"
            },
            TelescopeResultsConstant = {
                link = "Constant"
            },
            TelescopeResultsField = {
                link = "Function"
            },
            TelescopeResultsFunction = {
                link = "Function"
            },
            TelescopeResultsMethod = {
                link = "Function"
            },
            TelescopeResultsOperator = {
                link = "Operator"
            },
            TelescopeResultsStruct = {
                link = "Structure"
            },
            TelescopeResultsVariable = {
                link = "SpecialChar"
            },
            TelescopeResultsLineNr = {
                link = "LineNr"
            },
            TelescopeResultsIdentifier = {
                link = "Identifier"
            },
            TelescopeResultsNumber = {
                link = "Number"
            },
            TelescopeResultsComment = {
                link = "Comment"
            },
            TelescopeResultsSpecialComment = {
                link = "SpecialComment"
            },
            TelescopeResultsDiffChange = {
                link = "DiffChange"
            },
            TelescopeResultsDiffAdd = {
                link = "DiffAdd"
            },
            TelescopeResultsDiffDelete = {
                link = "DiffDelete"
            },
            TelescopeResultsDiffUntracked = {
                link = "NonText"
            }
        }
        for k, v in pairs(highlights) do
            pcall(vim.api.nvim_set_hl, 0, k, v)
        end

        -- Command-line mapping example (optional)
        -- vim.keymap.set('c', '<Plug>(TelescopeFuzzyCommandSearch)', ...) -- can be re-added if you use it
    end
}
