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
  -- Find the content field in the JSON response
  -- This is a simple parser - in production, you'd want a proper JSON library
  local content = response_text:match('"text"%s*:%s*"([^"]*)"')
  
  if not content then
    -- Try to extract any error message
    local error_msg = response_text:match('"message"%s*:%s*"([^"]*)"')
    if error_msg then
      return nil, "API Error: " .. error_msg
    end
    return nil, "Failed to parse API response"
  end
  
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
  
  -- Build curl command
  local curl_cmd = string.format(
    'curl -s -X POST https://api.anthropic.com/v1/messages ' ..
    '-H "Content-Type: application/json" ' ..
    '-H "x-api-key: %s" ' ..
    '-H "anthropic-version: 2023-06-01" ' ..
    '-d @%s',
    config.api_key,
    temp_file
  )
  
  -- Execute request
  local response = vim.fn.system(curl_cmd)
  local exit_code = vim.v.shell_error
  
  -- Clean up temp file
  os.remove(temp_file)
  
  -- Check for errors
  if exit_code ~= 0 then
    return nil, "API request failed with exit code " .. exit_code .. ": " .. response
  end
  
  -- Parse response
  local content, err = parse_response(response)
  if err then
    return nil, err
  end
  
  return content, nil
end

return M

