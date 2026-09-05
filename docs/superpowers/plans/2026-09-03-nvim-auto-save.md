# Neovim Auto-Save Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure conservative auto-saving in Neovim using `okuuva/auto-save.nvim` so that buffers automatically save on mode or focus changes without interrupting typing.

**Architecture:** Add a new LazyVim plugin configuration file at `~/.config/nvim/lua/plugins/auto-save.lua`. It configures event triggers (`InsertLeave`, `BufLeave`, `FocusLost`), ignores non-file and git buffers, and maps `<leader>ua` for manual toggle.

**Tech Stack:** Lua, Neovim (v0.10+ / LazyVim), lazy.nvim, okuuva/auto-save.nvim.

## Global Constraints
- Target configuration path: `/home/tsuna/.config/nvim/lua/plugins/auto-save.lua`
- Conservative mode: No `TextChanged` event; only save on exit from insert mode or focus/buffer switch
- Safety checks: Ensure non-modifiable, read-only, special buftypes (terminal, prompt, etc.), and gitcommit filetypes are not auto-saved
- Keymap: `<leader>ua` mapped to `:ASToggle<cr>` with description "Toggle Auto-save"

---

### Task 1: Create Auto-Save Plugin Specification

**Files:**
- Create: `/home/tsuna/.config/nvim/lua/plugins/auto-save.lua`

**Interfaces:**
- Consumes: `LazyVim` plugin loader (`lazy.nvim`), `okuuva/auto-save.nvim`
- Produces: Auto-save configuration table loaded by `lazy.nvim`

- [ ] **Step 1: Write plugin configuration file**

Write `/home/tsuna/.config/nvim/lua/plugins/auto-save.lua`:
```lua
return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "BufLeave", "FocusLost" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        -- Do not save special buffers (e.g. terminal, quickfix, snacks explorer)
        if vim.bo[buf].buftype ~= "" then
          return false
        end
        -- Do not save unmodifiable or read-only buffers
        if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
          return false
        end
        -- Exclude git commit and git rebase buffers
        local ft = vim.bo[buf].filetype
        if ft == "gitcommit" or ft == "gitrebase" then
          return false
        end
        return true
      end,
      write_all_buffers = false,
      debounce_delay = 135,
    },
    keys = {
      { "<leader>ua", "<cmd>ASToggle<cr>", desc = "Toggle Auto-save" },
    },
  },
}
```

- [ ] **Step 2: Verify syntax of the Lua file**

Run: `luac -p /home/tsuna/.config/nvim/lua/plugins/auto-save.lua || nvim --headless "+luafile /home/tsuna/.config/nvim/lua/plugins/auto-save.lua" +q`
Expected: Exits with 0 without syntax errors.

---

### Task 2: Verify Neovim Loads the Plugin Configuration

**Files:**
- Test: Verification via Neovim headless mode

**Interfaces:**
- Consumes: `/home/tsuna/.config/nvim/lua/plugins/auto-save.lua`
- Produces: Verified plugin registration and startup health

- [ ] **Step 1: Execute Neovim headless check**

Run: `nvim --headless "+Lazy! sync" +q` or `nvim --headless "+lua require('lazy').load({ plugins = { 'auto-save.nvim' } })" +q`
Expected: Loads without error and installs/syncs `auto-save.nvim`.

- [ ] **Step 2: Verify auto-save trigger functionality with automated script**

Run a headless script that opens a buffer, modifies text, triggers `InsertLeave`, and asserts the file is written.
Expected: File on disk reflects buffer content.
