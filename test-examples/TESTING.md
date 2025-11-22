# Testing code-improver.nvim

## Manual Testing Instructions

### 1. Setup

Install the plugin in Neovim using one of these methods:

**Option A: Lazy.nvim (local development)**
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

**Option B: Direct require for testing**
```lua
-- In your init.lua or a test file
package.path = package.path .. ";/Users/stephaniegredell/projects/code-standards/?.lua"
require("code-improver").setup({
  api_key = os.getenv("ANTHROPIC_API_KEY"),
  standards_folder = "./docs/standards/",
})
```

### 2. Set API Key

Make sure your Anthropic API key is set:
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

### 3. Test Cases

#### Test 1: Analyze entire file
1. Open `test-examples/sample.lua`
2. Run `:ImproveCode`
3. Verify suggestions appear in vertical split
4. Press `q` to close

#### Test 2: Analyze visual selection
1. Open `test-examples/sample.lua`
2. Enter visual mode (`V`)
3. Select the `processData` function
4. Run `:'<,'>ImproveCode`
5. Verify suggestions for only selected code

#### Test 3: Test without standards
1. Temporarily rename the standards folder
2. Run `:ImproveCode` on sample.lua
3. Should see warning but still get suggestions

#### Test 4: Clear cache
1. Run `:lua require('code-improver').clear_cache()`
2. Verify cache cleared message

#### Test 5: Test different split positions
```lua
require("code-improver").setup({
  split_position = "left",  -- or "above", "below"
})
```

### 4. Expected Behavior

- Standards should be loaded from docs/standards/
- Suggestions should reference the standards
- Split should open on the right by default
- Pressing `q` should close the split
- Error messages should be clear and helpful

### 5. Verification Checklist

- [ ] Plugin loads without errors
- [ ] :ImproveCode command is registered
- [ ] Standards are loaded and cached
- [ ] API calls work with valid key
- [ ] Split window opens correctly
- [ ] Suggestions are displayed with markdown highlighting
- [ ] 'q' key closes the window
- [ ] Visual selection works
- [ ] Error handling works (try without API key)
- [ ] Works without standards folder

