# Neovim Setup Guide

This guide covers the Neovim configuration in this dotfiles repository, based on AstroNvim v5+ with custom plugins and language support.

## Overview

The Neovim setup uses:
- **AstroNvim v5** - Feature-rich Neovim configuration framework
- **Lazy.nvim** - Modern plugin manager
- **AstroCommunity** - Curated plugin collections and language packs
- **Custom plugins** - Project-specific enhancements
- **Multiple LSP servers** - Language support for Lua, Rust, Python, TypeScript, Bash, etc.
- **GitHub Copilot** - AI-powered code completion

## Directory Structure

```
config/nvim/
├── init.lua                 # Entry point (loads lazy_setup.lua)
├── lua/
│   ├── lazy_setup.lua       # Lazy.nvim configuration
│   ├── community.lua        # AstroCommunity imports
│   ├── polish.lua           # Final customizations & QoL tweaks
│   └── plugins/             # Custom plugin specifications
│       ├── astrocore.lua    # Core AstroNvim settings
│       ├── astrolsp.lua     # LSP configuration
│       ├── astroui.lua      # UI settings
│       ├── copilot.lua      # GitHub Copilot setup
│       ├── dashboard.lua    # Start screen
│       ├── devicons.lua     # File icons
│       ├── mason.lua        # LSP/tool installer
│       ├── none-ls.lua      # Formatting & diagnostics
│       ├── oil.lua          # File browser
│       ├── telescope.lua    # Fuzzy finder
│       ├── transparent.lua  # Transparent background
│       ├── treesitter.lua   # Syntax highlighting
│       └── user.lua         # Additional user plugins
└── README.md                # AstroNvim template info
```

## Installation

### Prerequisites

Ensure these are installed (handled by `install.sh --lang`):

```bash
# Neovim (latest stable)
brew install neovim

# Node.js (required for many LSPs and Copilot)
fnm install --lts
node --version  # Should be >= 16

# Python (for Python LSP and tools)
pyenv install 3.13
python3 --version

# Ripgrep (for Telescope)
brew install ripgrep

# Nerd Font (for icons)
# Already installed via Brewfile (MesloLGS NF, JetBrains Mono, etc.)
```

### Setup Steps

The dotfiles installation automatically symlinks the Neovim config:

```bash
# Full setup (includes Neovim config)
./install.sh --all

# Or just link dotfiles
./install.sh --dotfiles
```

This creates: `~/.config/nvim` → `~/Workday/MacSetup/dotfiles/config/nvim`

### First Launch

```bash
nvim
```

On first launch:
1. Lazy.nvim auto-installs
2. Plugins download and install
3. Treesitter parsers compile
4. LSP servers install via Mason (may take 1-2 minutes)

If any plugins fail, run:
```bash
nvim +Lazy sync
```

## Configuration Architecture

### Loading Order

1. **init.lua** → Minimal entry point, calls `lazy_setup.lua`
2. **lazy_setup.lua** → Configures Lazy.nvim, imports:
   - `astronvim.plugins` (AstroNvim core)
   - `community.lua` (AstroCommunity modules)
   - `plugins/` (Custom plugin specs)
3. **community.lua** → Loads language packs and community plugins
4. **plugins/*.lua** → Plugin-specific configurations
5. **polish.lua** → Final tweaks, autocommands, keymaps

### Key Configuration Files

**lazy_setup.lua**:
- Sets leader keys (`<Space>` for leader, `,` for local leader)
- Enables icons
- Configures Lazy UI and performance options
- Imports plugin specifications

**community.lua**:
- Imports AstroCommunity modules for:
  - **Colorscheme**: Catppuccin
  - **Completion**: Copilot
  - **Language Packs**: Lua, Rust, Python, TypeScript, JSON, Bash, Markdown, YAML

**polish.lua**:
- Highlights yanked text
- Custom keymaps (dashboard, relative numbers)
- Node.js version check
- GUI font management (NeoFont commands)
- Local overrides support

## Language Support

### Installed Language Packs

Via AstroCommunity (`community.lua`):

| Language | Pack | LSP Server | Formatter | Linter |
|----------|------|------------|-----------|--------|
| **Lua** | `pack.lua` | lua-language-server | stylua | - |
| **Rust** | `pack.rust` | rust-analyzer | rustfmt | clippy |
| **Python** | `pack.python` | pyright | ruff | ruff |
| **TypeScript** | `pack.typescript` | typescript-language-server | prettier | eslint_d |
| **JSON** | `pack.json` | json-lsp | prettier | - |
| **Bash** | `pack.bash` | bash-language-server | shfmt | shellcheck |
| **Markdown** | `pack.markdown` | marksman | prettier | - |
| **YAML** | `pack.yaml` | yaml-language-server | prettier | - |

### Adding New Languages

1. **Check AstroCommunity** for available packs:
   - https://github.com/AstroNvim/astrocommunity

2. **Add to** `community.lua`:
```lua
{
  import = "astrocommunity.pack.go"  -- Example: Go support
}
```

3. **Sync plugins**:
```bash
nvim +Lazy sync
```

### Manual LSP Setup

For languages without community packs, configure in `plugins/astrolsp.lua`:

```lua
return {
  "AstroNvim/astrolsp",
  opts = {
    servers = {
      "gopls",  -- Go language server
      "clangd", -- C/C++ language server
    },
  },
}
```

## Plugin Configuration

### Core Plugins

**Telescope** (`plugins/telescope.lua`):
- Fuzzy finder for files, buffers, grep
- Keymaps:
  - `<Leader>ff` - Find files
  - `<Leader>fg` - Live grep
  - `<Leader>fb` - Browse buffers
  - `<Leader>fh` - Help tags

**Oil.nvim** (`plugins/oil.lua`):
- File browser with vim-like editing
- Keymap: `<Leader>e` - Toggle file explorer

**Treesitter** (`plugins/treesitter.lua`):
- Syntax highlighting for all languages
- Auto-installs parsers for community pack languages
- Incremental selection, indentation

**Mason** (`plugins/mason.lua`):
- LSP server, formatter, linter installer
- UI: `:Mason` to manage tools
- Auto-installs tools for configured languages

**GitHub Copilot** (`plugins/copilot.lua`):
- AI-powered code completion
- Requires GitHub Copilot subscription
- First use: `:Copilot setup` → authenticate

**Dashboard** (`plugins/dashboard.lua`):
- Start screen with quick actions
- Keymap: `<Leader>ud` - Reopen dashboard

**Transparent** (`plugins/transparent.lua`):
- Makes background transparent for terminal themes
- Toggle: `:TransparentToggle`

### Customizing Plugins

Edit the corresponding file in `plugins/`:

**Example: Change Telescope layout**
```lua
-- plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "vertical",
      layout_config = {
        height = 0.95,
      },
    },
  },
}
```

**Example: Add new Treesitter parser**
```lua
-- plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua", "rust", "python", "typescript",
      "toml",  -- Add TOML support
    },
  },
}
```

## Keybindings

### Leader Key

- **Leader**: `<Space>`
- **Local Leader**: `,`

### Essential Keybindings

| Keymap | Action | Mode |
|--------|--------|------|
| `<Leader>ff` | Find files | Normal |
| `<Leader>fg` | Live grep | Normal |
| `<Leader>fb` | Browse buffers | Normal |
| `<Leader>e` | File explorer | Normal |
| `<Leader>c` | Close buffer | Normal |
| `<Leader>w` | Save file | Normal |
| `<Leader>q` | Quit | Normal |
| `gd` | Go to definition | Normal |
| `gr` | Find references | Normal |
| `K` | Hover documentation | Normal |
| `<Leader>ca` | Code actions | Normal |
| `<Leader>rn` | Rename symbol | Normal |
| `]d` / `[d` | Next/prev diagnostic | Normal |
| `<Leader>ud` | Open dashboard | Normal |
| `<Leader>tr` | Toggle relative numbers | Normal |

### Custom Keymaps

Add to `polish.lua`:

```lua
-- Example: Quick save with Ctrl+S
vim.keymap.set("n", "<C-s>", "<Cmd>w<CR>", { desc = "Save file" })

-- Example: Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
```

## Formatters & Linters

### None-ls Configuration

Located in `plugins/none-ls.lua`:

**Current setup:**
- **Formatters**: prettier, stylua, ruff
- **Linters**: eslint_d (JavaScript/TypeScript)
- **Diagnostics**: ruff (Python)

### Format on Save

AstroNvim auto-formats on save by default. To disable:

```lua
-- plugins/astrolsp.lua
return {
  "AstroNvim/astrolsp",
  opts = {
    formatting = {
      format_on_save = false,
    },
  },
}
```

### Manual Format

`:Format` or `<Leader>lf`

## Customization

### Local Overrides (Per-Machine)

Create `lua/user_local.lua` (gitignored):

```lua
-- Example: Machine-specific settings
vim.opt.relativenumber = false  -- Disable relative line numbers
vim.g.copilot_enabled = false   -- Disable Copilot

-- Custom colorscheme
vim.cmd.colorscheme("habamax")

-- Machine-specific keymaps
vim.keymap.set("n", "<Leader>xx", "<Cmd>!./build.sh<CR>", { desc = "Run build" })
```

Load it from `polish.lua`:

```lua
-- At end of polish.lua
local user_local = vim.fn.stdpath("config") .. "/lua/user_local.lua"
if vim.fn.filereadable(user_local) == 1 then
  dofile(user_local)
end
```

### Adding Custom Plugins

Create a new file in `plugins/`:

**Example: Add vim-fugitive**
```lua
-- plugins/fugitive.lua
return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gstatus", "Gblame" },
  keys = {
    { "<Leader>gs", "<Cmd>Git<CR>", desc = "Git status" },
  },
}
```

### Changing Colorscheme

Edit `community.lua`:

```lua
-- Replace catppuccin with another
{
  import = "astrocommunity.colorscheme.tokyonight-nvim"
}
```

Or set directly in `polish.lua`:

```lua
vim.cmd.colorscheme("tokyonight")
```

## GUI Font Management (NeoFont)

For GUI Neovim clients (Neovide, goneovim):

**Commands:**
- `:NeoFontSet "Font Name" h{size}` - Set font and size
  - Example: `:NeoFontSet "JetBrainsMono Nerd Font" h14`
- `:NeoFontInc` / `:NeoFontDec` - Adjust size by ±1
- `:NeoFontCycle` - Cycle through preset fonts
- `:NeoFontList` - Show current font and available options

**Preset Fonts:**
- MesloLGS NF
- JetBrainsMono Nerd Font
- FiraCode Nerd Font
- Hack Nerd Font
- Iosevka Nerd Font

## Troubleshooting

### Plugins Not Installing

```bash
# Check Lazy status
nvim +Lazy

# Force sync
nvim +Lazy sync

# Clear cache and reinstall
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
nvim +Lazy sync
```

### LSP Not Working

```bash
# Check LSP server installed
nvim +Mason

# Check LSP attached to buffer
:LspInfo

# Reinstall language server
:MasonUninstall pyright
:MasonInstall pyright
```

### Node.js Version Warning

If you see "Node.js not found" or version warnings:

```bash
# Install Node.js via fnm
fnm install --lts
fnm use lts-latest

# Verify version
node --version  # Should be >= 16
```

### Copilot Not Working

```bash
# Authenticate with GitHub
:Copilot setup

# Check status
:Copilot status

# If auth fails, try browser auth
:Copilot auth
```

### Treesitter Parser Errors

```bash
# Update all parsers
:TSUpdate

# Install specific parser
:TSInstall python

# Check installed parsers
:TSInstallInfo
```

### Icons Not Showing

Ensure Nerd Font installed and terminal configured:

```bash
# List installed fonts
fc-list | grep -i nerd

# If missing, install via Homebrew
brew install --cask font-meslo-lg-nerd-font
```

Configure terminal to use Nerd Font (e.g., "MesloLGS NF").

## Sync & Backup

### Sync Config Between Machines

The dotfiles repo handles this automatically:

```bash
# On machine 1: commit changes
cd ~/Workday/MacSetup/dotfiles
git add config/nvim
git commit -m "Update Neovim config"
git push

# On machine 2: pull changes
cd ~/Workday/MacSetup/dotfiles
git pull
nvim +Lazy sync
```

### Backup & Restore

**Before major changes:**
```bash
# Backup current config
cp -r ~/.config/nvim ~/.config/nvim.backup

# If using dotfiles, just commit
cd ~/Workday/MacSetup/dotfiles
git add config/nvim
git commit -m "Backup before changes"
```

**Restore:**
```bash
# From backup
mv ~/.config/nvim.backup ~/.config/nvim

# From git
cd ~/Workday/MacSetup/dotfiles
git checkout HEAD -- config/nvim
```

### Helper Scripts

The repo includes convenience scripts:

**Check Neovim health:**
```bash
nvim +checkhealth
```

**Update everything:**
```bash
# Update plugins
nvim +Lazy update

# Update LSP servers
nvim +Mason
# Then 'U' to update all
```

## Advanced Configuration

### Conditional Plugin Loading

Load plugins only in specific filetypes:

```lua
-- plugins/rust-tools.lua
return {
  "simrat39/rust-tools.nvim",
  ft = "rust",  -- Only load for Rust files
  opts = {
    -- rust-tools config
  },
}
```

### Lazy Loading on Commands

```lua
-- plugins/markdown-preview.lua
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview" },  -- Load on command
  build = "cd app && npm install",
}
```

### Custom Autocommands

Add to `polish.lua`:

```lua
-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa",
})

-- Highlight TODO comments
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua", "javascript" },
  callback = function()
    vim.fn.matchadd("Todo", "TODO\\|FIXME\\|NOTE")
  end,
})
```

## Performance Optimization

### Disable Unused Plugins

In `lazy_setup.lua`, the config already disables some built-in plugins:

```lua
performance = {
  rtp = {
    disabled_plugins = {
      "gzip",
      "netrwPlugin",
      "tarPlugin",
      "tohtml",
      "zipPlugin",
    },
  },
}
```

### Lazy Load More Plugins

Convert plugins to load on events/commands:

```lua
return {
  "plugin-name",
  event = "BufReadPre",  -- Load when reading buffer
  -- or
  cmd = "PluginCommand",  -- Load on command
  -- or
  keys = { "<Leader>x" },  -- Load on keymap
}
```

### Measure Startup Time

```bash
nvim --startuptime startup.log
cat startup.log
```

Look for slow-loading plugins and lazy-load them.

## Best Practices

1. **Use community packs** - Leverage AstroCommunity for language support
2. **Keep polish.lua minimal** - Only essential customizations
3. **Lazy load plugins** - Use `ft`, `cmd`, `keys` when possible
4. **Test changes incrementally** - Don't add many plugins at once
5. **Use local overrides** - Keep machine-specific config in `user_local.lua`
6. **Commit working configs** - Save stable configurations in git
7. **Read plugin docs** - Many plugins have extensive configuration options
8. **Use `:checkhealth`** - Diagnose issues regularly

## Additional Resources

- [AstroNvim Documentation](https://docs.astronvim.com/)
- [AstroCommunity Plugins](https://github.com/AstroNvim/astrocommunity)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)
- [Neovim Documentation](https://neovim.io/doc/)
- [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

## Related Documentation

- [Shell Configuration Guide](./shell-configuration.md) - Zsh and Nushell setup
- [Language Runtimes Guide](./language-runtimes.md) - Node.js and Python configuration
- [VS Code Setup Guide](./vscode-setup.md) - Alternative editor configuration
