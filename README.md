# Aya's Neovim Configuration

This is a lightweight and fast Neovim configuration, tailored for performance and simplicity.

## 🚀 Startup Time

####

The configuration is optimized for a fast startup time.

```
--- NVIM STARTED ---
clock   self+sourced   self:  sourced script
...
059.368  000.002: --- NVIM STARTED ---
```

The total startup time is approximately **60ms**.

## 📦 Plugins

This configuration uses a minimal set of plugins, managed by `vim.pack.add`.

| Plugin                                                                                | Description                       |
| ------------------------------------------------------------------------------------- | --------------------------------- |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim)                       | A popup for keybindings.          |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | For syntax highlighting and more. |

## 📂 File & Folder Structure

The configuration is structured in a modular way, making it easy to maintain and extend.

```
.
├── .luarc.json
├── init.lua
├── startuptime.log
├── colors
│   └── ayu.lua
├── lsp
│   ├── golangci_lint_ls.lua
│   ├── gopls.lua
│   ├── lua_ls.lua
│   ├── tailwindcss.lua
│   └── ts_ls.lua
└── lua
    ├── configs
    │   ├── init.lua
    │   ├── lsp.lua
    │   ├── pack.lua
    │   ├── treesitter.lua
    │   └── whichkey.lua
    ├── core
    │   ├── autocmd.lua
    │   ├── commands.lua
    │   ├── fold.lua
    │   ├── init.lua
    │   ├── mapping.lua
    │   ├── netrw.lua
    │   ├── option.lua
    │   ├── statusline.lua
    │   └── winbar.lua
    └── utils
        ├── init.lua
        └── utils.lua
```

### Root Directory

- `.luarc.json`: Configuration for the Lua language server.
- `init.lua`: The entry point of the configuration.
- `startuptime.log`: Log file for startup time analysis.

### `colors/`

- `ayu.lua`: The `ayu` colorscheme.

### `lsp/`

- This directory contains the configurations for the different language servers.

## 🔧 LSP Server Installation

```bash
# Go
go install golang.org/x/tools/gopls@latest
go install github.com/nametake/golangci-lint-langserver@latest

# TypeScript/JavaScript
npm install -g typescript typescript-language-server

# Lua (macOS)
brew install lua-language-server

# SQL
go install github.com/sqls-server/sqls@latest
```

### `lua/`

- **`configs/`**: This directory contains the configurations for the plugins and other parts of Neovim.
  - `init.lua`: Loads all the configurations in this directory.
  - `lsp.lua`: LSP configuration.
  - `pack.lua`: Plugin management.
  - `treesitter.lua`: Treesitter configuration.
  - `whichkey.lua`: Which-key configuration.
- **`core/`**: This directory contains the core Neovim configuration.
  - `init.lua`: Loads all the core configurations.
  - `autocmd.lua`: Autocommands.
  - `commands.lua`: Custom commands.
  - `fold.lua`: Folding configuration.
  - `mapping.lua`: Key mappings.
  - `netrw.lua`: Netrw configuration.
  - `option.lua`: Neovim options.
  - `statusline.lua`: Statusline configuration.
  - `winbar.lua`: Winbar configuration.
- **`utils/`**: This directory contains utility functions.
  - `init.lua`: Loads the utility modules.
  - `utils.lua`: Utility functions.
