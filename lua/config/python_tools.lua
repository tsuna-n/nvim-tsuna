local M = {}

local function project_root()
  local home = vim.fn.expand("$HOME")
  local root = vim.fs.root(0, {
    ".git",
    ".venv",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
  })
  if root == nil or root == home then
    root = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    if root == "" or root == home then
      root = vim.fn.getcwd()
    end
  end
  return root
end

local function auto_install_tools()
  local root = project_root()
  local runner = vim.fn.stdpath("config") .. "/scripts/python-project-runner"

  if vim.fn.executable(runner) ~= 1 then
    vim.notify("Python tools runner is not executable: " .. runner, vim.log.levels.ERROR)
    return
  end

  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  local job = vim.fn.jobstart({ runner, "--install-only", root }, {
    cwd = root,
    term = true,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        local message = exit_code == 0 and "Python tools are ready" or "Python tools installation failed"
        vim.notify(message, level, { title = "AutoInstallTools" })
      end)
    end,
  })

  if job <= 0 then
    vim.cmd.bdelete({ bang = true })
    vim.notify("Unable to start Python tools installer", vim.log.levels.ERROR)
    return
  end

  vim.bo[buf].filetype = "crunner"
  vim.cmd.stopinsert()
end

function M.setup()
  vim.api.nvim_create_user_command("AutoInstallTools", auto_install_tools, {
    desc = "Scan req*.txt files and install them into the project .venv",
  })
end

return M
