-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

require("config.commands")
require("config.python_tools").setup()

-- Keep a narrow project tree visible on regular interactive starts. This file
-- itself is loaded on VeryLazy, so scheduling directly avoids missing that
-- event while still keeping the explorer out of headless and small sessions.
local function open_startup_explorer()
  if #vim.api.nvim_list_uis() == 0 or vim.o.diff then
    return
  end
  local excluded = { lazy = true, mason = true, help = true, qf = true }
  if excluded[vim.bo.filetype] then
    return
  end

  local first_arg = vim.fn.argv(0)
  local start_in_tree = vim.fn.argc() == 0 or (first_arg ~= "" and vim.fn.isdirectory(first_arg) == 1)
  local explorer = Snacks.picker.get({ source = "explorer" })[1] or require("config.explorer").open({ enter = false })
  vim.schedule(function()
    if start_in_tree and explorer then
      explorer:focus("list")
    elseif explorer and explorer.main and vim.api.nvim_win_is_valid(explorer.main) then
      vim.api.nvim_set_current_win(explorer.main)
    end
  end)
end

-- Open the explorer on the next UI tick; retry a few times in case lazy.nvim
-- is still loading plugins when this file runs. Errors are surfaced instead of
-- failing silently.
local attempts = 0
local function try_open_explorer()
  attempts = attempts + 1
  local ok, err = pcall(open_startup_explorer)
  if ok then
    return
  end
  if attempts < 10 and tostring(err):find("snacks", 1, true) then
    vim.defer_fn(try_open_explorer, 200)
  else
    Snacks.notify.error("Could not open file explorer:\n" .. tostring(err), { title = "Explorer" })
  end
end
vim.schedule(try_open_explorer)

local runner_group = vim.api.nvim_create_augroup("ide_code_runner", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = runner_group,
  pattern = "crunner",
  desc = "Make the full-screen code output easy to close",
  callback = function(event)
    local function close_output()
      if #vim.api.nvim_list_tabpages() > 1 then
        vim.cmd.tabclose()
      else
        vim.cmd.bdelete({ bang = true })
      end
    end

    vim.keymap.set("n", "q", close_output, { buffer = event.buf, desc = "Close Output and Return to Code" })
    vim.keymap.set("n", "<esc>", close_output, { buffer = event.buf, desc = "Close Output and Return to Code" })
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], {
      buffer = event.buf,
      desc = "Leave Terminal Input Mode",
    })
  end,
})
