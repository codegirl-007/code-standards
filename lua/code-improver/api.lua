-- Claude API integration
local M = {}

-- Escape string for JSON
local function json_escape(str)
  str = str:gsub("\\", "\\\\")
  str = str:gsub('"', '\\"')
  str = str:gsub("\n", "\\n")
  str = str:gsub("\r", "\\r")
  str = str:gsub("\t", "\\t")
  return str
end

-- Build the prompt for code improvement
local function build_prompt(standards_content, code_content, filename)
  local prompt_parts = {}
  
  if standards_content then
    table.insert(prompt_parts, "Here are our project's coding standards and guidelines:\n")
    table.insert(prompt_parts, standards_content)
    table.insert(prompt_parts, "\n---\n\n")
  end
  
  table.insert(prompt_parts, "Please review the following code")
  if filename then
    table.insert(prompt_parts, " from " .. filename)
  end
  table.insert(prompt_parts, " and provide specific, actionable improvement suggestions:\n\n")
  table.insert(prompt_parts, "```\n")
  table.insert(prompt_parts, code_content)
  table.insert(prompt_parts, "\n```\n\n")
  table.insert(prompt_parts, "Focus on:\n")
  table.insert(prompt_parts, "- Code quality and best practices\n")
  table.insert(prompt_parts, "- Adherence to the provided standards (if any)\n")
  table.insert(prompt_parts, "- Potential bugs or issues\n")
  table.insert(prompt_parts, "- Performance improvements\n")
  table.insert(prompt_parts, "- Readability and maintainability\n\n")
  table.insert(prompt_parts, "Provide your suggestions in a clear, structured format with specific examples where applicable.")
  
  return table.concat(prompt_parts, "")
end

-- Build the JSON payload for the API request
local function build_request_payload(config, prompt)
  local payload = {
    model = config.model,
    max_tokens = config.max_tokens,
    messages = {
      {
        role = "user",
        content = prompt
      }
    }
  }
  
  -- Manually build JSON (simple approach for our needs)
  local json = string.format(
    '{"model":"%s","max_tokens":%d,"messages":[{"role":"user","content":"%s"}]}',
    json_escape(payload.model),
    payload.max_tokens,
    json_escape(prompt)
  )
  
  return json
end

-- Parse the API response
local function parse_response(response_text)
  -- Try using vim's built-in JSON decoder first (Neovim 0.8+)
  if vim.json and vim.json.decode then
    local ok, decoded = pcall(vim.json.decode, response_text)
    if ok and decoded then
      -- Check for error in response
      if decoded.error then
        return nil, "API Error: " .. (decoded.error.message or "Unknown error")
      end
      
      -- Extract text content from the first content block
      if decoded.content and decoded.content[1] and decoded.content[1].text then
        return decoded.content[1].text, nil
      end
      
      -- Debug: show what we got
      local debug_info = "Response structure: "
      if decoded.content then
        debug_info = debug_info .. "has content field, "
        if type(decoded.content) == "table" then
          debug_info = debug_info .. "#content=" .. #decoded.content
        end
      else
        debug_info = debug_info .. "no content field"
      end
      
      return nil, "Failed to find text content in API response. " .. debug_info
    elseif not ok then
      -- JSON decode failed, show error
      local json_err = tostring(decoded)
      vim.notify("JSON decode failed: " .. json_err .. ", trying manual parsing", vim.log.levels.WARN)
    end
    -- If vim.json.decode failed, fall through to manual parsing
  end
  
  -- Fallback: Manual parsing
  -- Find the content field in the JSON response
  -- We need to properly handle escaped quotes within the text content
  
  -- First, try to find the text field
  local text_start = response_text:find('"text"%s*:%s*"')
  if not text_start then
    -- Try to extract any error message
    local error_msg = response_text:match('"message"%s*:%s*"([^"]*)"')
    if error_msg then
      return nil, "API Error: " .. error_msg
    end
    return nil, "Failed to parse API response - no text field found"
  end
  
  -- Find where the actual content starts (after "text":")
  local content_start = response_text:find('"', text_start + 1)
  if not content_start then
    return nil, "Failed to parse API response - malformed text field"
  end
  content_start = content_start + 1
  
  -- Now we need to find the end of the string, accounting for escaped quotes
  local i = content_start
  local escape_next = false
  local content_end = nil
  
  while i <= #response_text do
    local char = response_text:sub(i, i)
    
    if escape_next then
      escape_next = false
    elseif char == "\\" then
      escape_next = true
    elseif char == '"' then
      -- Found the closing quote
      content_end = i - 1
      break
    end
    
    i = i + 1
  end
  
  if not content_end then
    return nil, "Failed to parse API response - unclosed text field"
  end
  
  local content = response_text:sub(content_start, content_end)
  
  -- Unescape JSON string
  content = content:gsub("\\n", "\n")
  content = content:gsub("\\r", "\r")
  content = content:gsub("\\t", "\t")
  content = content:gsub('\\"', '"')
  content = content:gsub("\\\\", "\\")
  
  return content, nil
end

-- Call the Claude API
function M.improve_code(config, standards_content, code_content, filename)
  -- Build the prompt
  local prompt = build_prompt(standards_content, code_content, filename)
  
  -- Build request payload
  local json_payload = build_request_payload(config, prompt)
  
  -- Write payload to temp file
  local temp_file = os.tmpname()
  local f = io.open(temp_file, "w")
  if not f then
    return nil, "Failed to create temporary file"
  end
  f:write(json_payload)
  f:close()
  
  -- Create temp file for response
  local response_file = os.tmpname()
  
  -- Build curl command with output to file and timeout
  local curl_cmd = string.format(
    'curl -s --max-time 120 -X POST https://api.anthropic.com/v1/messages ' ..
    '-H "Content-Type: application/json" ' ..
    '-H "x-api-key: %s" ' ..
    '-H "anthropic-version: 2023-06-01" ' ..
    '-d @%s ' ..
    '-o %s',
    config.api_key,
    temp_file,
    response_file
  )
  
  -- Execute request
  vim.fn.system(curl_cmd)
  local exit_code = vim.v.shell_error
  
  -- Clean up request temp file
  os.remove(temp_file)
  
  -- Check for curl errors
  if exit_code ~= 0 then
    os.remove(response_file)
    return nil, "API request failed with exit code " .. exit_code
  end
  
  -- Read response from file (handles large responses better)
  local response_fh = io.open(response_file, "r")
  if not response_fh then
    os.remove(response_file)
    return nil, "Failed to read API response file"
  end
  
  local response = response_fh:read("*all")
  response_fh:close()
  
  -- Clean up response temp file
  os.remove(response_file)
  
  -- Check if response is empty
  if not response or response == "" then
    return nil, "Empty response from API"
  end
  
  -- Parse response
  local content, err = parse_response(response)
  if err then
    -- Add helpful debug info
    local preview = response:sub(1, 500)
    return nil, err .. "\n\nResponse preview:\n" .. preview
  end
  
  return content, nil
end

return M

