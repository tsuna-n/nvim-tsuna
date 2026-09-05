local explorer_clipboard = { paths = {}, cut = false }

local function explorer_format(item, picker)
  if item.dir and not item.parent then
    local path = vim.fn.fnamemodify(item.file, ":~"):gsub("/$", "")
    return { { "  " .. path .. "/", "SnacksPickerRoot" } }
  end

  local ret = {}
  if item.parent then
    vim.list_extend(ret, Snacks.picker.format.tree(item, picker))
  end

  local hidden, ignored = false, false
  local node = item
  while node do
    hidden = hidden or node.hidden or false
    ignored = ignored or node.ignored or false
    node = node.parent
  end

  local name = vim.fn.fnamemodify(item.file, ":t")
  local text_hl = item.dir and "SnacksPickerDirectory" or "SnacksPickerFile"
  text_hl = ignored and "SnacksPickerPathIgnored" or hidden and "SnacksPickerPathHidden" or item.filename_hl or text_hl

  if item.dir then
    ret[#ret + 1] = { item.open and "▾ " or "▸ ", "SnacksPickerTree" }
  else
    local icon, icon_hl = Snacks.util.icon(item.file, "file", { fallback = picker.opts.icons.files })
    icon = Snacks.picker.util.align(icon, picker.opts.formatters.file.icon_width or 2)
    ret[#ret + 1] = { icon, icon_hl, virtual = true }
  end
  ret[#ret + 1] = { name, text_hl, field = "file" }
  return ret
end

local function selected_paths(picker)
  return vim.tbl_map(Snacks.picker.util.path, picker:selected({ fallback = true }))
end

local function remember_files(picker, cut)
  local paths = selected_paths(picker)
  if #paths == 0 then
    return
  end
  explorer_clipboard = { paths = paths, cut = cut }
  vim.fn.setreg("+", table.concat(paths, "\n"), "l")
  picker.list:set_selected()
  Snacks.notify.info((cut and "Cut " or "Copied ") .. #paths .. (cut and " item(s)" or " item(s)"))
end

local function paste_files(picker)
  local paths = explorer_clipboard.paths
  if #paths == 0 then
    return Snacks.notify.warn("Copy or cut a file first")
  end

  local Tree = require("snacks.explorer.tree")
  local Actions = require("snacks.explorer.actions")
  local target = picker:dir()
  local changed = false

  if explorer_clipboard.cut then
    for _, from in ipairs(paths) do
      local to = vim.fs.joinpath(target, vim.fs.basename(from))
      if from ~= to then
        if vim.uv.fs_stat(to) then
          Snacks.notify.warn("Already exists: " .. to)
        else
          Snacks.rename.rename_file({ from = from, to = to })
          Tree:refresh(vim.fs.dirname(from))
          changed = true
        end
      end
    end
    if changed then
      explorer_clipboard = { paths = {}, cut = false }
    end
  else
    Snacks.picker.util.copy(paths, target)
    changed = true
  end

  if changed then
    Tree:refresh(target)
    Tree:open(target)
    Actions.update(picker, { target = target })
    Snacks.notify.info("Pasted into " .. vim.fn.fnamemodify(target, ":~:."))
  end
end

local function create_item(picker, directory)
  Snacks.input({ prompt = directory and "New folder name" or "New file name" }, function(value)
    value = value and vim.trim(value) or ""
    if value == "" then
      return
    end

    local Tree = require("snacks.explorer.tree")
    local Actions = require("snacks.explorer.actions")
    local path = vim.fs.joinpath(picker:dir(), value)
    if vim.uv.fs_stat(path) then
      return Snacks.notify.warn("Already exists: " .. path)
    end

    if directory then
      vim.fn.mkdir(path, "p")
    else
      vim.fn.mkdir(vim.fs.dirname(path), "p")
      local file, err = io.open(path, "w")
      if not file then
        return Snacks.notify.error(err or "Could not create file")
      end
      file:close()
    end

    Tree:open(vim.fs.dirname(path))
    Tree:refresh(vim.fs.dirname(path))
    Actions.update(picker, { target = path })
  end)
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      show_end_of_buffer = false,
      integrations = {
        gitsigns = true,
        mason = true,
        native_lsp = { enabled = true },
        noice = true,
        notify = true,
        snacks = true,
        treesitter = true,
        which_key = true,
      },
      custom_highlights = function(colors)
        return {
          Normal = { fg = colors.text, bg = "NONE" },
          NormalNC = { fg = colors.text, bg = "NONE" },
          NormalFloat = { fg = colors.text, bg = colors.mantle },
          SignColumn = { bg = "NONE" },
          LineNr = { fg = colors.surface1, bg = "NONE" },
          CursorLine = { bg = colors.surface0 },
          CursorLineNr = { fg = colors.lavender, bg = colors.surface0, bold = true },
          WinSeparator = { fg = colors.surface0, bg = "NONE" },
          FloatBorder = { fg = colors.surface1, bg = colors.mantle },
          Visual = { bg = colors.surface1 },

          CleanHeader = { fg = colors.text, bg = colors.mantle, bold = true },
          CleanHeaderFile = { fg = colors.text, bg = colors.mantle },
          CleanHeaderAccent = { fg = colors.lavender, bg = colors.mantle },
          CleanHeaderMuted = { fg = colors.overlay0, bg = colors.mantle },

          SnacksPickerList = { bg = "NONE" },
          SnacksPickerListCursorLine = { bg = colors.surface0 },
          SnacksPickerInput = { fg = colors.text, bg = colors.mantle },
          SnacksPickerBorder = { fg = colors.surface0, bg = "NONE" },
          SnacksPickerTitle = { fg = colors.lavender, bg = "NONE", bold = true },
          SnacksPickerRoot = { fg = colors.lavender, bg = "NONE", italic = true },
          SnacksPickerSelectionBar = { fg = colors.lavender, bg = "NONE" },
          SnacksPickerDirectory = { fg = colors.text },
          SnacksPickerFile = { fg = colors.text },
          SnacksPickerTree = { fg = colors.surface2, bg = "NONE" },
          SnacksPickerDir = { fg = colors.overlay1 },
          SnacksPickerPathHidden = { fg = colors.surface2 },
        }
      end,
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      -- Smooth scrolling is pleasant but costs redraws and timers.
      scroll = { enabled = false },
      -- Claim directory arguments before the dashboard does, so
      -- `nvim project/` behaves like opening a folder in an IDE.
      explorer = { replace_netrw = true },
      picker = {
        sources = {
          files = { hidden = true, ignored = true },
          explorer = {
            hidden = true,
            ignored = true,
            title = "",
            format = explorer_format,
            icons = {
              files = { dir = "▸ ", dir_open = "▾ " },
              tree = { vertical = "  ", middle = "  ", last = "  " },
            },
            actions = {
              vscode_copy = function(picker)
                remember_files(picker, false)
              end,
              vscode_cut = function(picker)
                remember_files(picker, true)
              end,
              vscode_paste = paste_files,
              vscode_new_file = function(picker)
                create_item(picker, false)
              end,
              vscode_new_folder = function(picker)
                create_item(picker, true)
              end,
              vscode_toggle_select = function(picker)
                picker.list:select()
              end,
              vscode_focus_editor = function(picker)
                if picker.main and vim.api.nvim_win_is_valid(picker.main) then
                  vim.api.nvim_set_current_win(picker.main)
                end
              end,
            },
            layout = {
              preset = "sidebar",
              preview = false,
              hidden = { "input" },
              layout = { width = 21, min_width = 19 },
            },
            win = {
              list = {
                wo = {
                  number = true,
                  numberwidth = 1,
                  relativenumber = false,
                  signcolumn = "no",
                  statuscolumn = "%#SnacksPickerSelectionBar#%{v:relnum == 0 ? '▏' : ' '}%*",
                },
                keys = {
                  ["<CR>"] = "confirm",
                  ["<2-LeftMouse>"] = "confirm",
                  ["<Right>"] = "confirm",
                  ["<Left>"] = "explorer_close",
                  ["<Space>"] = "vscode_toggle_select",
                  ["<Esc>"] = "vscode_focus_editor",
                  ["<F2>"] = "explorer_rename",
                  ["<Delete>"] = "explorer_del",
                  ["<C-n>"] = "vscode_new_file",
                  ["<C-S-n>"] = "vscode_new_folder",
                  ["<C-c>"] = { "vscode_copy", mode = { "n", "x" } },
                  ["<C-x>"] = { "vscode_cut", mode = { "n", "x" } },
                  ["<C-v>"] = "vscode_paste",
                  ["<C-f>"] = { "toggle_input", mode = { "n", "i" } },
                  ["<F5>"] = "explorer_update",
                },
              },
            },
          },
          grep = { hidden = true, ignored = true },
        },
      },
      dashboard = {
        enabled = false,
        preset = {
          header = [[
  ███╗   ██╗██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██║   ██║██║████╗ ████║
  ██╔██╗ ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝

       Fast · Focused · Developer Ready
          ]],
        },
      },
      notifier = {
        timeout = 2500,
        style = "compact",
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local base = { fg = "#cdd6f5", bg = "NONE" }
      local muted = { fg = "#7f849d", bg = "NONE" }
      local mode = { fg = "#11111c", bg = "#b4beff", gui = "bold" }
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        globalstatus = true,
        theme = {
          normal = { a = mode, b = base, c = base },
          insert = { a = mode, b = base, c = base },
          visual = { a = mode, b = base, c = base },
          replace = { a = mode, b = base, c = base },
          command = { a = mode, b = base, c = base },
          inactive = { a = muted, b = muted, c = muted },
        },
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { statusline = { "dashboard", "snacks_dashboard" } },
      })
      opts.sections = {
        lualine_a = {
          { "mode", separator = { left = "", right = "" }, padding = 0 },
        },
        lualine_b = { { "branch", icon = "", color = base } },
        lualine_c = {
          { "filetype", icon_only = true, colored = false, padding = { left = 1, right = 0 } },
          { "filename", path = 0, symbols = { modified = " ●", readonly = " ", unnamed = "untitled" } },
        },
        lualine_x = {
          { "diagnostics", color = base, symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } },
        },
        lualine_y = { { "filetype", color = base, icons_enabled = false } },
        lualine_z = { { "location", color = base }, { "progress", color = base } },
      }
      opts.inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      }
      return opts
    end,
  },

  { "akinsho/bufferline.nvim", enabled = false },

  {
    "folke/noice.nvim",
    opts = {
      presets = {
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },
}
