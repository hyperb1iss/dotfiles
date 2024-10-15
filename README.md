# 🌠 Stefanie's Dotfiles

<p align="center">
  <img src="https://img.shields.io/badge/Shell-Zsh-informational?style=flat&logo=gnu-bash&logoColor=white&color=2bbc8a">
  <img src="https://img.shields.io/badge/Editor-AstroNvim-informational?style=flat&logo=neovim&logoColor=white&color=2bbc8a">
  <img src="https://img.shields.io/badge/Terminal-Tmux-informational?style=flat&logo=tmux&logoColor=white&color=2bbc8a">
  <img src="https://img.shields.io/badge/Prompt-Starship-informational?style=flat&logo=starship&logoColor=white&color=2bbc8a">
  <img src="https://img.shields.io/badge/OS-Linux%20%7C%20WSL2%20%7C%20Windows-informational?style=flat&logo=windows&logoColor=white&color=2bbc8a">
</p>

Hey there! Welcome to my personal dotfiles repository! I'm **Stefanie Jane**, aka **hyperb1iss**—a creative tech enthusiast based in Seattle. This collection of configuration files and scripts helps me quickly set up and maintain a consistent development environment across different machines, including Linux, WSL2, and Windows with PowerShell.

<p align="center">
  <img src="https://github.com/hyperb1iss/elektra/blob/main/screenshot.png" alt="Starship + Elektra" width="600" />
</p>

<p align="center">
  <img src="images/terminal-bliss.png" alt="Terminal Bliss" width="600" />
</p>

## 🌟 Features

| Feature                                                                          | Description                                                                   |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| 🐚 [Zsh](https://www.zsh.org/)                                                   | Customized Zsh setup with aliases, functions, and environment variables       |
| 📝 [AstroNVim](https://astronvim.com/)                                           | Powerful Neovim configuration for an IDE-like experience                      |
| 🖥️ [Tmux](https://github.com/tmux/tmux)                                          | Enhanced terminal multiplexer setup with custom theme and plugins             |
| 🌳 [Git](https://git-scm.com/)                                                   | Personalized Git settings and aliases                                         |
| 🚀 [Starship](https://starship.rs/)                                              | Beautiful and informative command prompt with a custom Dracula-inspired theme |
| 📂 [LSDeluxe (lsd)](https://github.com/Peltoche/lsd)                             | Modern replacement for `ls` with color-coding and icons                       |
| 🔍 [FZF](https://github.com/junegunn/fzf)                                        | Fuzzy finder for enhanced file and history searching                          |
| 💾 [WSL2 Backup](https://github.com/hyperb1iss/dotfiles/blob/main/wsl_backup.sh) | Automated backup script for Windows Subsystem for Linux                       |
| 🔷 [HyperShell](https://github.com/hyperb1iss/dotfiles/tree/main/hypershell)     | A Linux-like PowerShell experience for Windows                                |
| 🖼️ [Macchina](https://github.com/Macchina-CLI/macchina)                          | System information display with custom Elektra theme                          |
| 🤖 [Dotbot](https://github.com/anishathalye/dotbot)                              | Automated dotfiles installation and management                                |

## 🛠 Installation

### Linux/WSL2

1. Clone this repository:

   ```bash
   git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
   ```

2. Run the installation script:

   ```bash
   cd ~/dev/dotfiles
   make
   ```

   This will set up everything and install the necessary dependencies.

### Windows

1. Clone this repository:

   ```powershell
   git clone https://github.com/hyperb1iss/dotfiles.git $env:USERPROFILE\dev\dotfiles
   ```

2. Run the installation script as administrator:

   ```powershell
   cd $env:USERPROFILE\dev\dotfiles
   .\install.ps1
   ```

   This will set up the Windows environment and install HyperShell.

## 🔤 Installing Nerd Fonts

Nerd Fonts are required for proper icon display in the terminal. These are not
automatically installed by dotbot. Follow these steps to install them:

1. Visit the [Nerd Fonts website](https://www.nerdfonts.com/).
2. Download your preferred font.
3. Extract the downloaded zip file.
4. Install the fonts:
   - On Windows: Right-click on each `.ttf` file and select "Install".
   - On macOS: Double-click each `.ttf` file and click "Install Font".
   - On Linux: Copy the `.ttf` files to `~/.local/share/fonts/` and run `fc-cache -fv`.
5. Configure your terminal to use the installed Nerd Font.

For WSL2 users, make sure to set the Nerd Font in your Windows Terminal settings as well.

## 📁 What's Inside

```
dotfiles/
├── zsh/                  # Zsh configuration files
├── nvim/                 # AstroNVim configuration
├── tmux.conf             # Tmux configuration
├── gitconfig             # Git configuration
├── starship.toml         # Starship prompt configuration
├── lsd/                  # LSDeluxe configuration
├── wsl_backup.sh         # WSL2 backup script
├── hypershell/           # HyperShell environment for PowerShell
├── elektra/              # Elektra theme for Macchina
├── install.bat           # Windows installation script
├── windows.yaml          # Dotbot configuration for Windows
├── setup-windows.ps1     # PowerShell script for Windows setup
└── README.md             # You are here!
```

## 🔷 Windows Setup (HyperShell)

HyperShell provides a Linux-like experience in PowerShell, enhancing productivity and ease of use for developers familiar with Unix-like environments.

### Features:

- Customized prompt using Starship with a Dracula-inspired theme
- Linux-style command aliases (e.g., `ls`, `grep`, `cat`)
- Enhanced directory navigation with `cd -` support
- Fuzzy finding for files, directories, and command history using fzf
- Improved tab completion and syntax highlighting
- WSL integration for seamless interaction between Windows and Linux environments
- Git and Docker shortcuts for quick operations

### What's Included:

- PowerShell Core
- Windows Terminal
- Git
- Visual Studio Code (with extensions)
- Node.js
- Python
- Rust
- FZF
- Ripgrep
- Bat
- LSD
- Starship
- Neovim
- GNU CoreUtils
- Grep, Find, Sed, Awk
- Curl, Wget
- 7-Zip
- WSL2 support

### Setup Process:

1. The `install.bat` script initiates the Dotbot installation process for Windows.
2. `windows.yaml` defines the Dotbot configuration for Windows, including symlinks and shell commands.
3. `setup-windows.ps1` is executed to:
   - Install Chocolatey (if not present)
   - Install/upgrade necessary tools and applications
   - Set up PowerShell modules
   - Configure Git
   - Install VS Code extensions
   - Add directories to PATH
   - Enable Developer Mode

After installation, restart your PowerShell session to ensure all changes take effect.

## 🎨 Customization

Feel free to explore and modify any of the configuration files to suit your needs. The modular structure allows for easy customization and extension.

### 🌈 Starship Theme

The Starship prompt uses a custom theme based on the pastel-powerline theme, with colors inspired by the Dracula theme. You can find the configuration in `starship.toml`.

For more information on customizing Starship, visit the [Starship documentation](https://starship.rs/).

### 🖼️ Macchina and Elektra Theme

[Macchina](https://github.com/Macchina-CLI/macchina) is a system information fetcher, and Elektra is a custom theme I've created for it. The Elektra theme provides a visually appealing display of system information, as seen in the screenshot above. Macchina and the Elektra theme are automatically set up during installation.

### 🖥️ Tmux Configuration

My tmux setup enhances productivity with custom keybindings, mouse support, and a sleek status bar. Key features include:

- Mouse support for easy pane resizing and scrolling
- Custom split pane shortcuts (| for vertical, - for horizontal)
- Easy config reload with `prefix + r`
- Alt+arrow keys for pane navigation without prefix
- Increased scrollback buffer (5000 lines)
- Window and pane indices start at 1 for easier switching
- Catppuccin theme via the Tmux2K plugin
- Custom status bar with git, CPU, network, and time information

The full configuration can be found in `tmux.conf`.

## 🔧 Dependencies

Most dependencies will be installed automatically when you run `make` (for Linux/WSL2) or `install.bat` (for Windows). However, ensure you have the following core tools installed:

- Make (for Linux/WSL2)
- Git
- PowerShell 7+ (for Windows)

## 🔄 Updating

To update the dotfiles repository:

```bash
cd ~/dev/dotfiles
git pull
make  # For Linux/WSL2
# Or
.\install.bat  # For Windows (run as administrator)
```

## 🐧 WSL2 Backup

The `wsl_backup.sh` script provides an easy way to create incremental backups of your WSL2 environment. To use it:

1. Ensure you have a backup directory set up (default is `/mnt/d/WSL2_Backups`)
2. Run the script:
   ```bash
   ~/dev/dotfiles/wsl_backup.sh
   ```

## 🚀 Other Projects

If you like these dotfiles, you might be interested in some of my other projects:

- [git-iris](https://github.com/hyperb1iss/git-iris): An AI-accelerated git workflow tool
- [signalrgb-homeassistant](https://github.com/hyperb1iss/signalrgb-homeassistant): SignalRGB integration for Home Assistant
- [signalrgb-python](https://github.com/hyperb1iss/signalrgb-python): Python API client for SignalRGB Pro
- [hyper-light-card](https://github.com/hyperb1iss/hyper-light-card): Custom card for controlling SignalRGB through Home Assistant
- [contexter](https://github.com/hyperb1iss/contexter): Chrome extension and CLI for quickly copying code into LLMs
- [elektra](https://github.com/hyperb1iss/elektra): A custom Macchina theme for system information display

## 🤝 Contributing

If you have suggestions for improvements or find any issues, please feel free to open an issue or submit a pull request!

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

Created by [Stefanie Jane 🌠](https://github.com/hyperb1iss)

If you like my work, [buy me a Monster Ultra Violet](https://ko-fi.com/hyperb1iss)! ⚡️

</div>
