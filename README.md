# code-improver.nvim

A lightweight Neovim plugin that analyzes your code and provides improvement suggestions using Claude AI. It automatically includes your codebase standards and guidelines from markdown files to provide context-aware, project-specific recommendations displayed in a vertical split window.

## Features

- **Command-based trigger**: `:ImproveCode` command
- **Smart content selection**: Sends visual selection if active, otherwise entire file
- **Standards integration**: Automatically includes markdown files from configurable standards folder
- **Vertical split display**: Shows suggestions in a vertical split window
- **Claude integration**: Uses Anthropic's Claude API for analysis
- **Context-aware suggestions**: Recommendations based on your codebase standards and guidelines
- **Intelligent caching**: Standards are cached per-project to improve performance

## Requirements

- Neovim >= 0.8.0
- `curl` command-line tool
- Anthropic API key

## Installation

### Using Lazy.nvim

Add this to your Lazy.nvim configuration:

```lua
{
  "codegirl-007/code-standards",
  config = function()
    require("code-improver").setup({
      api_key = os.getenv("ANTHROPIC_API_KEY"),
      standards_folder = "./docs/standards/",
    })
  end,
}
```

### Using Packer

```lua
use {
  "codegirl-007/code-standards",
  config = function()
    require("code-improver").setup({
      api_key = os.getenv("ANTHROPIC_API_KEY"),
      standards_folder = "./docs/standards/",
    })
  end
}
```

### Local Installation (for development)

If you're developing or testing the plugin locally:

```lua
{
  dir = "/Users/stephaniegredell/projects/code-standards",
  config = function()
    require("code-improver").setup({
      api_key = os.getenv("ANTHROPIC_API_KEY"),
      standards_folder = "./docs/standards/",
    })
  end,
}
```

## Configuration

### API Key Setup

Set your Anthropic API key as an environment variable:

```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

Add this to your `~/.zshrc` or `~/.bashrc` to make it permanent.

### Configuration Options

```lua
require("code-improver").setup({
  -- Required: Your Anthropic API key
  -- If not provided, will read from ANTHROPIC_API_KEY environment variable
  api_key = nil,
  
  -- Path to standards folder (relative to current working directory)
  -- Default: "./docs/standards/"
  standards_folder = "./docs/standards/",
  
  -- Claude model to use
  -- Default: "claude-3-5-sonnet-20241022"
  model = "claude-3-5-sonnet-20241022",
  
  -- Maximum tokens for Claude response
  -- Default: 8192
  max_tokens = 8192,
  
  -- Split window position: "right", "left", "above", "below"
  -- Default: "right"
  split_position = "right",
  
  -- Split window size (width for vertical, height for horizontal)
  -- nil = use default (50%)
  split_size = nil,
})
```

## Usage

### Basic Usage

1. Open a file in Neovim
2. Run `:ImproveCode`
3. View suggestions in the split window
4. Press `q` to close the suggestions window

### Visual Selection

You can also analyze just a portion of your code:

1. Enter visual mode (`v`, `V`, or `Ctrl-v`)
2. Select the code you want to analyze
3. Run `:ImproveCode`

### Standards Folder

The plugin works best when you have coding standards defined in markdown files. These should be placed in your standards folder (default: `./docs/standards/`).

**Important**: The standards folder path is **relative to Neovim's current working directory** (`:pwd`), which is typically your project root.

Example structure:

```
my-project/
├── docs/
│   └── standards/
│       ├── coding-style.md
│       ├── best-practices.md
│       └── architecture.md
├── src/
│   └── main.lua
└── init.lua
```

When you run `:ImproveCode`, the plugin will:
1. Find all `.md` files in `./docs/standards/` (relative to your project root)
2. Aggregate their content
3. Send them to Claude along with your code
4. Get suggestions that align with your standards

If the standards folder doesn't exist or contains no markdown files, the plugin will still work but without project-specific context.

## Commands

- `:ImproveCode` - Analyze current file or visual selection

## Examples

### Example 1: Analyze entire file

```vim
:ImproveCode
```

### Example 2: Analyze selected code

```vim
" In visual mode
:'<,'>ImproveCode
```

### Example 3: Clear standards cache

If you've updated your standards files and want to force a reload:

```lua
:lua require('code-improver').clear_cache()
```

## How It Works

1. **Standards Loading**: The plugin scans your standards folder for markdown files and caches them
2. **Code Extraction**: Gets the current file content or visual selection
3. **Context Building**: Combines standards + code into a comprehensive prompt
4. **API Call**: Sends to Claude AI for analysis
5. **Display Results**: Shows suggestions in a vertical split with markdown highlighting

## Tips

- Keep your standards organized in separate markdown files by topic
- Update standards as your team's practices evolve
- Use descriptive filenames for your standards (e.g., `python-style-guide.md`)
- The plugin caches standards for performance, so large standards folders are fine

## Troubleshooting

### "API key not configured" error

Make sure you've set the `ANTHROPIC_API_KEY` environment variable or passed `api_key` in the setup configuration.

### "Standards folder not found" warning

The standards folder path is relative to Neovim's current working directory (`:pwd`). Either:
- Create the folder at the specified path
- Adjust the `standards_folder` configuration option
- The plugin will still work without standards

### API request failed

- Check your internet connection
- Verify your API key is valid
- Check if you've hit API rate limits

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - See LICENSE file for details

## Credits

Built with Claude AI by Anthropic.

