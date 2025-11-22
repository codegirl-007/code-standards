# Simple AI Code Improvement Plugin

## Overview

A lightweight Neovim plugin that analyzes your code and provides improvement suggestions using Claude AI. It automatically includes your codebase standards and guidelines from markdown files to provide context-aware, project-specific recommendations displayed in a split window.

## Core Features

- **Command-based trigger**: `:ImproveCode` command
- **Smart content selection**: Sends visual selection if active, otherwise entire file
- **Standards integration**: Automatically includes markdown files from configurable standards folder
- **Split window display**: Shows suggestions in a horizontal split window
- **Claude integration**: Uses Anthropic's Claude API for analysis
- **Context-aware suggestions**: Recommendations based on your codebase standards and guidelines

## Implementation Approach

### Plugin Structure

- `lua/code-improver/init.lua` - Main plugin logic and command registration
- `lua/code-improver/config.lua` - Configuration management
- `lua/code-improver/api.lua` - Claude API integration
- `lua/code-improver/ui.lua` - UI management (split window)
- `lua/code-improver/standards.lua` - Standards folder parsing and content aggregation

### Key Components

1. **Command Registration**: Register `:ImproveCode` command
2. **Content Extraction**: Get selected text or full buffer content
3. **Standards Loading**: Read and parse markdown files from standards folder
4. **Context Building**: Combine code + standards into comprehensive prompt
5. **API Integration**: Send to Claude with improvement-focused prompt
6. **Result Display**: Create split window with formatted suggestions
7. **Error Handling**: Handle API failures and missing standards gracefully

### Standards Integration Details

- **Configurable folder path**: User sets standards directory in config
- **Markdown file discovery**: Recursively find all `.md` files in standards folder
- **Content aggregation**: Combine all markdown content as context
- **Caching**: Cache standards content to avoid re-reading on each request
- **File watching**: Optional auto-refresh when standards files change

### Configuration Options

- API key management (environment variable or config)
- Standards folder path (default: `./docs/standards/`)
- Custom prompts for different file types
- Split window positioning and size
- Standards caching behavior
- Result formatting preferences

## Example Usage Flow

1. User runs `:ImproveCode` on a JavaScript file
2. Plugin reads current file/selection
3. Plugin loads all markdown files from standards folder (e.g., `js-style-guide.md`, `testing-standards.md`)
4. Plugin sends combined context to Claude: "Here are our coding standards: [standards content]. Please review this code and suggest improvements: [code content]"
5. Claude provides suggestions that align with the project's specific standards
6. Results displayed in split window with actionable recommendations

## Repository Structure

```
code-improver.nvim/
├── README.md
├── lua/
│   └── code-improver/
│       ├── init.lua
│       ├── config.lua
│       ├── api.lua
│       ├── ui.lua
│       └── standards.lua
├── doc/
│   └── code-improver.txt
└── plugin/
    └── code-improver.lua
```

## Lazy.nvim Installation

```lua
{
  "yourusername/code-improver.nvim",
  config = function()
    require("code-improver").setup({
      standards_folder = "./docs/standards/",
      api_key = os.getenv("ANTHROPIC_API_KEY"),
    })
  end,
}
```