return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Keep inline messages quiet, but retain signs and underlines for both
      -- errors and warnings so actionable problems are never hidden.
      diagnostics = {
        virtual_text = {
          severity = vim.diagnostic.severity.ERROR,
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
        signs = {
          severity = { min = vim.diagnostic.severity.WARN },
        },
        underline = {
          severity = { min = vim.diagnostic.severity.WARN },
        },
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
      },
      -- Parameter/type hints save round trips to hover while writing code.
      -- They remain toggleable at any time with <leader>uh.
      inlay_hints = { enabled = true },
      folds = { enabled = false },
      servers = {
        intelephense = {
          settings = {
            intelephense = {
              telemetry = { enabled = false },
              files = { maxSize = 5000000 },
            },
          },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      max_concurrent_installers = 2,
      ui = { border = "rounded" },
      -- Keep the core toolchain ready instead of waiting for the first file of
      -- each type. Less common language tools remain project-conditional in
      -- mason-tool-installer.
      ensure_installed = {
        "bash-language-server",
        "clangd",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "eslint-lsp",
        "shellcheck",
        "taplo",
        "yaml-language-server",
      },
    },
  },
}
