# Keybindings

Everything hangs off `Space`; press it and let which-key show the rest

Notation: `Space` is the leader, `,` the local leader, `C-x` is Ctrl, `S-x` is Shift. Mode is normal unless a table says
otherwise. Mappings marked (ours) come from `nvim/lua/plugins/`; the rest are AstroNvim v6 defaults.

## Which-key groups

| Prefix    | Group               |
| --------- | ------------------- |
| `Space a` | Claude (ours)       |
| `Space b` | Buffers             |
| `Space d` | Debugger            |
| `Space f` | Find                |
| `Space g` | Git                 |
| `Space l` | Language tools      |
| `Space O` | Octo, GitHub (ours) |
| `Space p` | Packages            |
| `Space S` | Sessions            |
| `Space t` | Terminal            |
| `Space u` | UI toggles          |
| `Space x` | Trouble and lists   |

## Files and windows

| Key                                | Action                                 |
| ---------------------------------- | -------------------------------------- |
| `Space w`                          | Save                                   |
| `Space q`                          | Quit window                            |
| `Space Q`                          | Exit Neovim                            |
| `Space n`                          | New file                               |
| `Space R`                          | Rename file                            |
| `Space h`                          | Home screen (dashboard)                |
| `Space e`                          | Toggle Neo-tree                        |
| `Space o`                          | Focus Neo-tree                         |
| `\|` / `\\`                        | Vertical / horizontal split            |
| `C-h` `C-j` `C-k` `C-l`            | Move between splits (also in terminal) |
| `C-Up` `C-Down` `C-Left` `C-Right` | Resize split                           |

Inside Neo-tree: `a` add, `A` add directory, `d` delete, `r` rename, `y` `x` `p` copy, cut, paste, `c` `m` copy or move
to a path, `Y` copy path picker, `s` vsplit, `S` split, `t` tab, `w` open with window picker, `H` toggle hidden, `/`
filter, `.` set root, `Backspace` up a level, `[g` `]g` previous or next modified file, `P` preview, `?` help.

## Buffers and tabs

| Key         | Action                                                |
| ----------- | ----------------------------------------------------- |
| `]b` / `[b` | Next / previous buffer                                |
| `Space c`   | Close buffer                                          |
| `Space C`   | Force close buffer                                    |
| `Space bd`  | Pick a buffer to close from the tabline               |
| `Space bC`  | Close all buffers                                     |
| `Space bp`  | Previous buffer                                       |
| `Space bs*` | Sort buffers by extension, path, number, modification |
| `Space fb`  | Find buffers (picker)                                 |
| `]t` / `[t` | Next / previous tab                                   |

## Find (snacks picker)

| Key             | Action                         |
| --------------- | ------------------------------ |
| `Space ff`      | Files                          |
| `Space fF`      | All files, including hidden    |
| `Space fw`      | Grep the project               |
| `Space fW`      | Grep including hidden files    |
| `Space fc`      | Grep the word under the cursor |
| `Space fs`      | Smart: buffers, recent, files  |
| `Space fo`      | Recent files                   |
| `Space fO`      | Recent files in cwd            |
| `Space fg`      | Git files                      |
| `Space fp`      | Projects                       |
| `Space fl`      | Lines in the buffer            |
| `Space fh`      | Help tags                      |
| `Space fk`      | Keymaps                        |
| `Space fC`      | Commands                       |
| `Space fm`      | Man pages                      |
| `Space fr`      | Registers                      |
| `Space f'`      | Marks                          |
| `Space fu`      | Undo history                   |
| `Space fn`      | Notifications                  |
| `Space ft`      | Colorschemes                   |
| `Space fT`      | TODO comments                  |
| `Space fa`      | AstroNvim config files         |
| `Space f Enter` | Resume the last picker         |

In a picker: `C-j` / `C-k` move, `Enter` open, `C-v` vsplit, `C-s` split, `C-t` send to Trouble, `Esc` close.

## Language tools

| Key         | Action                            |
| ----------- | --------------------------------- |
| `gd`        | Definition                        |
| `gD`        | Declaration (ours)                |
| `gI`        | Implementation                    |
| `gy`        | Type definition                   |
| `gK`        | Signature help                    |
| `K`         | Hover                             |
| `gl`        | Hover diagnostics                 |
| `Space la`  | Code action (also in visual mode) |
| `Space lA`  | Source action                     |
| `Space lr`  | Rename symbol                     |
| `Space lR`  | References                        |
| `Space lf`  | Format buffer with conform (ours) |
| `Space lc`  | Conform info (ours)               |
| `Space ld`  | Hover diagnostics                 |
| `Space lD`  | Search diagnostics                |
| `Space ls`  | Search document symbols           |
| `Space lS`  | Symbols outline (aerial)          |
| `Space lG`  | Search workspace symbols          |
| `Space lh`  | Signature help                    |
| `Space li`  | LSP info                          |
| `Space ll`  | CodeLens refresh                  |
| `Space lL`  | CodeLens run                      |
| `Space lv`  | Select Python virtualenv          |
| `]d` / `[d` | Next / previous diagnostic        |
| `]e` / `[e` | Next / previous error             |
| `]w` / `[w` | Next / previous warning           |

Completion in insert mode: `C-Space` open or toggle docs, `C-n` / `C-p` or `C-j` / `C-k` move, `Enter` accept, `Tab` /
`S-Tab` next or previous snippet field, `C-u` / `C-d` scroll docs, `C-e` dismiss.

## Trouble and lists

| Key         | Action                            |
| ----------- | --------------------------------- |
| `Space xx`  | Trouble: buffer diagnostics       |
| `Space xX`  | Trouble: workspace diagnostics    |
| `Space xt`  | Trouble: TODO comments            |
| `Space xT`  | Trouble: TODO, FIX and FIXME only |
| `Space xL`  | Trouble: location list            |
| `Space xQ`  | Trouble: quickfix list            |
| `Space xq`  | Open quickfix list                |
| `Space xl`  | Open location list                |
| `]T` / `[T` | Next / previous TODO comment      |

Inside Trouble: `j` / `k` move, `Enter` jump, `q` or `Esc` close.

## Git

| Key         | Action                               |
| ----------- | ------------------------------------ |
| `Space gg`  | Lazygit (ours)                       |
| `Space tl`  | Lazygit (ours)                       |
| `Space gf`  | Lazygit history for this file (ours) |
| `Space go`  | Open the file on GitHub              |
| `Space gb`  | Git branches                         |
| `Space gc`  | Git commits                          |
| `Space gC`  | Git commits for this buffer          |
| `Space gt`  | Git status                           |
| `Space gT`  | Git stash                            |
| `Space gl`  | Blame line (gitsigns)                |
| `Space gp`  | Preview hunk                         |
| `Space gh`  | Reset hunk                           |
| `Space gr`  | Reset buffer                         |
| `Space gs`  | Stage hunk                           |
| `Space gS`  | Stage buffer                         |
| `Space gu`  | Unstage hunk                         |
| `Space gd`  | Diff this file                       |
| `]g` / `[g` | Next / previous hunk                 |
| `]G` / `[G` | Last / first hunk                    |

## Octo (GitHub)

| Key        | Action               |
| ---------- | -------------------- |
| `Space Oo` | Octo picker          |
| `Space Oi` | List issues          |
| `Space OI` | Search issues        |
| `Space Op` | List pull requests   |
| `Space OP` | Search pull requests |
| `Space Or` | Start a review       |
| `Space Oa` | Run a workflow       |
| `Space On` | Notifications        |

Inside an Octo buffer, `,` is the local leader: `,ca` comment, `,ic` close, `,io` reopen, `,po` checkout PR, `,pm`
merge, `,vs` start review, `,vr` resume review, `C-r` reload, `C-b` open in browser. `:Octo` with no arguments lists
every command.

## Claude

| Key        | Mode   | Action                                  |
| ---------- | ------ | --------------------------------------- |
| `Space as` | visual | Send selection to Claude                |
| `Space as` | normal | In Neo-tree: send the file under cursor |
| `Space ab` | normal | Add the current buffer                  |
| `Space aa` | normal | Accept the open diff                    |
| `Space ad` | normal | Deny the open diff                      |
| `Space ai` | normal | Connection status                       |

## Terminal

| Key                     | Action                                     |
| ----------------------- | ------------------------------------------ |
| `F7`                    | Toggle terminal (normal, insert, terminal) |
| `Space tf`              | Floating terminal                          |
| `Space th`              | Horizontal terminal                        |
| `Space tv`              | Vertical terminal                          |
| `C-h` `C-j` `C-k` `C-l` | Leave the terminal toward a split          |

All of these use snacks.nvim. Toggleterm is disabled.

## Editing

| Key                 | Action                                |
| ------------------- | ------------------------------------- |
| `Space /`           | Toggle comment (normal and visual)    |
| `gco` / `gcO`       | Comment below / above                 |
| `Tab` / `S-Tab`     | Indent / unindent selection (visual)  |
| `jj` / `jk`         | Leave insert mode                     |
| `]r` / `[r`         | Next / previous reference of the word |
| `af` `if` `ac` `ic` | Function and class text objects       |
| `Space u(`          | Toggle rainbow delimiters (buffer)    |
| `Space u)`          | Toggle rainbow delimiters (global)    |

## UI toggles

| Key         | Action                              |
| ----------- | ----------------------------------- |
| `Space ub`  | Background light / dark             |
| `Space uc`  | Completion (buffer)                 |
| `Space uC`  | Completion (global)                 |
| `Space ud`  | Diagnostics                         |
| `Space uD`  | Dismiss notifications               |
| `Space uf`  | Autoformat (buffer)                 |
| `Space uF`  | Autoformat (global, off by default) |
| `Space ug`  | Sign column                         |
| `Space uh`  | Inlay hints (buffer)                |
| `Space ui`  | Indent setting                      |
| `Space ul`  | Statusline                          |
| `Space uL`  | CodeLens                            |
| `Space un`  | Line numbering                      |
| `Space up`  | Paste mode                          |
| `Space ur`  | Reference highlighting              |
| `Space us`  | Spellcheck                          |
| `Space uS`  | Conceal                             |
| `Space ut`  | Tabline                             |
| `Space uu`  | URL highlight                       |
| `Space uv`  | Virtual text                        |
| `Space uw`  | Wrap                                |
| `Space uY`  | Semantic highlighting (buffer)      |
| `Space uZ`  | Zen mode                            |
| `Space u\|` | Toggle indent guides                |

## Sessions and packages

| Key        | Action                  |
| ---------- | ----------------------- |
| `Space Sl` | Load last session       |
| `Space Ss` | Save session            |
| `Space St` | Save this tab's session |
| `Space Sf` | Load a session          |
| `Space Sd` | Delete a session        |
| `Space pi` | Lazy install            |
| `Space ps` | Lazy status             |
| `Space pS` | Lazy sync               |
| `Space pu` | Lazy check updates      |
| `Space pU` | Lazy update             |
| `Space pa` | Update Lazy and Mason   |
| `Space pm` | Mason                   |
| `Space pM` | Mason tools update      |

## Debugger

| Key                  | Action                      |
| -------------------- | --------------------------- |
| `F5` / `Space dc`    | Start or continue           |
| `F9` / `Space db`    | Toggle breakpoint           |
| `F10` / `Space do`   | Step over                   |
| `F11` / `Space di`   | Step into                   |
| `S-F11` / `Space dO` | Step out                    |
| `F6` / `Space dp`    | Pause                       |
| `S-F5` / `Space dQ`  | Terminate                   |
| `Space dB`           | Clear breakpoints           |
| `Space dr`           | Restart                     |
| `Space dR`           | Toggle REPL                 |
| `Space ds`           | Run to cursor               |
| `Space du`           | Toggle debugger UI          |
| `Space dh`           | Hover value                 |
| `Space dE`           | Evaluate selection (visual) |
