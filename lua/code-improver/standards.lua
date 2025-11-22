-- Standards folder parsing and caching
local M = {}

-- Cache structure: { cwd = { mtime = timestamp, content = string } }
local cache = {}

-- Get all markdown files in a directory recursively
local function find_markdown_files(dir)
  local files = {}
  
  -- Check if directory exists
  local stat = vim.loop.fs_stat(dir)
  if not stat or stat.type ~= "directory" then
    return files
  end
  
  -- Scan directory
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return files
  end
  
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    
    local path = dir .. "/" .. name
    
    if type == "directory" then
      -- Recursively scan subdirectories
      local subfiles = find_markdown_files(path)
      for _, file in ipairs(subfiles) do
        table.insert(files, file)
      end
    elseif type == "file" and (name:match("%.md$") or name:match("%.markdown$")) then
      table.insert(files, path)
    end
  end
  
  return files
end

-- Read file content
local function read_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  
  local content = file:read("*all")
  file:close()
  return content
end

-- Get the modification time of the newest file in the standards folder
local function get_newest_mtime(dir)
  local files = find_markdown_files(dir)
  local newest = 0
  
  for _, file in ipairs(files) do
    local stat = vim.loop.fs_stat(file)
    if stat and stat.mtime.sec > newest then
      newest = stat.mtime.sec
    end
  end
  
  return newest
end

-- Load and aggregate all markdown files from standards folder
function M.load_standards(config)
  local cwd = vim.fn.getcwd()
  local standards_path = config.standards_folder
  
  -- Resolve path relative to cwd
  if not vim.startswith(standards_path, "/") then
    standards_path = cwd .. "/" .. standards_path
  end
  
  -- Normalize path (remove trailing slash, resolve ..)
  standards_path = vim.fn.fnamemodify(standards_path, ":p"):gsub("/$", "")
  
  -- Check if directory exists
  local stat = vim.loop.fs_stat(standards_path)
  if not stat or stat.type ~= "directory" then
    return nil, "Standards folder not found: " .. standards_path
  end
  
  -- Check cache
  local newest_mtime = get_newest_mtime(standards_path)
  local cache_key = cwd .. ":" .. standards_path
  
  if cache[cache_key] and cache[cache_key].mtime >= newest_mtime then
    return cache[cache_key].content, nil
  end
  
  -- Load all markdown files
  local files = find_markdown_files(standards_path)
  
  if #files == 0 then
    local msg = "No markdown files found in standards folder: " .. standards_path
    return nil, msg
  end
  
  -- Aggregate content
  local content_parts = {}
  table.insert(content_parts, "# Project Coding Standards\n")
  
  for _, file in ipairs(files) do
    local relative_path = file:sub(#standards_path + 2) -- +2 to remove leading slash
    local file_content = read_file(file)
    
    if file_content then
      table.insert(content_parts, "\n## From: " .. relative_path .. "\n")
      table.insert(content_parts, file_content)
      table.insert(content_parts, "\n")
    end
  end
  
  local aggregated = table.concat(content_parts, "")
  
  -- Update cache
  cache[cache_key] = {
    mtime = newest_mtime,
    content = aggregated
  }
  
  return aggregated, nil
end

-- Clear cache (useful for testing or manual refresh)
function M.clear_cache()
  cache = {}
end

return M

