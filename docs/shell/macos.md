# macOS Utilities

_Platform-specific power_

macOS-specific utilities that make the platform shine. These only load on macOS systems.

## Application Shortcuts

Quick access to common apps:

| Alias     | Application        |
| --------- | ------------------ |
| `code`    | Visual Studio Code |
| `subl`    | Sublime Text       |
| `preview` | Preview.app        |
| `xcode`   | Xcode              |
| `finder`  | Finder             |
| `chrome`  | Google Chrome      |
| `safari`  | Safari             |
| `warp`    | Warp terminal      |

Open apps from the command line. `code .` to open VS Code in current directory.

## Finder Integration

### `finder` — Open in Finder

Open directories in Finder:

```bash
finder .           # Open current directory
finder ~/Downloads # Open specific path
```

The macOS bridge between terminal and GUI.

### `ql` — Quick Look

Preview files without opening them:

```bash
ql image.png      # Preview image
ql document.pdf   # Preview PDF
ql video.mp4      # Preview video
```

Works with any file type that Quick Look supports (which is most things).

### Hidden Files Toggle

```bash
showfiles         # Show hidden files in Finder
hidefiles         # Hide them again
```

Useful when you need to see `.git` or `.env` files in Finder.

## Clipboard

### `clip` — Copy to Clipboard

Multiple input methods:

```bash
echo "text" | clip       # Pipe to clipboard
clip "direct text"       # Direct argument
cat file.txt | clip      # File contents
pwd | clip               # Current directory path
```

Wrapper around `pbcopy` that's easier to remember.

### `paste` — Paste from Clipboard

Alias for `pbpaste`:

```bash
paste                    # Output clipboard
paste > file.txt         # Save clipboard to file
```

### `copy-path` — Copy File Path

Copy absolute path of a file:

```bash
copy-path file.txt
# Copies: /Users/bliss/project/file.txt
```

Perfect for sharing file locations.

## System Control

### Volume

```bash
mute              # Mute audio
unmute            # Unmute
set-volume 50     # Set to 50%
set-volume 100    # Maximum volume
```

Control audio without touching the volume keys.

### Display

```bash
toggle-dark-mode  # Switch between light and dark mode
```

Instant theme switching.

### Network

```bash
flushdns          # Flush DNS cache
wifi-name         # Get current WiFi SSID
```

`flushdns` fixes "this site can't be reached" 90% of the time.

### System Info

```bash
macversion        # Show macOS version
battery           # Battery status (see System docs for detailed version)
list-devices      # USB/Bluetooth/Thunderbolt devices
```

## Screenshots

macOS screenshot utilities:

```bash
screenshot-area           # Select area, save to file
screenshot-area-clipboard # Select area, copy to clipboard
screenshot-screen         # Full screen to file
screenshot-window         # Select window to file
screenshot-location       # Get/set default save location
```

More convenient than remembering keyboard shortcuts.

### Screen Recording

```bash
screen-record output.mov      # Record screen to file
gif-from-recording video.mov  # Convert to GIF (requires ffmpeg)
```

Record screencasts from the terminal.

## Homebrew Services

### `brew-services` — Interactive Manager

Interactive service management with fzf:

```bash
brew-services
# fzf selection of brew services
# Shows running/stopped status
# Select to toggle state
```

No more remembering service names.

### Direct Commands

```bash
brew-services-list    # List all Homebrew services
brew-start postgres   # Start a service
brew-stop postgres    # Stop a service
brew-restart postgres # Restart a service
```

Manage databases, web servers, and other brew services.

## App Store (mas)

Requires [mas](https://github.com/mas-cli/mas):

```bash
app-search "Xcode"    # Search Mac App Store
app-install 497799835 # Install by ID (get ID from search)
app-list              # List installed App Store apps
```

Install App Store apps from the terminal. Great for automation.

## Developer Tools

```bash
xcode-select-install  # Install Command Line Tools
vsc                   # Open VS Code in current directory
```

`vsc` is an alias for `code .`—muscle memory friendly.

## Security

### `unquarantine` — Remove Quarantine Flag

Remove the "downloaded from internet" flag:

```bash
unquarantine MyApp.app
# Removes quarantine attribute
# App can now run without security prompt
```

Useful for apps from unofficial sources. Use responsibly.

## DMG Handling

### `extract-dmg` — Mount & Extract

Mount a DMG, copy contents, unmount:

```bash
extract-dmg installer.dmg
# Mounts the DMG
# Copies contents to current directory
# Unmounts automatically
```

Automates DMG extraction workflow.

## Karabiner Elements

Keyboard customization config in `macos/karabiner.json`:

- **Caps Lock** → Escape (tap) / Control (hold)
- Enhanced text editing shortcuts
- Custom application-specific shortcuts

See the karabiner.json config for full mappings.

## Yabai Window Management

Tiling window manager (requires SIP disable on some macOS versions):

```bash
# Start/stop yabai
yabai --start-service
yabai --stop-service

# Config in macos/yabairc
```

Auto-tile windows like a Linux WM. Game-changer for productivity.

## skhd Hotkeys

Keyboard shortcuts for Yabai and other system control:

```bash
# Start/stop skhd
skhd --start-service
skhd --stop-service

# Config in macos/skhdrc
```

Common default bindings:

- `alt + h/j/k/l` — Focus windows (vim-style)
- `shift + alt + h/j/k/l` — Move windows
- `alt + 1-9` — Switch to space (desktop) 1-9
- `alt + f` — Toggle fullscreen
- `alt + r` — Rotate window tree

Check `macos/skhdrc` for full bindings.

## Pro Tips

**Learn Quick Look**: `ql` is faster than opening files. Use it for quick file inspection.

**Homebrew services**: Keep databases (postgres, redis) managed by brew. Easy start/stop/restart.

**Clipboard fu**: Pipe command output to `clip`, edit in your editor, paste back. Super workflow.

**Dark mode toggle**: Map `toggle-dark-mode` to a keyboard shortcut for instant theme switching.

**Flush DNS regularly**: After changing network settings or having connection issues. `flushdns` is magic.

**Yabai + skhd**: If you're serious about window management, learn these. Vim-style window navigation is addictive.

**Use `mas` for automation**: Script your App Store installs. Great for setting up new machines.

**Karabiner for keyboard customization**: Caps Lock as Escape/Control is life-changing. Never go back to normal caps
lock.
