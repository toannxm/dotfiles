return {
	'glepnir/nerdicons.nvim',
	cmd = 'NerdIcons',
	opts = {},
	config = function(_, opts)
		require('nerdicons').setup(opts)

		-- Custom highlight palette for NerdIcons popup
		local function apply_nerdicons_hl()
			-- You can tweak these colors later; designed to stand out on transparent bg
			pcall(vim.api.nvim_set_hl, 0, 'NerdIconPrompt', { fg = '#89b4fa', bg = 'none', bold = true })
			pcall(vim.api.nvim_set_hl, 0, 'NerdIconPreviewPrompt', { fg = '#f5c2e7', bg = 'none', italic = true })
			pcall(vim.api.nvim_set_hl, 0, 'NerdIconNormal', { fg = '#a6adc8', bg = 'none' })
			pcall(vim.api.nvim_set_hl, 0, 'NerdIconBorder', { fg = '#94e2d5', bg = 'none' })
		end
		apply_nerdicons_hl()

		vim.api.nvim_create_autocmd('ColorScheme', {
			group = vim.api.nvim_create_augroup('NerdIconsHL', { clear = true }),
			callback = function()
				apply_nerdicons_hl()
			end,
		})
	end,
}