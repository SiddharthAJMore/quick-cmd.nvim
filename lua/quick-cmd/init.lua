local M = {}

-- Track globally to prevent duplicate setups and maintain history state
M.active_win = nil
M.active_buf = nil
M.history_win = nil
M.history_buf = nil
M.history = {}
M.history_idx = 0

-- Function to safely close the entire component (prompt + history windows)
local function close_all()
  if M.active_win and vim.api.nvim_win_is_valid(M.active_win) then
    pcall(vim.api.nvim_win_close, M.active_win, true)
  end
  if M.active_buf and vim.api.nvim_buf_is_valid(M.active_buf) then
    pcall(vim.api.nvim_buf_delete, M.active_buf, { force = true })
  end
  if M.history_win and vim.api.nvim_win_is_valid(M.history_win) then
    pcall(vim.api.nvim_win_close, M.history_win, true)
  end
  if M.history_buf and vim.api.nvim_buf_is_valid(M.history_buf) then
    pcall(vim.api.nvim_buf_delete, M.history_buf, { force = true })
  end
  M.active_win = nil
  M.active_buf = nil
  M.history_win = nil
  M.history_buf = nil
end

function M.open_interactive_prompt()
  -- 1. If user presses keymap again, close any previous windows cleanly first
  close_all()

  -- Reset history index to 0 (fresh session, no highlight/selection initially)
  M.history_idx = 0

  -- 2. Create a scratch buffer for entering the command
  local prompt_buf = vim.api.nvim_create_buf(false, true)
  M.active_buf = prompt_buf
  
  -- Calculate screen dimensions to center the window
  local ui = vim.api.nvim_list_uis()
  if not ui or #ui == 0 then return end
  local current_ui = ui[1]
  
  local width = math.floor(current_ui.width * 0.6)
  local height = 1
  local row = math.floor((current_ui.height - height) / 2)
  local col = math.floor((current_ui.width - width) / 2)

  local prompt_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Type Command ",
    title_pos = "center",
  }

  -- 3. Open the main prompt window
  local win = vim.api.nvim_open_win(prompt_buf, true, prompt_opts)
  M.active_win = win

  -- 4. Open history list window below the prompt if history exists
  if #M.history > 0 then
    local hist_buf = vim.api.nvim_create_buf(false, true)
    M.history_buf = hist_buf
    
    -- Populate history buffer with past commands (most recent at the top)
    vim.api.nvim_buf_set_lines(hist_buf, 0, -1, false, M.history)

    -- Limit history window height to a maximum of 10 lines
    local hist_height = math.min(#M.history, 10)
    
    local hist_opts = {
      relative = "editor",
      width = width,
      height = hist_height,
      row = row + 3,
      col = col,
      style = "minimal",
      border = "rounded",
      title = " History ",
      title_pos = "center",
    }

    local hist_win = vim.api.nvim_open_win(hist_buf, false, hist_opts)
    M.history_win = hist_win

    vim.api.nvim_win_set_option(hist_win, "cursorline", false)
  end

  vim.cmd("startinsert")

  -- Helper function to update prompt text and highlight corresponding history line
  local function update_selection(text)
    vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { text })
    vim.api.nvim_win_set_cursor(win, { 1, #text })

    if M.history_win and vim.api.nvim_win_is_valid(M.history_win) then
      if M.history_idx > 0 then
        vim.api.nvim_win_set_option(M.history_win, "cursorline", true)
        pcall(vim.api.nvim_win_set_cursor, M.history_win, { M.history_idx, 0 })
      else
        vim.api.nvim_win_set_option(M.history_win, "cursorline", false)
      end
    end
  end

  -- 5. Handle History Navigation
  vim.keymap.set("i", "<Down>", function()
    if #M.history == 0 then return end
    if M.history_idx == 0 then
      M.history_idx = 1
    elseif M.history_idx < #M.history then
      M.history_idx = M.history_idx + 1
    end
    update_selection(M.history[M.history_idx] or "")
  end, { buffer = prompt_buf, silent = true })

  -- Handle History Navigation 
  vim.keymap.set("i", "<Up>", function()
    if #M.history == 0 then return end
    if M.history_idx > 1 then
      M.history_idx = M.history_idx - 1
      update_selection(M.history[M.history_idx])
    else
      M.history_idx = 0
      update_selection("") 
    end
  end, { buffer = prompt_buf, silent = true })

  -- 6. Handle Command Execution on Enter
  vim.keymap.set("i", "<CR>", function()
    if not vim.api.nvim_win_is_valid(win) then return end

    local lines = vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)
    local cmd = lines[1]

    vim.cmd("stopinsert")

    if not cmd or cmd == "" then
      close_all()
      return
    end

    for i, c in ipairs(M.history) do
      if c == cmd then
        table.remove(M.history, i)
        break
      end
    end

    table.insert(M.history, 1, cmd)

    if #M.history > 10 then
      table.remove(M.history, 11)
    end

    if M.history_win and vim.api.nvim_win_is_valid(M.history_win) then
      pcall(vim.api.nvim_win_close, M.history_win, true)
    end
    if M.history_buf and vim.api.nvim_buf_is_valid(M.history_buf) then
      pcall(vim.api.nvim_buf_delete, M.history_buf, { force = true })
    end
    M.history_win = nil
    M.history_buf = nil

    local term_buf = vim.api.nvim_create_buf(false, true)
    M.active_buf = term_buf

    local target_height = math.floor(current_ui.height * 0.6)
    local target_row = math.floor((current_ui.height - target_height) / 2)
    
    pcall(vim.api.nvim_win_set_buf, win, term_buf)
    pcall(vim.api.nvim_win_set_config, win, {
      relative = "editor",
      row = target_row,
      col = col,
      height = target_height,
      title = " Running: " .. cmd .. " ",
    })

    if vim.api.nvim_buf_is_valid(prompt_buf) then 
      pcall(vim.api.nvim_buf_delete, prompt_buf, { force = true }) 
    end

    vim.fn.termopen(cmd, {
      on_exit = function(_, exit_code)
        pcall(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { 
              relative = "editor",
              row = target_row,
              col = col,
              title = " Process Finished (Code: " .. exit_code .. ") — Press Esc to Close " 
            })
          end
        end)
      end
    })

    vim.cmd("startinsert")

    vim.keymap.set("t", "<Esc>", close_all, { buffer = term_buf, silent = true })
    vim.keymap.set("n", "<Esc>", close_all, { buffer = term_buf, silent = true })

  end, { buffer = prompt_buf, silent = true })

  vim.keymap.set("n", "<Esc>", close_all, { buffer = prompt_buf, silent = true })
end

-- Setup function to accept custom user options (like keymaps)
function M.setup(opts)
  opts = opts or {}
  local keymap = opts.keymap or "<leader>cx"

  vim.keymap.set("n", keymap, M.open_interactive_prompt, { desc = "Interactive Floating Terminal" })
end

return M
