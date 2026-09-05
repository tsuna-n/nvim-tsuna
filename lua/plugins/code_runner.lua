return {
  {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "RunCodePATH" },
    keys = {
      { "<F5>", "<esc><cmd>RunCode<cr>", mode = { "n", "i" }, desc = "Run Code (VSCode Style)" },
      { "<F6>", "<esc><cmd>RunCodePATH<cr>", mode = { "n", "i" }, desc = "Run Code (python from PATH)" },
      { "<leader>rr", "<cmd>RunCode<cr>", desc = "Run Code" },
      { "<leader>rf", "<cmd>RunFile<cr>", desc = "Run File" },
      { "<leader>rc", "<cmd>RunClose<cr>", desc = "Close Runner Window" },
      { "<leader>rp", "<cmd>RunProject<cr>", desc = "Run Project" },
      { "<leader>r", ":<C-u>RunCode<CR>", mode = "v", desc = "Run Code" },
    },
    config = function(_, opts)
      local use_path_python = false

      -- Root detection: also stop at .venv, and never treat $HOME itself as
      -- the project root (a stray ~/.git or ~/.venv would hijack every file
      -- under the home directory).
      local function get_project_root()
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

      local function find_path_python()
        local path_python = vim.fn.exepath("python3")
        if path_python == "" then
          path_python = vim.fn.exepath("python")
        end
        return path_python
      end

      -- <F6> / :RunCodePATH -> run python straight from PATH (ignores .venv).
      -- Use this when <F5> fails or the project has no working .venv.
      vim.api.nvim_create_user_command("RunCodePATH", function()
        use_path_python = true
        local ok, err = pcall(vim.cmd, "RunCode")
        use_path_python = false
        if not ok then
          vim.notify("RunCodePATH failed: " .. tostring(err), vim.log.levels.ERROR)
        end
      end, { desc = "Run code using python from PATH (fallback when .venv fails)" })

      require("code_runner").setup(vim.tbl_deep_extend("force", opts, {
        filetype = {
          python = function()
            local project_root = get_project_root()

            if use_path_python then
              local path_python = find_path_python()
              if path_python == "" then
                vim.notify("No python found in PATH", vim.log.levels.ERROR)
                return "false"
              end
              return "cd $dir && " .. vim.fn.shellescape(path_python) .. " -u $fileName"
            end

            -- Default (<F5>): put the project's .venv/bin first on PATH so
            -- `python` resolves to the venv; if the venv is missing/broken the
            -- shell automatically falls back to whatever python is on PATH.
            local venv_bin = project_root .. "/.venv/bin"
            local venv_python = venv_bin .. "/python"
            if vim.fn.executable(venv_python) == 1 then
              return "cd $dir && export PATH="
                .. vim.fn.shellescape(venv_bin)
                .. ":$PATH && python -u $fileName"
            end

            local path_python = find_path_python()
            return "cd $dir && " .. vim.fn.shellescape(path_python ~= "" and path_python or "python3") .. " -u $fileName"
          end,
        },
      }))
    end,
    opts = {
      -- A dedicated tab hides the source while the program is running, leaving
      -- only stdout/stderr visible. Press q or Esc to return to the source tab.
      mode = "tab",
      focus = true,
      startinsert = false,
      term = {
        position = "botright",
        size = 12,
      },
      float = {
        border = "rounded",
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
        border_hl = "FloatBorder",
        float_hl = "Normal",
        blend = 0,
      },
      before_run_filetype = function()
        vim.cmd("silent! write")
      end,
      filetype = {
        javascript = "node $fileName",
        typescript = "npx ts-node $fileName",
        c = "cd $dir && gcc -O2 $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        cpp = "cd $dir && g++ -O2 $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt",
        rust = "cd $dir && cargo run",
        go = "cd $dir && go run $fileName",
        sh = "bash $fileName",
        bash = "bash $fileName",
        zsh = "zsh $fileName",
        lua = "nvim -l $fileName",
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        php = "php $fileName",
        ruby = "ruby $fileName",
      },
    },
  },

  -- Register WhichKey icon & group label for <leader>r
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>r", group = "code runner", icon = "󰐊 " },
      },
    },
  },
}
