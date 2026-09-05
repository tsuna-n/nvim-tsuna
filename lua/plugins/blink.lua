return {
  "saghen/blink.cmp",
  init = function()
    -- ลบ default snippet mapping ของ Neovim ที่ขัดแย้งกับ blink.cmp Tab
    vim.schedule(function()
      pcall(vim.keymap.del, { "i", "s" }, "<Tab>")
      pcall(vim.keymap.del, { "i", "s" }, "<S-Tab>")
    end)
  end,
  opts = function(_, opts)
    opts.keymap = opts.keymap or {}

    -- ใช้ preset super-tab แล้ว override <Tab> ให้ accept suggestion ก่อน
    opts.keymap.preset = "super-tab"
    opts.keymap["<Tab>"] = {
      function(cmp)
        if cmp.is_menu_visible() then
          return cmp.select_and_accept()
        end
        if cmp.snippet_active() then
          return cmp.snippet_forward()
        end
        return false
      end,
      "fallback",
    }

    -- Shift+Tab ถอยกลับ snippet
    opts.keymap["<S-Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.snippet_backward()
        end
        return false
      end,
      "fallback",
    }

    -- Enter ก็ accept เหมือนกัน
    opts.keymap["<CR>"] = { "accept", "fallback" }

    -- แสดงรายการแรก highlighted ไว้ก่อน เหมือน VSCode
    opts.completion = opts.completion or {}
    opts.completion.list = opts.completion.list or {}
    opts.completion.list.selection = { preselect = true, auto_insert = true }

    -- Helpful IDE hints without keeping extra completion processes alive.
    opts.completion.documentation = vim.tbl_deep_extend("force", opts.completion.documentation or {}, {
      auto_show = true,
      auto_show_delay_ms = 350,
      window = { border = "rounded" },
    })
    opts.completion.menu = vim.tbl_deep_extend("force", opts.completion.menu or {}, {
      max_height = 10,
      border = "rounded",
    })
    opts.completion.ghost_text = { enabled = false }

    opts.signature = vim.tbl_deep_extend("force", opts.signature or {}, {
      enabled = true,
      window = {
        border = "rounded",
        treesitter_highlighting = false,
      },
    })

    opts.cmdline = { enabled = false }
    opts.fuzzy = { implementation = "prefer_rust" }
    opts.sources = opts.sources or {}
    opts.sources.providers = opts.sources.providers or {}
    opts.sources.providers.buffer = vim.tbl_deep_extend("force", opts.sources.providers.buffer or {}, {
      min_keyword_length = 3,
      max_items = 20,
    })
  end,
}
