-- Plugin registration for code-improver
-- This file is automatically loaded by Neovim

-- Prevent loading the plugin twice
if vim.g.loaded_code_improver then
  return
end
vim.g.loaded_code_improver = 1

-- The plugin will be set up by the user in their config
-- This file just ensures the plugin is available
-- The actual command registration happens in init.lua's setup() function

