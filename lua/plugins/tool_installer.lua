local function project_uses(extensions, markers)
  local file = vim.api.nvim_buf_get_name(0)
  local extension = vim.fn.fnamemodify(file, ":e"):lower()

  if vim.tbl_contains(extensions, extension) then
    return true
  end

  local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
  return vim.fs.root(start, markers) ~= nil
end

local project = {
  python = function()
    return project_uses({ "py", "pyi" }, {
      "pyproject.toml",
      "requirements.txt",
      "setup.py",
      "setup.cfg",
      "Pipfile",
    })
  end,
  javascript = function()
    return project_uses({ "js", "jsx", "ts", "tsx", "mjs", "cjs" }, {
      "package.json",
      "deno.json",
      "deno.jsonc",
    })
  end,
  php = function()
    return project_uses({ "php" }, { "composer.json" })
  end,
  json = function()
    return project_uses({ "json", "jsonc" }, { ".prettierrc", ".prettierrc.json" })
  end,
  lua = function()
    return project_uses({ "lua" }, { ".luarc.json", ".luarc.jsonc", "stylua.toml", ".stylua.toml" })
  end,
  shell = function()
    return project_uses({ "sh", "bash", "zsh" }, { ".shellcheckrc" })
  end,
  go = function()
    return project_uses({ "go" }, { "go.mod", "go.work" })
  end,
  rust = function()
    return project_uses({ "rs" }, { "Cargo.toml", "rust-project.json" })
  end,
  cpp = function()
    return project_uses({ "c", "h", "cc", "cpp", "cxx", "hpp" }, {
      "compile_commands.json",
      "CMakeLists.txt",
    })
  end,
  java = function()
    return project_uses({ "java" }, { "pom.xml", "build.gradle", "build.gradle.kts" })
  end,
  ruby = function()
    return project_uses({ "rb" }, { "Gemfile", ".ruby-version" })
  end,
}

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    opts = {
      ensure_installed = {
        { "pyright", condition = project.python },
        { "ruff", condition = project.python },
        { "vtsls", condition = project.javascript },
        { "prettier", condition = project.javascript },
        { "eslint-lsp", condition = project.javascript },
        { "json-lsp", condition = project.json },
        { "intelephense", condition = project.php },
        { "lua-language-server", condition = project.lua },
        { "stylua", condition = project.lua },
        { "bash-language-server", condition = project.shell },
        { "shellcheck", condition = project.shell },
        { "shfmt", condition = project.shell },
        { "gopls", condition = project.go },
        { "rust-analyzer", condition = project.rust },
        { "clangd", condition = project.cpp },
        { "jdtls", condition = project.java },
        { "ruby-lsp", condition = project.ruby },
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 1000,
    },
  },
}
