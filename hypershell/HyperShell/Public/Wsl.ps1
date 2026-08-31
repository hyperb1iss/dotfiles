# WSL integration.
#
# Aliases: wsld
#
# wsl.exe only exists on Windows, so every command here is guarded.

<#
.SYNOPSIS
    Drops into WSL at the Linux home directory.
#>
function Enter-WSL {
    [CmdletBinding()]
    param()

    if (-not (Test-HyperShellWindows -Feature 'WSL')) {
        return
    }

    wsl ~
}

<#
.SYNOPSIS
    Converts a Windows path to its WSL equivalent.
.EXAMPLE
    ConvertTo-WSLPath -WindowsPath 'C:\dev\dotfiles'   # /mnt/c/dev/dotfiles
#>
function ConvertTo-WSLPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$WindowsPath
    )

    if (-not (Test-HyperShellWindows -Feature 'WSL path conversion')) {
        return $null
    }

    return (wsl wslpath -u "'$WindowsPath'").Trim()
}

<#
.SYNOPSIS
    Converts a WSL path to its Windows equivalent.
#>
function ConvertFrom-WSLPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$WSLPath
    )

    if (-not (Test-HyperShellWindows -Feature 'WSL path conversion')) {
        return $null
    }

    return (wsl wslpath -w "'$WSLPath'").Trim()
}

Add-HyperShellAlias -Name 'wsld' -Value 'Enter-WSL'
