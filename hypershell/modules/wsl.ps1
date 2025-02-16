# WSL (Windows Subsystem for Linux) integration

# Function to run Linux commands from PowerShell
function Invoke-WSLCommand {
    wsl.exe -e $args
}
Set-Alias -Name wsl -Value Invoke-WSLCommand

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