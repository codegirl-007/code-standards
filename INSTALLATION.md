# Installation Guide for code-improver.nvim

## Prerequisites

1. **Neovim 0.8.0 or higher**
   ```bash
   nvim --version
   ```

2. **curl command-line tool**
   ```bash
   curl --version
   ```

3. **Anthropic API Key**
   - Sign up at https://console.anthropic.com
   - Generate an API key
   - Note: API usage is billed by Anthropic

## Step 1: Get Your API Key

1. Visit https://console.anthropic.com
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (you won't be able to see it again!)

## Step 2: Set Environment Variable

Add to your shell configuration file (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

Verify it's set:
```bash
echo $ANTHROPIC_API_KEY
```

## Step 3: Install with Lazy.nvim

### For Released Plugin

Add to your `lazy.nvim` configuration:

```lua
{
  "codegirl-007/code-standards",
  config = function()
    require("code-improver").setup({
      standards_folder = "./docs/standards/",  -- customize as needed
    })
  end,
}
```

### For Local Development/Testing

If you're testing locally or developing:

```lua
{
  dir = "/Users/stephaniegredell/projects/code-standards",
  name = "code-improver.nvim",
  config = function()
    require("code-improver").setup({
      api_key = os.getenv("ANTHROPIC_API_KEY"),
      standards_folder = "./docs/standards/",
    })
  end,
}
```

## Step 4: Reload Neovim Configuration

After adding the plugin configuration:

```vim
:Lazy sync
```

Or restart Neovim.

## Step 5: Verify Installation

Check that the command is registered:

```vim
:ImproveCode
```

You should see the command complete (or get an appropriate error if no file is open).

## Step 6: Set Up Standards Folder (Optional but Recommended)

Create a standards folder in your project:

```bash
mkdir -p docs/standards
```

Add markdown files with your coding standards:

```bash
# Example
cat > docs/standards/style-guide.md << 'EOF'
# Coding Style Guide

## General Principles
- Write clear, readable code
- Use meaningful variable names
- Keep functions small and focused
EOF
```

## Troubleshooting

### Command not found

- Make sure you ran `:Lazy sync`
- Check for errors with `:messages`
- Verify the plugin path is correct

### API key errors

- Verify environment variable: `:lua print(vim.fn.getenv("ANTHROPIC_API_KEY"))`
- Make sure you reloaded your shell after setting the variable
- Try setting the key directly in the config as a test

### Standards not loading

- Check the path is relative to your project root (`:pwd`)
- Verify markdown files exist: `:!ls docs/standards/`
- Try clearing cache: `:lua require('code-improver').clear_cache()`

### curl errors

- Test curl manually: `curl --version`
- Check network connectivity
- Verify firewall/proxy settings

## Next Steps

1. Open a code file
2. Run `:ImproveCode`
3. Review suggestions in the split window
4. Press `q` to close
5. Customize configuration as needed

## Configuration Examples

### Minimal configuration
```lua
require("code-improver").setup()
```

### Full configuration
```lua
require("code-improver").setup({
  api_key = os.getenv("ANTHROPIC_API_KEY"),
  standards_folder = "./docs/standards/",
  model = "claude-3-5-sonnet-20241022",
  max_tokens = 8192,
  split_position = "right",
  split_size = 80,  -- 80 columns wide
})
```

### Different split positions
```lua
-- Left side
require("code-improver").setup({ split_position = "left" })

-- Bottom
require("code-improver").setup({ split_position = "below" })

-- Top
require("code-improver").setup({ split_position = "above" })
```

## Uninstallation

If using Lazy.nvim, remove the plugin configuration and run:

```vim
:Lazy clean
```

