-- Main entry point for code-improver plugin
local M = {}

local config = require("code-improver.config")
local standards = require("code-improver.standards")
local api = require("code-improver.api")
local ui = require("code-improver.ui")

-- Setup function to be called by user
function M.setup(user_config)
  config.setup(user_config)
  
  -- Register the command
  vim.api.nvim_create_user_command("ImproveCode", function(opts)
    M.improve_code()
  end, {
    desc = "Analyze and improve code using Claude AI",
    range = true,
  })
end

-- Get the code content to analyze
local function get_code_content()
  -- Check if there's a visual selection
  local mode = vim.fn.mode()
  
  if mode == "v" or mode == "V" or mode == "" then
    -- Get visual selection
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]
    
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    return table.concat(lines, "\n")
  else
    -- Get entire buffer
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    return table.concat(lines, "\n")
  end
end

-- Main function to improve code
function M.improve_code()
  local cfg = config.get()
  
  -- Validate configuration
  local ok, err = config.validate()
  if not ok then
    vim.notify("code-improver: " .. err, vim.log.levels.ERROR)
    return
  end
  
  -- Get current filename
  local filename = vim.fn.expand("%:t")
  if filename == "" then
    filename = "untitled"
  end
  
  -- Get code content
  local code_content = get_code_content()
  
  if not code_content or code_content == "" then
    vim.notify("code-improver: No code to analyze", vim.log.levels.WARN)
    return
  end
  
  -- Show loading message
  vim.notify("code-improver: Sending request to Claude AI...", vim.log.levels.INFO)
  ui.show_loading(cfg)
  
  -- Force UI to update so user sees the loading message
  vim.cmd('redraw')
  
  -- Load standards (this happens in background, non-blocking for user experience)
  local standards_content, standards_err = standards.load_standards(cfg)
  
  if standards_err then
    -- Warn but continue without standards
    vim.notify("code-improver: " .. standards_err, vim.log.levels.WARN)
  end
  
  -- Call API (this will block, but that's okay for now)
  -- In a production plugin, you'd want to make this async
  local ok, suggestions, api_err = pcall(function()
    return api.improve_code(cfg, standards_content, code_content, filename)
  end)
  
  if not ok then
    -- Lua error occurred
    local err_msg = "Unexpected error: " .. tostring(suggestions)
    vim.notify("code-improver: " .. err_msg, vim.log.levels.ERROR)
    ui.show_error(err_msg, cfg)
    return
  end
  
  if api_err then
    vim.notify("code-improver: " .. api_err, vim.log.levels.ERROR)
    ui.show_error(api_err, cfg)
    return
  end
  
  if not suggestions or suggestions == "" then
    local err_msg = "No suggestions received from API"
    vim.notify("code-improver: " .. err_msg, vim.log.levels.ERROR)
    ui.show_error(err_msg, cfg)
    return
  end
  
  -- Show suggestions (schedule to ensure UI updates properly)
  vim.schedule(function()
    vim.notify("code-improver: Suggestions ready!", vim.log.levels.INFO)
    ui.show_suggestions(suggestions, cfg)
  end)
end

-- Command to clear standards cache
function M.clear_cache()
  standards.clear_cache()
  vim.notify("code-improver: Standards cache cleared", vim.log.levels.INFO)
end

-- Test API connection (for debugging)
function M.test_api()
  local cfg = config.get()
  local ok, err = config.validate()
  if not ok then
    vim.notify("code-improver: " .. err, vim.log.levels.ERROR)
    return
  end
  
  vim.notify("Testing API connection...", vim.log.levels.INFO)
  
  -- Simple test code
  local test_code = "function hello() print('world') end"
  local suggestions, api_err = api.improve_code(cfg, nil, test_code, "test.lua")
  
  if api_err then
    vim.notify("API Test FAILED: " .. api_err, vim.log.levels.ERROR)
    print("Full error: " .. api_err)
  else
    vim.notify("API Test SUCCESS! Response length: " .. #suggestions .. " chars", vim.log.levels.INFO)
    print("Response preview: " .. suggestions:sub(1, 200))
  end
end

-- Test UI display (for debugging)
function M.test_ui()
  local cfg = config.get()
  local test_content = [[# Test Suggestions

This is a test of the UI display system.

## Test Section 1
- Item 1
- Item 2
- Item 3

## Test Section 2
Here is some sample text to verify the display is working correctly.

Press 'q' to close this window.]]
  
  vim.notify("Showing test UI window...", vim.log.levels.INFO)
  ui.show_suggestions(test_content, cfg)
  vim.notify("Test UI window should be visible now", vim.log.levels.INFO)
end

-- Export the improve_code function for direct calling
M.improve = M.improve_code

return M

