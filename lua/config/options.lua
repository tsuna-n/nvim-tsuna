-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Language servers selected for the languages used in ~/project.
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_ts_lsp = "vtsls"

-- Remote providers are not used by this config; keep them from spawning runtimes.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make Mason tools available before lazy-loaded plugins run their health checks.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

-- Keep UI motion low-cost while retaining the useful Snacks picker/explorer.
vim.g.snacks_animate = false

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.cursorlineopt = "number,line"
opt.signcolumn = "yes:1"
opt.foldcolumn = "0"
opt.colorcolumn = ""
opt.showmode = false
opt.laststatus = 3
opt.showtabline = 2
opt.mouse = "a"
opt.scrolloff = 6
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.pumheight = 10
opt.confirm = true
opt.timeoutlen = 400
opt.updatetime = 250
opt.splitbelow = true
opt.splitright = true
opt.winborder = "rounded"

-- A slim, single-line header like the reference UI. Buffer switching remains
-- available through Ctrl-Tab / Ctrl-Shift-Tab and the file picker.
function _G.clean_nvim_tabline()
  local current = vim.api.nvim_get_current_buf()
  local buffer = vim.bo[current].buftype == "" and current or nil
  if not buffer then
    for _, window in ipairs(vim.api.nvim_list_wins()) do
      local candidate = vim.api.nvim_win_get_buf(window)
      if vim.bo[candidate].buftype == "" and vim.api.nvim_buf_get_name(candidate) ~= "" then
        buffer = candidate
        break
      end
    end
  end

  local name = buffer and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":t") or ""
  if name == "" then
    name = "untitled"
  end
  name = name:gsub("%%", "%%%%")
  return table.concat({
    "%#CleanHeader#  nvim   ",
    "%#CleanHeaderFile#",
    name,
    "%=",
    "%#CleanHeaderAccent#● ",
    "%#CleanHeaderMuted#●  ●  ",
  })
end

opt.tabline = "%!v:lua.clean_nvim_tabline()"
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  vert = "│",
  diff = "╱",
}
