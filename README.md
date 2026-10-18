A lightweight, zero-dependency Neovim plugin that gives you an interactive floating command prompt with a recent-first history dropdown and seamless live terminal execution.

---
## The Problem

When developing or managing projects inside Neovim, running quick shell commands often feels disjointed. You either have to:
* Leave your current focus to switch to an external terminal emulator,
* Use standard Neovim terminal splits that clutter your workspace, or
* Struggle with clunky command-line input history that doesn't provide a clear, visual overview of your recent commands.

---
## The Solution

**`quick-cmd.nvim`** bridges this gap by providing a modern, modal-style workflow directly inside Neovim. 
1. Press your shortcut key to trigger a clean, centered floating input box.
2. If you have past commands, a **History** window automatically appears right below it, keeping your most recent commands at the very top.
3. Cycle through your history using the arrow keys with live selection highlighting.
4. Hit **Enter**, and watch the window seamlessly morph from an input box into a fully functional, interactive terminal running your command!

---
## Features

* **Floating Modal UI:** Minimalist and centered floating window designed to stay out of your way.
* **Smart History Management:** 
  * Automatically displays a dropdown history list beneath the input box.
  * Orders commands with the **most recent at the top**.
  * Capped neatly at your last **10 commands**.
* **Intuitive Navigation:** Cycle through history using arrow keys with active row highlighting.
* **Live Terminal Transition:** Automatically shifts from the input prompt into an interactive terminal buffer upon execution.
* **Zero Dependencies:** Built entirely using native Neovim Lua APIs.

---
## Installation

If you use [lazy.nvim](https://github.com/folke/lazy.nvim), add the following to your plugin spec:

```lua
{
  "SiddharthAJMore/quick-cmd.nvim",
  event = "VeryLazy",
  opts = {
    keymap = "<leader>cx", -- Default keymap to open the prompt
  },
}
```

---
## Configuration

You can customize the shortcut key by passing an `opts` table into the `setup()` function (or via your plugin manager configuration block):

```lua
require("quick-cmd").setup({
  keymap = "<leader>cc", -- Change to whatever key combination you prefer
})
```

---
## Usage

1. Press `<leader>cx` (or your custom keymap) to open the interactive prompt.
2. Type a shell command, or use the **Up** and **Down** arrow keys to select from your recent history list.
3. Press **Enter** to run the command inside the interactive terminal.
4. Press **Esc** inside the terminal or prompt window to close it cleanly.

---
## License

Distributed under the MIT License. See `LICENSE` for more information.

