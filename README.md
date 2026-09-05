# Neovim Dev Setup

Fast LazyVim-based configuration for PHP, JavaScript/TypeScript, Python,
Rust, C/C++, JSON, YAML, Docker, Lua, shell, and common web formats. It includes
LSP completion, format-on-save, linting, project search/replace, Git hunk tools,
tests, and debugging with automatic project-local adapter discovery.

## Install

```sh
git clone https://github.com/tsuna-n/nvim-tsuna.git
cd nvim-tsuna
./install.sh
```

The installer downloads the latest `main` branch into
`${XDG_CONFIG_HOME:-$HOME/.config}/nvim`. If a Neovim configuration already
exists, it is moved to a timestamped backup before the new configuration takes
its place. The installed directory remains a Git checkout connected to this
repository.

## Start here

- `Ctrl+P` find a file
- `Ctrl+Shift+F` search the project
- `Ctrl+Shift+H` search and replace across the project
- `Ctrl+B` toggle the file explorer
- `Ctrl+Shift+E` reveal the current file in the explorer
- `Ctrl+\`` toggle the terminal
- `F5` run the current file/project
- `F12` go to definition
- `F2` rename a symbol with a live preview
- `F9` toggle a debugger breakpoint
- `Ctrl+.` code action
- `Alt+Shift+F` format
- `Space ?` contextual key help
- `Space t r` run the nearest test
- `Space d c` start or continue debugging
- `Space g g` open LazyGit for the project
- `Space x x` open project diagnostics
- `:KeyHelp` Thai shortcut guide

Inside the explorer, use `Enter`/arrow keys to open folders and files,
`Ctrl+N` to create a file, `Ctrl+Shift+N` to create a folder, `F2` to rename,
`Delete` to move to trash, `Ctrl+C/X/V` to copy/cut/paste, `Space` for multiple
selection, `Ctrl+F` to filter, `F5` to refresh, and `Esc` to return to the editor.
The explorer root stays anchored to the path used to launch the current Neovim
session. For example, `nvim .` uses the current directory, `nvim /path/project`
uses that directory, and opening a file outside the current directory uses the
file's parent directory.

Plugins update manually with `:Lazy sync`, so Neovim does not perform update
checks in the background. Language servers are started only for matching file
types.
