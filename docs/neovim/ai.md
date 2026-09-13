# AI Integration

Claude Code in a herdr pane, Neovim as its IDE

Claude does not live inside the editor. It runs in its own [herdr](https://herdr.dev) pane next to Neovim, and
[claudecode.nvim](https://github.com/coder/claudecode.nvim) turns Neovim into an IDE that Claude can attach to. The
plugin starts a WebSocket server and writes a lock file under `~/.claude/ide/`; Claude Code's `/ide` command finds it
and connects. From then on Claude sees your open buffers, your visual selection and your diagnostics, and its edits come
back as diffs you review in Neovim.

## Setup

`nvim/lua/plugins/claudecode.lua` loads the plugin on `VeryLazy` with `terminal.provider = "none"`, which means the
plugin never spawns a Claude terminal of its own. Nothing else to configure: no API key, no model choice. Claude Code
authenticates itself.

## Workflow

1. Open a project in a herdr workspace, Neovim in one pane and `claude` in a sibling pane.
2. In Claude, run `/ide`. It lists the Neovim instance and connects. `Space a i` in Neovim confirms the connection.
3. Work as usual. Claude already knows the file you are in and where your cursor sits.
4. Select code and press `Space a s` to hand the selection to Claude as context. `Space a b` sends the whole buffer. In
   Neo-tree, `Space a s` sends the file under the cursor.
5. When Claude proposes an edit, a diff opens in a new tab. `Space a a` accepts it, `Space a d` sends it back.

## Keybindings

| Key         | Mode   | Action                                  |
| ----------- | ------ | --------------------------------------- |
| `Space a s` | visual | Send selection to Claude                |
| `Space a s` | normal | In Neo-tree: send the file under cursor |
| `Space a b` | normal | Add the current buffer                  |
| `Space a a` | normal | Accept the open Claude diff             |
| `Space a d` | normal | Deny the open Claude diff               |
| `Space a i` | normal | Show connection status                  |

Commands behind them: `:ClaudeCodeSend`, `:ClaudeCodeTreeAdd`, `:ClaudeCodeAdd %`, `:ClaudeCodeDiffAccept`,
`:ClaudeCodeDiffDeny`, `:ClaudeCodeStatus`. `:ClaudeCodeStart` and `:ClaudeCodeStop` control the server by hand.

## Diffs

Diffs open vertically in a new tab so the editing window stays put. Accepting writes the change to the buffer; denying
leaves the file untouched and tells Claude. `:ClaudeCodeCloseAllDiffs` clears any that pile up.

## Troubleshooting

- `/ide` shows nothing: check `Space a i`. If the server is stopped, `:ClaudeCodeStart`. Both processes need the same
  `$HOME`, since the lock file lives under `~/.claude/ide/`.
- Claude connected to the wrong Neovim: each instance writes its own lock file, and `/ide` lists them by working
  directory. Pick the one whose cwd matches.
- Selection not arriving: `track_selection` is on by default, but the plugin only tracks the buffer that has focus.
  Focus the editor pane before selecting.
