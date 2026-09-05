-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- IDE-style shortcuts -------------------------------------------------------
-- LazyVim's original <leader> mappings remain available.  This layer makes
-- the most common editor actions accessible without first learning Vim keys.

-- File and editor actions
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save File" })
map("n", "<C-S-s>", function()
  vim.ui.input({ prompt = "Save as: ", default = vim.fn.expand("%:p") }, function(path)
    if path and path ~= "" then
      vim.cmd.saveas(vim.fn.fnameescape(path))
    end
  end)
end, { desc = "Save As" })
map("n", "<C-n>", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<C-p>", LazyVim.pick("files"), { desc = "Quick Open File" })
local function command_palette()
  Snacks.picker.commands()
end
map("n", "<C-S-p>", command_palette, { desc = "Command Palette" })
map("n", "<F1>", command_palette, { desc = "Command Palette" })
map("n", "<C-b>", function()
  require("config.explorer").open()
end, { desc = "Toggle File Explorer" })
map("n", "<C-S-e>", function()
  local explorer = Snacks.explorer.reveal({ file = vim.api.nvim_buf_get_name(0) })
  if explorer then
    explorer:focus("list")
  end
end, { desc = "Focus Current File in Explorer" })

-- Editing: select all, undo/redo, and system clipboard
-- <C-g> converts Visual mode to Select mode, so typing replaces the selection
-- like it does in graphical editors.
map("n", "<C-a>", "ggVG<C-g>", { desc = "Select All" })
map("i", "<C-a>", "<esc>ggVG<C-g>", { desc = "Select All" })
map({ "x", "s" }, "<C-a>", "<esc>ggVG<C-g>", { desc = "Select All" })
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
-- Finish the current undo block before starting the next word. Re-apply this
-- as a buffer-local map on InsertEnter so filetype/completion maps cannot
-- silently replace the word-by-word undo boundary.
local word_undo_rhs = "<C-g>u<Space>"
local word_undo_opts = { desc = "Undo Break Before Word" }
map("i", "<Space>", word_undo_rhs, word_undo_opts)

local undo_group = vim.api.nvim_create_augroup("ide_word_undo", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
  group = undo_group,
  desc = "Keep word-by-word undo active in every editable buffer",
  callback = function(event)
    if vim.bo[event.buf].buftype == "" then
      map("i", "<Space>", word_undo_rhs, {
        buffer = event.buf,
        desc = word_undo_opts.desc,
      })
    end
  end,
})
map("x", "<C-c>", '"+y', { desc = "Copy" })
map("x", "<C-x>", '"+d', { desc = "Cut" })
map("n", "<C-v>", '"+p', { desc = "Paste" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste" })
map("x", "<C-v>", '"+P', { desc = "Paste" })
map("s", "<C-c>", '<C-g>"+y', { desc = "Copy" })
map("s", "<C-x>", '<C-g>"+d', { desc = "Cut" })
map("s", "<C-v>", '<C-g>"+P', { desc = "Paste" })

-- Search and navigation
map("n", "<C-f>", "/", { desc = "Find in File" })
map("i", "<C-f>", "<esc>/", { desc = "Find in File" })
map("n", "<C-S-f>", LazyVim.pick("live_grep"), { desc = "Find in Project" })
map("n", "<C-S-h>", "<cmd>GrugFar<cr>", { desc = "Replace in Project" })
map("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next Editor" })
map("n", "<C-S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous Editor" })
map("n", "<C-w>", function()
  Snacks.bufdelete()
end, { desc = "Close Editor" })
map("n", "<C-A-Left>", "<C-o>", { desc = "Navigate Back" })
map("n", "<C-A-Right>", "<C-i>", { desc = "Navigate Forward" })
map("n", "<A-Left>", "<C-o>", { desc = "Navigate Back" })
map("n", "<A-Right>", "<C-i>", { desc = "Navigate Forward" })

-- Code editing
-- Most terminals send Ctrl+/ as Ctrl+_, so support both spellings.
for _, key in ipairs({ "<C-/>", "<C-_>" }) do
  map("n", key, "gcc", { desc = "Toggle Comment", remap = true })
  map("x", key, "gc", { desc = "Toggle Comment", remap = true })
end
map({ "n", "x" }, "<A-S-f>", function()
  LazyVim.format({ force = true })
end, { desc = "Format Document" })
map({ "n", "x" }, "<C-.>", vim.lsp.buf.code_action, { desc = "Quick Fix / Code Action" })
map("n", "<F2>", function()
  vim.cmd("IncRename " .. vim.fn.expand("<cword>"))
end, { desc = "Rename Symbol with Preview" })
map("n", "<F12>", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "<S-F12>", vim.lsp.buf.references, { desc = "Find References" })
map("n", "<F8>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Problem" })
map("n", "<S-F8>", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous Problem" })

-- Integrated terminal (Ctrl+` as in VS Code)
map({ "n", "t" }, "<C-`>", function()
  Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle Integrated Terminal" })

-- Terminal at the current file's directory (F4). For python projects the
-- project's .venv/bin is prepended to PATH, so `python` / `pip` inside the
-- terminal use the project venv automatically.
local function file_dir_venv_env()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= "" and vim.fn.fnamemodify(file, ":h") or vim.fn.getcwd()
  if dir == "" or vim.fn.isdirectory(dir) ~= 1 then
    dir = vim.fn.getcwd()
  end
  local env = nil
  local home = vim.fn.expand("$HOME")
  local root = vim.fs.root(0, { ".venv", "pyproject.toml", ".git" })
  if root and root ~= home and vim.fn.isdirectory(root .. "/.venv/bin") == 1 then
    env = { PATH = root .. "/.venv/bin:" .. vim.env.PATH }
  end
  return dir, env
end
map({ "n", "t" }, "<F4>", function()
  local dir, env = file_dir_venv_env()
  Snacks.terminal.toggle(nil, { cwd = dir, env = env })
end, { desc = "Toggle Terminal at File Directory (venv on PATH)" })
map("t", "<esc><esc>", [[<C-\><C-n>]], { desc = "Leave Terminal Mode" })
map("t", "<C-S-v>", [[<C-\><C-n>"+pi]], { desc = "Paste Clipboard in Terminal" })
