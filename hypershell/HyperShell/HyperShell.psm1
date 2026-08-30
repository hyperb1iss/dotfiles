# HyperShell.psm1
#
# HyperShell: a Linux-inspired PowerShell environment.
#
# Copyright (c) 2024 Stefanie Jane
# Licensed under the MIT License. See LICENSE file for more info.
#
# https://github.com/hyperb1iss/dotfiles
#
# Loading order is Private then Public, alphabetical within each. Private
# files hold shared state and pure helpers; Public files define the commands
# and register their aliases through Add-HyperShellAlias.
#
# Importing this module only defines things. Anything that touches the live
# session (the prompt, zoxide, PSReadLine) is a function the profile calls, so
# an import stays quiet in scripts and CI.

$script:HyperShellRoot = $PSScriptRoot

$manifest = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'HyperShell.psd1')
$script:HyperShellVersion = $manifest.ModuleVersion

foreach ($folder in @('Private', 'Public')) {
    $folderPath = Join-Path $PSScriptRoot $folder
    if (-not (Test-Path -LiteralPath $folderPath)) {
        continue
    }

    foreach ($file in (Get-ChildItem -LiteralPath $folderPath -Filter '*.ps1' | Sort-Object -Property Name)) {
        try {
            . $file.FullName
        }
        catch {
            throw "HyperShell failed to load $($file.Name): $($_.Exception.Message)"
        }
    }
}

Import-HyperShellCompanionModule

# The manifest is the source of truth for functions. Aliases are whatever
# survived the platform rules in Add-HyperShellAlias, so a shadowing alias
# such as ls or cat never reaches a macOS or Linux session.
Export-ModuleMember -Function $manifest.FunctionsToExport -Alias @($script:HyperShellAlias)
