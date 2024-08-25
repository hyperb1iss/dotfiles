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

## 🌟 Features

| Feature | Description |
|---------|-------------|
| 🐚 Zsh | Customized Zsh setup with aliases, functions, and environment variables |
| 📝 AstroNVim | Powerful Neovim configuration for an IDE-like experience |
| 🖥️ Tmux | Enhanced terminal multiplexer setup |
| 🌳 Git | Personalized Git settings and aliases |
| 🚀 Starship | Beautiful and informative command prompt with a custom Dracula-inspired theme |
| 📂 LSDeluxe (lsd) | Modern replacement for `ls` with color-coding and icons |
| 🔍 FZF | Fuzzy finder for enhanced file and history searching |
| 💾 WSL2 Backup | Automated backup script for Windows Subsystem for Linux |
| 🔷 HyperShell | A Linux-like PowerShell experience for Windows |

## 🛠 Installation

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
├── hypershell/           # HyperShell configuration for PowerShell
└── README.md             # You are here!
```

## 🎨 Customization

Feel free to explore and modify any of the configuration files to suit your needs. The modular structure allows for easy customization and extension.

### 🌈 Starship Theme

The Starship prompt uses a custom theme based on the pastel-powerline theme, with colors inspired by the Dracula theme. You can find the configuration in `starship.toml`. 

For more information on customizing Starship, visit the [Starship documentation](https://starship.rs/).

## 🔧 Dependencies

Most dependencies will be installed automatically when you run `make`. However, ensure you have the following core tools installed:

- Make
- Git

## 🖥 Windows PowerShell Setup (HyperShell)

The `hypershell/` directory contains the configuration for HyperShell, providing a Linux-like experience in PowerShell. To set it up:

1. Ensure you have PowerShell 7+ installed
2. Copy the contents of `hypershell/Microsoft.PowerShell_profile.ps1` to your PowerShell profile
3. Install the required modules:
   ```powershell
   Install-Module -Name PSReadLine -Force -SkipPublishCheck
   Install-Module -Name posh-git -Force
   ```
4. Install Starship for PowerShell:
   ```powershell
   winget install --id Starship.Starship
   ```

## 🔄 Updating

To update the dotfiles repository:

```bash
cd ~/dev/dotfiles
git pull
make
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

## 🤝 Contributing

If you have suggestions for improvements or find any issues, please feel free to open an issue or submit a pull request!

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

Created by [Stefanie Jane 🌠](https://github.com/hyperb1iss)

If you like my work, [buy me a Monster Ultra Violet](https://ko-fi.com/hyperb1iss)! ⚡️

</div>
