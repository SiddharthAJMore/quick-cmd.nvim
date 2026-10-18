# quick-cmd.nvim

A small, zero-dependency Neovim plugin for running quick shell commands without leaving your editor.

I built this after running into a simple but annoying problem: I often needed to run a command while working in Neovim, but switching to another terminal or opening a permanent terminal split interrupted my workflow. Neovim's command-line history also wasn't very convenient when I wanted to see and quickly reuse recent commands.

I used AI to help me turn that idea into a working plugin. The result is a floating command prompt with a recent-command history, followed by an interactive terminal that appears in the same window when the command starts.

## Features

- **Floating command prompt:** Open a clean, centered prompt without leaving your current editor layout.
- **Recent command history:** See up to 10 previous commands, with the newest command at the top.
- **Keyboard navigation:** Use the Up and Down arrow keys to move through your history.
- **Interactive terminal:** Press Enter and the prompt turns into a terminal running your command.
- **Simple cleanup:** Press Esc to close the prompt or terminal window.
- **Zero dependencies:** Built entirely with Neovim's native Lua APIs.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim), add this to your plugin specification:

```lua
{
  "SiddharthAJMore/quick-cmd.nvim",
  event = "VeryLazy",
  opts = {
    keymap = "<leader>cx", -- Default keymap
  },
}
```

## Usage

1. Press `<leader>cx`, or your custom keymap, to open the prompt.
2. Type a shell command, or use the **Up** and **Down** arrow keys to browse your recent commands.
3. Press **Enter** to run the command in the floating terminal.
4. Press **Esc** to close the prompt or terminal.

When you run a command again, it moves to the top of the history instead of creating a duplicate entry. History is kept in memory and is limited to the 10 most recent commands.

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
