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
