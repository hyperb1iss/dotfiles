# Microsoft.PowerShell_profile.ps1
#
# HyperShell: a Linux-inspired PowerShell environment
#
# Copyright (c) 2024 Stefanie Jane
# Licensed under the MIT License. See LICENSE file for more info.
#
# https://github.com/hyperb1iss/dotfiles
#
# Every command lives in the HyperShell module. This file only wires the
# module into a live session: keybindings, prompt, zoxide, banner.

# The installer links hypershell/HyperShell into a PSModulePath directory, so
# the plain module name normally resolves. The fallbacks cover running
# straight out of a checkout, which is how the module gets tested on macOS.
$hyperShellModule = $null
if (Get-Module -ListAvailable -Name HyperShell) {
    $hyperShellModule = 'HyperShell'
}
else {
    $candidates = @(
        (Join-Path $PSScriptRoot 'HyperShell')
        $(if ($env:DOTFILES) { Join-Path -Path $env:DOTFILES -ChildPath 'hypershell' -AdditionalChildPath 'HyperShell' })
        (Join-Path -Path $HOME -ChildPath 'dev' -AdditionalChildPath 'dotfiles', 'hypershell', 'HyperShell')
    )

    $hyperShellModule = $candidates |
        Where-Object { $_ -and (Test-Path -LiteralPath (Join-Path $_ 'HyperShell.psd1')) } |
        Select-Object -First 1
}

if (-not $hyperShellModule) {
    Write-Warning 'HyperShell module not found. Run the dotfiles installer, or set $env:DOTFILES to your checkout.'
    return
}

Import-Module -Name $hyperShellModule -ErrorAction Stop

# Interactive setup. Importing the module defines commands and nothing else,
# so these three calls are what turn a bare session into HyperShell.
Set-HyperShellPSReadLineOption
Initialize-HyperShellPrompt
Initialize-HyperShellZoxide

# Banner and inspiration quote, once a day.
if (Show-HyperShellStartup -PassThru) {
    Show-HyperShellInspiration
}
