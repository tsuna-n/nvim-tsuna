return {
  -- Familiar debugger shortcut while retaining LazyVim's complete <leader>d
  -- family for stepping, evaluation, REPL, and session control.
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
    },
  },

  -- Python/PHP/Rust adapters are contributed by their LazyVim language
  -- extras. Add Jest because the local Moodle project uses it.
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "npm test --",
          cwd = function(path)
            return vim.fs.root(path, "package.json") or vim.fn.getcwd()
          end,
        },
      },
      discovery = { concurrent = 1 },
      output = { open_on_run = true },
      summary = { animated = false },
    },
  },

  -- Shell files get both deterministic formatting and diagnostics. The tools
  -- are installed lazily by mason-tool-installer only for shell projects.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        zsh = { "shellcheck" },
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      preview_config = { border = "rounded" },
    },
  },
}
