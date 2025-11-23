-- UI management for displaying suggestions
local M = {}

-- Store the current suggestion buffer and window
local suggestion_buf = nil
local suggestion_win = nil

-- Create or update the suggestion window
function M.show_suggestions(content, config)
  -- Close existing window if open
  M.close_suggestions()
  
  -- Validate content
  if not content or content == "" then
    vim.notify("code-improver: No content to display", vim.log.levels.WARN)
    return
  end
  
  -- Create a new buffer
  suggestion_buf = vim.api.nvim_create_buf(false, true) -- not listed, scratch buffer
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(suggestion_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(suggestion_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(suggestion_buf, "swapfile", false)
  vim.api.nvim_buf_set_option(suggestion_buf, "filetype", "markdown")
  vim.api.nvim_buf_set_option(suggestion_buf, "modifiable", true)
  
  -- Split content into lines (more robust method)
  local lines = vim.split(content, "\n", { plain = true })
  
  -- If no lines were created, try alternative splitting
  if #lines == 0 then
    lines = { content }
  end
  
  -- Add header
  table.insert(lines, 1, "# Code Improvement Suggestions")
  table.insert(lines, 2, "")
  table.insert(lines, 3, "Press 'q' to close this window")
  table.insert(lines, 4, "")
  table.insert(lines, 5, "---")
  table.insert(lines, 6, "")
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(suggestion_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(suggestion_buf, "modifiable", false)
  
  -- Determine split command based on config
  local split_cmd
  if config.split_position == "left" then
    split_cmd = "topleft vsplit"
  elseif config.split_position == "above" then
    split_cmd = "topleft split"
  elseif config.split_position == "below" then
    split_cmd = "botright split"
  else -- right (default)
    split_cmd = "botright vsplit"
  end
  
  -- Create the split window
  vim.cmd(split_cmd)
  suggestion_win = vim.api.nvim_get_current_win()
  
  -- Set the buffer in the window
  vim.api.nvim_win_set_buf(suggestion_win, suggestion_buf)
  
  -- Set window options
  vim.api.nvim_win_set_option(suggestion_win, "wrap", true)
  vim.api.nvim_win_set_option(suggestion_win, "linebreak", true)
  vim.api.nvim_win_set_option(suggestion_win, "number", false)
  vim.api.nvim_win_set_option(suggestion_win, "relativenumber", false)
  vim.api.nvim_win_set_option(suggestion_win, "signcolumn", "no")
  
  -- Set window size if specified
  if config.split_size then
    if config.split_position == "left" or config.split_position == "right" then
      vim.api.nvim_win_set_width(suggestion_win, config.split_size)
    else
      vim.api.nvim_win_set_height(suggestion_win, config.split_size)
    end
  end
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(suggestion_buf, "Code Improvement Suggestions")
  
  -- Set up key mapping to close the window with 'q'
  vim.api.nvim_buf_set_keymap(
    suggestion_buf,
    "n",
    "q",
    ":lua require('code-improver.ui').close_suggestions()<CR>",
    { noremap = true, silent = true }
  )
  
  -- Force UI update to ensure window is visible
  vim.cmd('redraw')
  
  -- Return focus to original window if user wants
  -- (comment out the next line if you want focus to stay in suggestions)
  -- vim.cmd("wincmd p")
end

-- Close the suggestions window
function M.close_suggestions()
  if suggestion_win and vim.api.nvim_win_is_valid(suggestion_win) then
    vim.api.nvim_win_close(suggestion_win, true)
  end
  if suggestion_buf and vim.api.nvim_buf_is_valid(suggestion_buf) then
    vim.api.nvim_buf_delete(suggestion_buf, { force = true })
  end
  suggestion_win = nil
  suggestion_buf = nil
end

-- Show an error message in a split window
function M.show_error(error_msg, config)
  local content = "# Error\n\n" .. error_msg .. "\n\nPlease check your configuration and try again."
  M.show_suggestions(content, config)
end

-- Show a loading message
function M.show_loading(config)
  -- Create a temporary buffer with loading message
  local loading_content = [[# Code Improvement

⏳ **Analyzing your code...**

Please wait while Claude AI reviews your code and generates suggestions.

This may take a few seconds depending on:
- The size of your code
- Your standards documentation
- API response time

---

_You can press `q` to cancel if needed._]]
  M.show_suggestions(loading_content, config)
end

return M

