local M = {}

-- Keep the explorer anchored to the path used to launch this Neovim session.
-- A file opened from inside the launch directory keeps that directory as the
-- root; an explicitly opened directory (or an external file) becomes the root.
local launch_cwd = vim.fs.normalize(vim.fn.getcwd())

local function is_inside(path, directory)
  return path == directory or path:sub(1, #directory + 1) == directory .. "/"
end

local function detect_launch_root()
  local args = vim.fn.argv()
  local first = args[1]
  if not first or first == "" then
    return launch_cwd
  end

  local target = vim.fs.normalize(vim.fn.fnamemodify(first, ":p"))
  if vim.fn.isdirectory(target) == 1 then
    return target
  end

  if is_inside(target, launch_cwd) then
    return launch_cwd
  end

  return vim.fs.dirname(target) or launch_cwd
end

local launch_root = detect_launch_root()

function M.root()
  return launch_root
end

function M.open(opts)
  return Snacks.explorer(vim.tbl_deep_extend("force", {
    cwd = launch_root,
  }, opts or {}))
end

return M
