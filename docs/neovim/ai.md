# AI Integration

_Claude-powered development directly in your editor_

This configuration brings two powerful AI assistants into Neovim: Avante.nvim for inline code assistance and Claude Code
CLI for terminal-based pair programming. Together, they provide comprehensive AI support for your entire development
workflow.

## Avante.nvim - Claude in Your Editor

[Avante.nvim](https://github.com/yetone/avante.nvim) brings Claude Sonnet 4 directly into Neovim with a beautiful,
integrated UI that matches the SilkCircuit aesthetic.

### Configuration

```lua
provider = "claude"
claude = {
  model = "claude-sonnet-4-20250514",
  max_tokens = 4096,
  temperature = 0,
  timeout = 30000,
}
```

**Features:**

- Latest Claude Sonnet 4 model (January 2025)
- Zero temperature for deterministic responses
- 30-second timeout for complex requests
- Markdown rendering with syntax highlighting
- Beautiful neon borders matching SilkCircuit theme

### Core Keybindings

| Key         | Action           | Mode | Description                          |
| ----------- | ---------------- | ---- | ------------------------------------ |
| `Space a a` | Ask AI           | n, v | Ask Claude about selection or buffer |
| `Space a e` | Edit with AI     | n, v | Request code changes from Claude     |
| `Space a r` | Refresh response | n    | Regenerate last AI response          |

### Asking Questions

**Select code and ask:**

1. Visual select the code you want to ask about
2. Press `Space a a`
3. Type your question in the prompt
4. Press `Enter` or `Ctrl-s`

**Ask about entire buffer:**

1. Place cursor anywhere
2. Press `Space a a` (without selection)
3. Claude will use full buffer context

**Example prompts:**

- "Explain what this function does"
- "Why is this code throwing an error?"
- "What are the edge cases I should test?"
- "Suggest performance improvements"

### Editing Code

**Request changes:**

1. Select the code to modify (or entire buffer)
2. Press `Space a e`
3. Describe the changes you want
4. Review the diff in the side panel
5. Accept or reject changes

**Example requests:**

- "Add error handling to this function"
- "Refactor this to use async/await"
- "Extract this logic into a separate function"
- "Add TypeScript types to all parameters"

### AI Suggestions

Avante can provide inline suggestions as you code (experimental feature, currently disabled):

| Key   | Action              | Mode | Description                  |
| ----- | ------------------- | ---- | ---------------------------- |
| `M-l` | Accept suggestion   | i    | Apply AI suggestion          |
| `M-]` | Next suggestion     | i    | Cycle to next suggestion     |
| `M-[` | Previous suggestion | i    | Cycle to previous suggestion |
| `C-]` | Dismiss suggestion  | i    | Reject current suggestion    |

To enable auto-suggestions, set `auto_suggestions = true` in `nvim/lua/plugins/avante.lua`.

### Navigation in Avante Panel

When the Avante side panel is open:

| Key     | Action           | Description                     |
| ------- | ---------------- | ------------------------------- |
| `]]`    | Next section     | Jump to next response section   |
| `[[`    | Previous section | Jump to previous section        |
| `Tab`   | Switch panes     | Toggle between input and output |
| `S-Tab` | Reverse switch   | Switch panes in reverse         |
| `<CR>`  | Submit           | Send prompt (normal mode)       |
| `C-s`   | Submit           | Send prompt (insert mode)       |

The panel opens on the right side at 30% width with a beautiful electric border design.

### Diff Resolution

When Claude suggests code changes, you'll see a diff view with conflict markers:

| Key   | Action            | Description                      |
| ----- | ----------------- | -------------------------------- |
| `c o` | Choose ours       | Keep your original code          |
| `c t` | Choose theirs     | Accept Claude's suggestion       |
| `c a` | Choose all        | Accept all of Claude's changes   |
| `c b` | Choose both       | Keep both versions               |
| `c c` | Choose cursor     | Resolve based on cursor position |
| `]x`  | Next conflict     | Jump to next diff                |
| `[x`  | Previous conflict | Jump to previous diff            |

**Workflow:**

1. Review each suggested change
2. Navigate with `]x` / `[x`
3. Use `c o` or `c t` to accept/reject each hunk
4. Or use `c a` to accept everything at once

### UI Customization

**Vibrant spinners** show AI activity:

- Editing: Electric purple lightning bolts `⚡ ✦ ◆ ✧`
- Generating: Cyan rotation `◐ ◓ ◑ ◒`
- Thinking: Smooth dots `⠋ ⠙ ⠹ ⠸`

**Border styles:**

- Edit window: Double-line vibrant borders `╔═╗║╝═╚║`
- Ask window: Rounded neon borders `╭─╮│╯─╰│`
- Input prefix: Sharp electric arrow `▸`

All colors match the SilkCircuit neon palette for visual consistency.

### Best Practices with Avante

**1. Provide context:**

- Select relevant code before asking
- Include related functions if needed
- Reference variable names in your prompts

**2. Be specific:**

- "Add error handling for network failures" (good)
- "Make it better" (too vague)

**3. Iterative refinement:**

- Start with a broad request
- Use follow-up prompts to refine
- Build on previous responses

**4. Review before accepting:**

- Always review AI suggestions
- Test changes before committing
- Claude is smart but not perfect

**5. Use for:**

- Code explanations
- Refactoring suggestions
- Bug investigation
- Test case ideas
- Documentation help

**6. Don't use for:**

- Complete application generation
- Security-critical code without review
- Production deployments without testing

## Claude Code CLI Integration

[Claude Code](https://claude.ai/claude-code) is integrated via a terminal window, providing a full AI pair programming
experience.

### Configuration

```lua
window = {
  split_ratio = 0.4,      -- 40% of screen
  position = "botright",  -- Bottom right
  enter_insert = true,    -- Auto-enter insert mode
}
```

**Features:**

- Automatic file change detection
- Git root detection for project context
- Full terminal at 40% screen height
- Window navigation with Ctrl-h/j/k/l

### Core Keybindings

| Key         | Action                | Mode | Description                               |
| ----------- | --------------------- | ---- | ----------------------------------------- |
| `C-,`       | Toggle terminal       | n, t | Open/close Claude Code terminal           |
| `Space a c` | Toggle Claude Code    | n    | Alternative toggle                        |
| `Space c C` | Continue conversation | n    | Resume last session with `--continue`     |
| `Space c V` | Verbose mode          | n    | Full turn-by-turn output with `--verbose` |

### Using Claude Code

**Basic workflow:**

1. **Open terminal:** Press `Ctrl-,`
2. **Describe task:** Type what you want Claude to do
3. **Review changes:** Files auto-reload as Claude modifies them
4. **Continue editing:** Ask follow-up questions or refine
5. **Close terminal:** Press `Ctrl-,` again

**Example sessions:**

```bash
# Refactoring
"Refactor the user authentication system to use JWT tokens"

# Bug fixes
"There's a race condition in the payment processing. Can you find and fix it?"

# Feature implementation
"Add a dark mode toggle to the settings page with persistence"

# Code review
"Review the changes in src/api/endpoints.ts and suggest improvements"
```

### Command Variants

**Continue previous conversation:**

```
Space c C
```

Resumes where you left off, maintaining full context from previous session.

**Verbose output:**

```
Space c V
```

Shows detailed turn-by-turn output, useful for debugging or understanding Claude's process.

**Resume with picker:**

```
:ClaudeCodeResume
```

Opens interactive conversation picker to resume any previous session.

### File Watching

Claude Code automatically detects file changes:

- **Refresh enabled:** Files reload automatically
- **Update time:** 100ms while active
- **Check interval:** Every 1 second
- **Notifications:** Shows when files reload

You'll see changes in Neovim as Claude makes them, allowing real-time collaboration.

### Git Integration

When you open Claude Code:

- Automatically detects git root
- Sets working directory to project root
- Provides full project context to Claude
- Works with gitignore rules

**Pro tip:** Initialize Claude Code from your project root for best context.

### Window Management

**Navigate from terminal:**

- `C-h` - Move to left window
- `C-j` - Move to window below
- `C-k` - Move to window above
- `C-l` - Move to right window
- `C-,` - Close terminal

**Navigate from editor:**

- `C-,` - Jump to terminal
- Normal window navigation works

**Resize if needed:**

```vim
:resize +5   " Make taller
:resize -5   " Make shorter
```

Default height is 40% of screen, which works well for most workflows.

### Best Practices with Claude Code

**1. Project-wide tasks:**

- Multi-file refactoring
- Architecture changes
- Feature implementation across modules
- Dependency updates

**2. Complex debugging:**

- Issues spanning multiple files
- Race conditions and timing bugs
- Integration problems
- Performance bottlenecks

**3. Learning and exploration:**

- Understanding unfamiliar codebases
- Exploring new libraries
- Best practice questions
- Architecture discussions

**4. Workflow tips:**

- Keep terminal open while working
- Use for bigger tasks than Avante
- Combine with git for safety
- Review all changes before committing

**5. Performance:**

- Close terminal when not in use
- Clear conversation history if laggy
- Use `--continue` to avoid re-explaining context

## Combining Both AI Tools

Avante and Claude Code complement each other perfectly:

### When to Use Avante

**Quick inline tasks:**

- Single function modifications
- Code explanations
- Quick refactors
- Inline suggestions

**Advantages:**

- Faster for small edits
- Visual diff preview
- Granular control
- Less context switching

### When to Use Claude Code

**Large-scale tasks:**

- Multi-file changes
- Architecture refactoring
- Complex debugging
- Feature implementation

**Advantages:**

- Full project context
- File-level operations
- Git integration
- Persistent conversation

### Hybrid Workflows

**1. Exploration → Implementation:**

- Ask Claude Code for architecture advice
- Use Avante to implement specific pieces
- Return to Claude Code for integration

**2. Bulk → Polish:**

- Claude Code for initial feature build
- Avante for fine-tuning individual functions
- Claude Code for final integration testing

**3. Debug → Fix:**

- Claude Code to identify issue location
- Avante to fix specific bug
- Claude Code to verify fix across codebase

**4. Learn → Apply:**

- Claude Code for explanations
- Avante for inline documentation
- Both for understanding patterns

## API Configuration

### Setting API Key

**Required:** Both tools need your Anthropic API key.

```bash
# Add to ~/.zshrc or ~/.bashrc
export ANTHROPIC_API_KEY="sk-ant-..."
```

Or use a local file (not committed):

```bash
# ~/.rc.local
export ANTHROPIC_API_KEY="sk-ant-..."
```

**Check configuration:**

```vim
:lua print(vim.env.ANTHROPIC_API_KEY)
```

Should display your key (first few characters).

### Model Configuration

**Current model:** `claude-sonnet-4-20250514`

- Latest Claude Sonnet 4 (January 2025)
- Best balance of speed and intelligence
- 200K context window
- Optimized for code tasks

**To change models:**

Edit `nvim/lua/plugins/avante.lua`:

```lua
providers = {
  claude = {
    model = "claude-opus-4-5-20251101",  -- Or other model
    -- ...
  },
}
```

**Available models:**

- `claude-sonnet-4-20250514` - Recommended (fast, smart)
- `claude-opus-4-5-20251101` - Most capable (slower, pricier)
- `claude-sonnet-3-7-20241029` - Previous generation

### Rate Limits and Costs

**Be aware:**

- API calls cost money (check Anthropic pricing)
- Large codebases use more tokens
- Long conversations accumulate cost
- Consider using `temperature = 0` for consistency

**Optimize costs:**

- Use Avante for smaller tasks (fewer tokens)
- Clear Claude Code history when done
- Be specific in prompts (reduces back-and-forth)
- Review generated code (avoid regenerations)

## Troubleshooting

### Avante Not Responding

**Check API key:**

```vim
:lua print(vim.env.ANTHROPIC_API_KEY)
```

**Check network:**

```bash
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
  https://api.anthropic.com/v1/messages
```

**Restart Avante:**

```vim
:AvanteRestart
```

### Claude Code Terminal Issues

**Terminal won't open:**

```vim
:ClaudeCode
```

**Check Claude Code installation:**

```bash
which claude
claude --version
```

**Reset terminal:** Close and reopen with `Ctrl-,` twice.

### File Changes Not Detected

**Check refresh settings:**

```vim
:lua print(vim.inspect(require("claude-code").config.refresh))
```

**Manually reload:**

```vim
:e!   " Force reload current file
```

### Performance Issues

**Avante slow:**

- Reduce `max_tokens` in config
- Close unused buffers
- Restart Neovim

**Claude Code lag:**

- Use `--continue` instead of full context
- Clear old conversations
- Close terminal when not in use

## Advanced Configuration

### Custom Avante Prompts

Create custom prompts in your config:

```lua
-- nvim/lua/plugins/avante.lua
custom_prompts = {
  test = {
    prompt = "Write comprehensive tests for this code",
    system = "You are a test engineer focused on edge cases",
  },
  optimize = {
    prompt = "Optimize this code for performance",
    system = "Focus on algorithmic improvements",
  },
}
```

### Avante Window Positioning

Change side panel position:

```lua
windows = {
  position = "left",  -- or "right", "top", "bottom"
  width = 40,         -- percentage
}
```

### Disable Features

**Disable auto-suggestions:**

```lua
behaviour = {
  auto_suggestions = false,  -- Already disabled by default
}
```

**Disable auto-apply:**

```lua
behaviour = {
  auto_apply_diff_after_generation = false,  -- Require manual review
}
```

### Custom Claude Code Commands

Add custom variants in `nvim/lua/plugins/user.lua`:

```lua
command_variants = {
  continue = "--continue",
  verbose = "--verbose",
  custom = "--your-flag",  -- Add custom flags
}
```

## Security Considerations

### Code Review

**Always review AI-generated code:**

- Check for security vulnerabilities
- Verify logic correctness
- Test edge cases
- Review dependencies

**Never blindly accept:**

- Authentication/authorization code
- Cryptographic implementations
- SQL queries (SQL injection risk)
- File system operations
- Network requests

### API Key Safety

**Keep keys secure:**

- Never commit to version control
- Use environment variables
- Rotate keys regularly
- Use separate keys for different projects

**Add to .gitignore:**

```
.env
.env.local
*.key
```

### Privacy

**Be aware:**

- Code sent to Claude API is processed externally
- Conversations may be reviewed by Anthropic
- Don't share secrets, credentials, or PII
- Review Anthropic's privacy policy

**For sensitive code:**

- Use local LLMs instead
- Anonymize before sharing
- Review what context is sent

## Conclusion

This AI integration provides two powerful tools for different use cases:

- **Avante.nvim** - Quick, inline assistance with beautiful UI
- **Claude Code** - Deep, project-wide pair programming

Together, they create a comprehensive AI-assisted development workflow that enhances your productivity without getting
in the way.

**Key takeaways:**

1. Use Avante for focused, inline tasks
2. Use Claude Code for large refactors and debugging
3. Always review AI suggestions before accepting
4. Keep your API key secure
5. Combine both tools for maximum effectiveness

The future of coding is collaborative - human creativity guided by AI intelligence. This configuration makes that future
available right now, in your Neovim setup.
