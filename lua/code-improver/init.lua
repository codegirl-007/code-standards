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
  ui.show_loading(cfg)
  
  -- Load standards (this happens in background, non-blocking for user experience)
  local standards_content, standards_err = standards.load_standards(cfg)
  
  if standards_err then
    -- Warn but continue without standards
    vim.notify("code-improver: " .. standards_err, vim.log.levels.WARN)
  end
  
  -- Call API (this will block, but that's okay for now)
  -- In a production plugin, you'd want to make this async
  local suggestions, api_err = api.improve_code(cfg, standards_content, code_content, filename)
  
  if api_err then
    vim.notify("code-improver: " .. api_err, vim.log.levels.ERROR)
    ui.show_error(api_err, cfg)
    return
  end
  
  -- Show suggestions
  ui.show_suggestions(suggestions, cfg)
end

-- Command to clear standards cache
function M.clear_cache()
  standards.clear_cache()
  vim.notify("code-improver: Standards cache cleared", vim.log.levels.INFO)
end

-- Export the improve_code function for direct calling
M.improve = M.improve_code

return M

