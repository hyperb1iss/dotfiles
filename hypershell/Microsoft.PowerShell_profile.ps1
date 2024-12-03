# Microsoft.PowerShell_profile.ps1
# HyperShell: A high-tech, Linux-inspired environment for Windows PowerShell
# https://github.com/hyperbliss/dotfiles/hypershell

function Show-HyperShellStartup {
    $esc = [char]27
    $version = "1.0.0"
    
    Write-Host "$esc[38;5;213m⟨$esc[38;5;207m⟨$esc[38;5;201m⟨ $esc[1m$esc[38;5;219m☆ $esc[38;5;159mHYPER$esc[38;5;213mSHELL$esc[38;5;219m::$esc[38;5;123m$version $esc[22m$esc[38;5;201m⟩$esc[38;5;207m⟩$esc[38;5;213m⟩$esc[0m"
    Write-Host ""
}

# Load Starship prompt
Invoke-Expression (&starship init powershell)

# Import modules
Import-Module PSReadLine
Import-Module posh-git
Import-Module Terminal-Icons

# Configure PSReadLine for Linux-style keybindings
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Enable syntax highlighting
Set-PSReadLineOption -Colors @{
    Command   = [ConsoleColor]::Cyan
    Parameter = [ConsoleColor]::DarkCyan
    Operator  = [ConsoleColor]::DarkGray
    Variable  = [ConsoleColor]::Green
    String    = [ConsoleColor]::Yellow
    Number    = [ConsoleColor]::Magenta
    Type      = [ConsoleColor]::DarkYellow
    Comment   = [ConsoleColor]::DarkGreen
}

# FZF Configuration
$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Function to normalize a path for display
function Get-NormalizedPath {
    param([string]$Path)
    
    # Get the user's home directory path
    $homePath = $HOME
    
    # Check if the path starts with the home directory
    if ($Path.StartsWith($homePath)) {
        # Replace the home path with ~
        return $Path.Replace($homePath, "~")
    }
    
    return $Path
}

# Function to get the current directory name with proper normalization
function Get-CurrentDirectoryName {
    $normalizedPath = Get-NormalizedPath -Path $PWD.Path
    return (Split-Path -Leaf $normalizedPath)
}

# Function to update the terminal title
function Update-Title {
    param([string]$Title)
    $host.UI.RawUI.WindowTitle = $Title
}

# Function to update location with title update
function Set-LocationWithTitleUpdate {
    param([string]$path)
    Set-Location $path
    $normalizedPath = Get-NormalizedPath -Path $PWD.Path
    Update-Title "HyperShell - $normalizedPath"
}

# Set up the location change hook
Set-Alias -Name cd -Value Set-LocationWithTitleUpdate -Option AllScope -Force

# Initial title update
$initialPath = Get-NormalizedPath -Path $PWD.Path
Update-Title "HyperShell - $initialPath"

# LSD aliases
function Invoke-LSD { lsd $args }
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
New-Alias -Name ls -Value Invoke-LSD -Force

function Invoke-LSDLong { lsd -l $args }
New-Alias -Name ll -Value Invoke-LSDLong -Force

function Invoke-LSDAll { lsd -la $args }
New-Alias -Name la -Value Invoke-LSDAll -Force

function Invoke-LSDTree { lsd --tree $args }
New-Alias -Name lt -Value Invoke-LSDTree -Force

# Use real GNU tools when available
if (Get-Command grep.exe -ErrorAction SilentlyContinue) { New-Alias -Name grep -Value grep.exe -Force }
if (Get-Command find.exe -ErrorAction SilentlyContinue) { New-Alias -Name find -Value find.exe -Force }
if (Get-Command sed.exe -ErrorAction SilentlyContinue) { New-Alias -Name sed -Value sed.exe -Force }
if (Get-Command awk.exe -ErrorAction SilentlyContinue) { New-Alias -Name awk -Value awk.exe -Force }

# Other Linux-like aliases
Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
New-Alias -Name cat -Value bat -Force
New-Alias -Name less -Value bat -Force
New-Alias -Name which -Value Get-Command -Force
New-Alias -Name wget -Value Invoke-WebRequest -Force
New-Alias -Name pkill -Value Stop-Process -Force
New-Alias -Name ifconfig -Value ipconfig -Force

# Touch command
function New-File {
    param([string]$file)
    if ($file) {
        New-Item -ItemType File -Name $file
    }
    else {
        Write-Host "Usage: touch <filename>"
    }
}
New-Alias -Name touch -Value New-File -Force

# Mkdir command (creates full path)
function New-Directory {
    param([string]$path)
    New-Item -ItemType Directory -Force -Path $path
}
New-Alias -Name mkdir -Value New-Directory -Force

# Function to create directory and change into it
function mkcd {
    param([string]$path)
    New-Item -ItemType Directory -Path $path
    Set-Location -Path $path
}

# Enhance 'cd' to support 'cd -' (go to previous directory)
$global:__LastLocation = $PWD
function Set-LocationWithHistory {
    param([string]$path)
    if ($path -eq '-') {
        $tmp = $PWD
        Set-Location $global:__LastLocation
        $global:__LastLocation = $tmp
    }
    else {
        $global:__LastLocation = $PWD
        Set-Location $path
    }
    Update-Title "HyperShell - $(Get-CurrentDirectoryName)"
}
Set-Alias -Name cd -Value Set-LocationWithHistory -Option AllScope -Force

# Clear screen
function Clear-Host-Custom {
    Clear-Host
    Show-HyperShellStartup
}
Set-Alias -Name clear -Value Clear-Host-Custom

# History command
function Get-History-Custom {
    Get-History | Select-Object -Property CommandLine
}
Set-Alias -Name history -Value Get-History-Custom

# Tail command
function Get-Tail {
    param(
        [Parameter(Mandatory = $true)][string]$file,
        [int]$lines = 10
    )
    Get-Content -Tail $lines -Wait $file
}
Set-Alias -Name tail -Value Get-Tail

# Find command
function Find-Files {
    param(
        [Parameter(Mandatory = $true)][string]$pattern
    )
    Get-ChildItem -Recurse | Where-Object { $_.Name -match $pattern }
}
Set-Alias -Name find -Value Find-Files

# FZF Functions
function Find-FzfFile {
    $file = Get-ChildItem -Recurse | 
        Where-Object { -not $_.PSIsContainer } | 
        Select-Object -ExpandProperty FullName | 
        fzf --preview 'bat.exe --color=always --style=numbers --line-range=:500 {}'
    if ($file) {
        bat $file
    }
}
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { Find-FzfFile }

function Set-FzfLocation {
    $dir = Get-ChildItem -Directory | 
        Select-Object -ExpandProperty FullName | 
        fzf --preview 'dir /a /w "{}"'
    if ($dir) {
        Set-Location $dir
    }
}
Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock { Set-FzfLocation }

function Get-FzfHistory {
    $command = Get-Content (Get-PSReadLineOption).HistorySavePath | 
        fzf --tac --no-sort
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock { Get-FzfHistory }

# WSL Integration

# Function to run Linux commands from PowerShell
function wsl {
    wsl.exe $args
}

# Function to easily switch to WSL
function Enter-WSL {
    wsl ~
}
Set-Alias -Name wsld -Value Enter-WSL

# Function to convert Windows path to WSL path
function ConvertTo-WSLPath {
    param (
        [string]$WindowsPath
    )
    $wslPath = wsl wslpath -u "'$WindowsPath'"
    return $wslPath.Trim()
}

# Function to convert WSL path to Windows path
function ConvertFrom-WSLPath {
    param (
        [string]$WSLPath
    )
    $windowsPath = wsl wslpath -w "'$WSLPath'"
    return $windowsPath.Trim()
}

# Function to open Windows Explorer from WSL path
function Open-WSLFolder {
    param (
        [string]$WSLPath
    )
    $windowsPath = ConvertFrom-WSLPath $WSLPath
    explorer.exe $windowsPath
}
Set-Alias -Name wslopen -Value Open-WSLFolder

# WSL command function
function Invoke-WslCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    wsl $Command
}

# WSL command functions
function Invoke-WslGrep { wsl grep $args }
function Invoke-WslFind { wsl find $args }
function Invoke-WslSed { wsl sed $args }
function Invoke-WslAwk { wsl awk $args }

# WSL command aliases
New-Alias -Name wgrep -Value Invoke-WslGrep -Force
New-Alias -Name wfind -Value Invoke-WslFind -Force
New-Alias -Name wsed -Value Invoke-WslSed -Force
New-Alias -Name wawk -Value Invoke-WslAwk -Force

# Git Integration Improvements

# Git status shorthand
function Get-GitStatus { git status }
Set-Alias -Name gst -Value Get-GitStatus

# Git add shorthand
function Add-GitChanges { git add $args }
Set-Alias -Name ga -Value Add-GitChanges

# Git commit shorthand
function Invoke-GitChanges { git commit -m $args }
Set-Alias -Name gco -Value Invoke-GitChanges

# Git push shorthand
function Push-GitChanges { git push $args }
Set-Alias -Name gpp -Value Push-GitChanges

# Git cherry-pick shorthand
function Invoke-GitCherryPick { git cherry-pick $args }
Set-Alias -Name gcp -Value Invoke-GitCherryPick

# Docker Integration (if installed)
if (Get-Command docker -ErrorAction SilentlyContinue) {
    function Show-DockerContainers { docker ps $args }
    Set-Alias -Name dps -Value Show-DockerContainers

    function Show-DockerImages { docker images $args }
    Set-Alias -Name di -Value Show-DockerImages
}

# Improved Tab Completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Better error display
$PSStyle.Formatting.Error = "$([char]0x1b)[91m"
$PSStyle.Formatting.ErrorAccent = "$([char]0x1b)[91;1m"

# Function to update system PATH
function Update-SystemPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Function to add a directory to system PATH
function Add-ToPath {
    param (
        [string]$Directory
    )
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$Directory*") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$Directory", "User")
        Update-SystemPath
        Write-Host "Added $Directory to PATH." -ForegroundColor Green
    }
    else {
        Write-Host "$Directory is already in PATH." -ForegroundColor Yellow
    }
}

# Function to remove a directory from system PATH
function Remove-FromPath {
    param (
        [string]$Directory
    )
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -like "*$Directory*") {
        $newPath = ($currentPath.Split(';') | Where-Object { $_ -ne $Directory }) -join ';'
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Update-SystemPath
        Write-Host "Removed $Directory from PATH." -ForegroundColor Green
    }
    else {
        Write-Host "$Directory is not in PATH." -ForegroundColor Yellow
    }
}

# Load any additional configuration files
if (Test-Path "$env:USERPROFILE\Documents\PowerShell\user_profile.ps1") {
    . "$env:USERPROFILE\Documents\PowerShell\user_profile.ps1"
}

# Function to reload the profile
function Update-Profile {
    . $PROFILE
}
Set-Alias -Name reload -Value Update-Profile

# Run the startup sequence
Show-HyperShellStartup

# End of HyperShell PowerShell Profile

# Enhanced FZF Functions (inspired by fzf.sh)

# Interactive file finder with preview
function Find-FzfFileWithPreview {
    $file = Get-ChildItem -Recurse | Where-Object { -not $_.PSIsContainer } |
    Select-Object -ExpandProperty FullName |
    fzf --preview 'bat.exe --color=always --style=numbers --line-range=:500 {}' |
    ForEach-Object { $_.Trim() }
    if ($file) {
        bat $file
    }
}
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { Find-FzfFileWithPreview }

# Interactive directory navigation
function Set-FzfLocationWithPreview {
    $previewCmd = 'powershell.exe -NoProfile -Command "Get-ChildItem -Force \"{}\" | Format-Wide -AutoSize | Out-String"'
    
    $dir = Get-ChildItem -Directory -Recurse |
    Select-Object -ExpandProperty FullName |
    fzf --preview "$previewCmd" |
    ForEach-Object { $_.Trim() }
    if ($dir) {
        Set-Location $dir
    }
}
Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock { Set-FzfLocationWithPreview }

# Interactive process kill
function Stop-FzfProcess {
    $process = Get-Process |
    Format-Table -AutoSize |
    Out-String -Stream |
    fzf --header-lines=3 --multi --preview 'echo {}' |
    ForEach-Object { ($_ -split '\s+')[1] }

    if ($process) {
        $process | ForEach-Object {
            Stop-Process -Id $_ -Force
            Write-Host "Killed process with ID: $_"
        }
    }
}
Set-Alias -Name fkill -Value Stop-FzfProcess

# Enhanced Git Functions (inspired by git.sh)

# Interactive git add
function Add-FzfGitChanges {
    $files = git status -s |
    fzf --multi --preview 'git diff --color=always {2}' |
    ForEach-Object { 
        $line = $_
        if ($line -match '^\s*[MADRCU\?]+ (.+)$') {
            $matches[1]
        }
    }

    if ($files) {
        $files | ForEach-Object { 
            Write-Host "Adding $_"
            git add $_
        }
        git status -s
    }
}
Set-Alias -Name gadd -Value Add-FzfGitChanges

# Interactive git checkout branch
function Switch-FzfGitBranch {
    $branch = git branch --all |
    Where-Object { $_ -notmatch 'HEAD' } |
    fzf --preview 'git log --color=always {}' |
    ForEach-Object { $_.TrimStart('* ').TrimStart().Replace('remotes/origin/', '') }

    if ($branch) {
        git checkout $branch
    }
}
Set-Alias -Name gco -Value Switch-FzfGitBranch

# Interactive git log browser
function Show-FzfGitLog {
    $commit = git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
    fzf --ansi --no-sort --reverse --tiebreak=index |
    ForEach-Object { ($_ -split '\s+')[0] }

    if ($commit) {
        git show --color=always $commit | bat --style=numbers --paging=always
    }
}
Set-Alias -Name glog -Value Show-FzfGitLog

# Additional Git aliases (from git.sh)
function Get-GitStatus { git status }
Set-Alias -Name gst -Value Get-GitStatus

function Add-GitChanges { git add $args }
Set-Alias -Name ga -Value Add-GitChanges

function Invoke-GitCommit { git commit -m $args }
Set-Alias -Name gcom -Value Invoke-GitCommit

function Push-GitChanges { git push $args }
Set-Alias -Name gpsh -Value Push-GitChanges

function Invoke-GitPull { git pull $args }
Set-Alias -Name gpull -Value Invoke-GitPull

function Invoke-GitFetch { git fetch --all --prune }
Set-Alias -Name gf -Value Invoke-GitFetch

function Invoke-GitCheckout { git checkout $args }
Set-Alias -Name gco -Value Invoke-GitCheckout

# Directory navigation functions (from directory.sh)
function New-DirectoryAndEnter {
    param([string]$path)
    New-Item -ItemType Directory -Path $path -Force
    Set-Location -Path $path
}
Set-Alias -Name mkcd -Value New-DirectoryAndEnter

function Set-LocationUp {
    param([int]$levels = 1)
    $path = ".."
    for ($i = 1; $i -lt $levels; $i++) {
        $path = Join-Path $path ".."
    }
    Set-Location $path
}
Set-Alias -Name up -Value Set-LocationUp
