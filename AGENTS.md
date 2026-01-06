# AGENTS.md

This file provides guidance for agentic coding assistants working on this Neovim configuration.

## Build/Lint/Test Commands

This is a Neovim configuration directory (not a software project with build/tests).

### Validation & Diagnostics
- Run Neovim LSP diagnostics: Open any `.lua` file and check for diagnostics with `<leader>lt` or `<C-k>`
- LSP servers provide real-time feedback: lua_ls, gopls, golangci_lint_ls, ts_ls, tailwindcss, rust_analyzer, clangd, dartls, tinymist
- Lua type checking is configured in `.luarc.json` with some diagnostics disabled (`param-type-mismatch`, `assign-type-mismatch`)

### Manual Testing
- Source configuration changes: `:source %` or `<leader>s`
- Test keybindings after modifying `lua/core/mapping.lua`
- Test autocmds after modifying `lua/core/autocmd.lua`
- Check startup time: `nvim --startuptime startuptime.log`

## Code Style Guidelines

### Module Structure
- Use module pattern: `local M = {}` at the top, `return M` at the end
- Place reusable functions in `lua/utils/utils.lua`
- Organize configs: `lua/configs/` for plugin/language configs, `lua/core/` for Neovim core settings
- LSP configs in `lsp/` directory, color schemes in `colors/`
- Each directory should have an `init.lua` that loads its submodules

### Imports & APIs
- Import with `require()` (e.g., `require('utils.utils')`)
- Create local shortcuts for frequently used APIs: `local api = vim.api`, `local fn = vim.fn`
- Use `vim.` prefix for all Vim APIs (vim.opt, vim.keymap, vim.cmd, etc.)

### Formatting
- Use tabs for indentation (tabstop=4)
- No enforced auto-formatting; LSP format-on-save is enabled where supported
- Align tables and key-value pairs for readability

### Types
- Runtime: LuaJIT
- Minimal type annotations (use `---@type` comments sparingly)
- Some type checking disabled for flexibility (see `.luarc.json`)

### Naming Conventions
- Functions: `snake_case` (e.g., `git_blame_current_line`, `search_and_replace`)
- Variables: `snake_case`
- Constants: `UPPER_CASE_WITH_UNDERSCORES` (e.g., API shortcuts: `local api = vim.api`)
- Module tables: `M`
- Files: `snake_case.lua`

### Error Handling
- Use `pcall()` for error-prone operations
- Use `assert()` for invariant checking
- Use `vim.notify()` with appropriate log levels: `vim.log.levels.ERROR`, `WARN`, `INFO`
- Handle shell command errors: check `vim.v.shell_error` after `vim.fn.system()`

### Vim API Best Practices
- Prefer `vim.keymap.set()` over `vim.keymap.set()` (they're the same, use the clearer `set()`)
- Always provide `desc` option in keymaps
- Use `vim.api.nvim_create_autocmd()` for autocommands
- Always use augroups for autocmds: `vim.api.nvim_create_augroup('name', { clear = true })`
- Buffer-local options: `vim.bo[bufnr].option` or `vim.opt_local.option`
- Window-local options: `vim.wo[winid].option` or `vim.opt_local.option`

### Autocommands
- Create augroups to prevent duplicate autocmds: `vim.api.nvim_create_augroup('unique_name', { clear = true })`
- Use the `group` parameter in autocmd definitions
- Clear autocmds when necessary: `vim.api.nvim_clear_autocmds({ group = 'name', buffer = buf })`

### Comments
- Use `--` for comments
- Section headers with separators: `-- ========================`
- Keep comments concise and purposeful
- Explain non-obvious logic (e.g., complex string patterns, API quirks)

### Keymap Patterns
- Leader key is `<Space>`
- Use descriptive names: `{ desc = "Git Blame current line" }`
- Group related keymaps by common prefixes
- Test keymaps after defining them

### User Commands
- Define with `vim.api.nvim_create_user_command("CommandName", function(opts) end, { desc = "..." })`
- Handle arguments via `opts.args` and `opts.bang`
- Provide completion with the `complete` parameter

### Configuration Loading
- Entry point: `init.lua`
- Core configs loaded in `lua/core/init.lua` on startup
- Plugin/LSP configs loaded in `lua/configs/init.lua` when entering buffers
- Lazy load plugins with `vim.defer_fn()` when needed (see `lua/configs/pack.lua`)

### LSP Configuration
- Enable servers in `lua/configs/lsp.lua` with `vim.lsp.enable()`
- Server-specific configs in `lsp/*.lua` files
- Check server capabilities before enabling features: `if client:supports_method('method_name') then`
- LSP features are enabled on `LspAttach` autocmd

### Utility Functions
- Add to `lua/utils/utils.lua` following existing patterns
- Return values from functions when used by keymaps
- Use vim.schedule() for UI updates after async operations

### Performance Considerations
- Disable unused built-in plugins in `lua/core/init.lua`
- Use `vim.defer_fn()` for non-critical plugin initialization
- Avoid heavy computations in autocmds
- Use `once = true` for one-time autocmds
