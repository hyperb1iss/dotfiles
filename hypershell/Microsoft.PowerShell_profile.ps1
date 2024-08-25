# HyperShell PowerShell Profile

# Load oh-my-posh
oh-my-posh init pwsh --config '$env:USERPROFILE\oh-my-posh-dracula\dracula.omp.json' | Invoke-Expression

# Import modules
Import-Module PSReadLine
Import-Module posh-git

# Configure PSReadLine for Linux-style keybindings
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Enable syntax highlighting
Set-PSReadLineOption -Colors @{
    Command = 'Cyan'
    Parameter = 'DarkCyan'
    Operator = 'DarkGray'
    Variable = 'Green'
    String = 'Yellow'
    Number = 'Magenta'
    Type = 'DarkYellow'
    Comment = 'DarkGreen'
}

# FZF Configuration
$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"

# Function to update the terminal title
function Update-Title {
    param(
        [string]$Title
    )
    $host.UI.RawUI.WindowTitle = $Title
}

# Function to get the current directory name
function Get-CurrentDirectoryName {
    return (Get-Item -Path $PWD).Name
}

# Update title on directory change
function Set-LocationWithTitleUpdate {
    param([string]$path)
    Set-Location $path
    Update-Title "HyperShell - $(Get-CurrentDirectoryName)"
}
Set-Alias -Name cd -Value Set-LocationWithTitleUpdate -Option AllScope -Force

# Update title before executing a command
$ExecutionContext.InvokeCommand.PreCommandHook = {
    param($command)
    $cmdName = $command.CommandOrigin
    Update-Title "HyperShell - $cmdName - $(Get-CurrentDirectoryName)"
}

# Update title after executing a command
$ExecutionContext.InvokeCommand.PostCommandHook = {
    Update-Title "HyperShell - $(Get-CurrentDirectoryName)"
}

# Initial title update
Update-Title "HyperShell - $(Get-CurrentDirectoryName)"

# LSD aliases
function Invoke-LSD {
    lsd $args
}
Set-Alias -Name ls -Value Invoke-LSD -Option AllScope -Force

function Invoke-LSDLong {
    lsd -l $args
}
Set-Alias -Name ll -Value Invoke-LSDLong -Option AllScope -Force

function Invoke-LSDAll {
    lsd -la $args
}
Set-Alias -Name la -Value Invoke-LSDAll -Option AllScope -Force

function Invoke-LSDTree {
    lsd --tree $args
}
Set-Alias -Name lt -Value Invoke-LSDTree -Option AllScope -Force

# Linux-like aliases
Set-Alias -Name grep -Value Select-String
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name less -Value more
Set-Alias -Name which -Value Get-Command
Set-Alias -Name wget -Value Invoke-WebRequest
Set-Alias -Name pkill -Value Stop-Process
Set-Alias -Name ifconfig -Value ipconfig

# Touch command
function New-File {
    param([string]$file)
    if($file) {
        New-Item -ItemType File -Name $file
    } else {
        Write-Host "Usage: touch <filename>"
    }
}
Set-Alias -Name touch -Value New-File

# Mkdir command (creates full path)
function Make-Directory {
    param([string]$path)
    New-Item -ItemType Directory -Force -Path $path
}
Set-Alias -Name mkdir -Value Make-Directory

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
    } else {
        $global:__LastLocation = $PWD
        Set-Location $path
    }
    Update-Title "HyperShell - $(Get-CurrentDirectoryName)"
}
Set-Alias -Name cd -Value Set-LocationWithHistory -Option AllScope -Force

# Clear screen
function Clear-Host-Custom {
    Clear-Host
    oh-my-posh init pwsh --config 'C:/Users/Stefanie/oh-my-posh-dracula/dracula.omp.json' | Invoke-Expression
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
        [Parameter(Mandatory=$true)][string]$file,
        [int]$lines = 10
    )
    Get-Content -Tail $lines -Wait $file
}
Set-Alias -Name tail -Value Get-Tail

# Find command
function Find-Files {
    param(
        [Parameter(Mandatory=$true)][string]$pattern
    )
    Get-ChildItem -Recurse | Where-Object { $_.Name -match $pattern }
}
Set-Alias -Name find -Value Find-Files

# FZF Functions

# FZF Find File
function fzf-find-file {
    $file = Get-ChildItem -Recurse | Where-Object { -not $_.PSIsContainer } | Select-Object -ExpandProperty FullName | fzf
    if ($file) {
        Invoke-Item $file
    }
}
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { fzf-find-file }

# FZF Change Directory
function fzf-cd {
    $dir = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName | fzf
    if ($dir) {
        Set-Location $dir
    }
}
Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock { fzf-cd }

# FZF History Search
function fzf-history {
    $command = Get-Content (Get-PSReadLineOption).HistorySavePath | fzf
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock { fzf-history }

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

# Git Integration Improvements

# Git status shorthand
function Get-GitStatus { git status }
Set-Alias -Name gst -Value Get-GitStatus

# Git add shorthand
function Add-GitChanges { git add $args }
Set-Alias -Name ga -Value Add-GitChanges

# Git commit shorthand
function Commit-GitChanges { git commit -m $args }
Set-Alias -Name gco -Value Commit-GitChanges

# Git push shorthand
function Push-GitChanges { git push $args }
Set-Alias -Name gpp -Value Push-GitChanges

# Git cherry-pick shorthand
function Cherry-Pick-GitChanges { git cherry-pick $args }
Set-Alias -Name gcp -Value Cherry-Pick-GitChanges

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

# Load any additional configuration files
if (Test-Path "$env:USERPROFILE\Documents\PowerShell\user_profile.ps1") {
    . "$env:USERPROFILE\Documents\PowerShell\user_profile.ps1"
}

Write-Host "HyperShell loaded successfully!" -ForegroundColor Green
