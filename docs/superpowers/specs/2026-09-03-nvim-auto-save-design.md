# Design Spec: Neovim Auto-Save Configuration

**Date**: 2026-09-03
**Status**: Approved
**Target**: `~/.config/nvim/lua/plugins/auto-save.lua`

## 1. Overview
Configure conservative auto-saving in Neovim using the `okuuva/auto-save.nvim` plugin within a LazyVim environment. This ensures user edits are saved automatically on mode or focus changes without intruding during active typing.

## 2. Goals & Constraints
- **Goal**: Automatically persist buffer changes to disk without requiring manual `:w` / `<C-s>`.
- **Constraint (Conservative behavior)**: Do not save in the middle of typing (`TextChanged` disabled). Only trigger save on `InsertLeave`, `BufLeave`, and `FocusLost`.
- **Constraint (Buffer safety)**: Never attempt to save non-file buffers (terminals, Snack explorer, quickfix, help) or unmodifiable / read-only buffers.
- **Convenience**: Provide a toggle keymap `<leader>ua` adhering to LazyVim's UI toggle group to easily enable/disable auto-save when needed.

## 3. Architecture & Components

### 3.1 Plugin Specification
- **Plugin**: `okuuva/auto-save.nvim`
- **File**: `~/.config/nvim/lua/plugins/auto-save.lua`
- **Lazy Loading**: Loaded on events `InsertLeave`, `BufLeave`, `FocusLost` or command `ASToggle`.

### 3.2 Trigger Configuration
- `immediate_save`: `{ "BufLeave", "FocusLost" }`
- `defer_save`: `{ "InsertLeave" }`
- `cancel_deferred_save`: `{ "InsertEnter" }`
- `debounce_delay`: `135` ms (brief debounce to allow mode transitions cleanly)

### 3.3 Safety Filter (`condition`)
The `condition` callback checks:
1. `vim.bo[buf].buftype == ""` (regular file buffers only)
2. `vim.bo[buf].modifiable` is `true`
3. `vim.bo[buf].readonly` is `false`
4. Exclude git-related filetypes (`gitcommit`, `gitrebase`) where auto-saving before finishing the message is undesired.

### 3.4 Keymaps
- `<leader>ua`: `<cmd>ASToggle<cr>` (Toggle Auto-save, description: "Toggle Auto-save")

## 4. Verification & Testing
1. Syntax validation: Run `nvim --headless "+luafile ~/.config/nvim/lua/plugins/auto-save.lua" +q` or `nvim --headless "+Lazy! check" +q` to ensure valid Lua syntax.
2. Functional verification:
   - Open a temporary file in nvim.
   - Enter insert mode, type text, exit insert mode (`<Esc>`). Verify file modification timestamp updates.
   - Switch windows / focus lost. Verify buffer is written.
   - Verify toggle `<leader>ua` / `:ASToggle` enables and disables auto-saving properly.
