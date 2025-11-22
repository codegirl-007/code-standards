-- Configuration management for code-improver plugin
local M = {}

-- Default configuration
M.defaults = {
  api_key = nil, -- Will be read from ANTHROPIC_API_KEY env var if not set
  standards_folder = "./docs/standards/",
  model = "claude-3-5-sonnet-20241022",
  max_tokens = 4096,
  split_position = "right", -- right, left, above, below
  split_size = nil, -- nil for default (50%)
}

-- Current configuration (will be merged with user config)
M.config = {}

-- Setup function to merge user config with defaults
function M.setup(user_config)
  user_config = user_config or {}
  
  -- Merge with defaults
  M.config = vim.tbl_deep_extend("force", M.defaults, user_config)
  
  -- If no API key provided, try to get from environment
  if not M.config.api_key then
    M.config.api_key = vim.fn.getenv("ANTHROPIC_API_KEY")
  end
  
  -- Validate configuration
  local ok, err = M.validate()
  if not ok then
    vim.notify("code-improver: " .. err, vim.log.levels.WARN)
  end
  
  return M.config
end

-- Validate the configuration
function M.validate()
  -- Check API key
  if not M.config.api_key or M.config.api_key == vim.NIL or M.config.api_key == "" then
    return false, "API key not configured. Set ANTHROPIC_API_KEY environment variable or pass api_key in setup()"
  end
  
  -- Validate split position
  local valid_positions = { right = true, left = true, above = true, below = true }
  if not valid_positions[M.config.split_position] then
    return false, "Invalid split_position. Must be one of: right, left, above, below"
  end
  
  return true
end

-- Get current configuration
function M.get()
  return M.config
end

return M

