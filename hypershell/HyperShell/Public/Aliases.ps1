# Command aliases and Linux-flavoured replacements.
#
# Aliases: ls ll la lt cat less which wget pkill ifconfig clear history
#          grep sed awk find
#
# Most of these shadow a name that already exists, so they register on Windows
# only. See Private/Alias.ps1 for the policy.

<#
.SYNOPSIS
    Runs lsd, the Rust ls replacement.
#>
function Invoke-LSD {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    lsd @Arguments
}

<#
.SYNOPSIS
    Long directory listing via lsd.
#>
function Invoke-LSDLong {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    lsd -l @Arguments
}

<#
.SYNOPSIS
    Long directory listing including dotfiles, via lsd.
#>
function Invoke-LSDAll {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    lsd -la @Arguments
}

<#
.SYNOPSIS
    Tree listing via lsd.
#>
function Invoke-LSDTree {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    lsd --tree @Arguments
}

<#
.SYNOPSIS
    Prints files through bat with no pager.
#>
function Invoke-Cat {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    bat --style=plain --pager=never @Arguments
}

<#
.SYNOPSIS
    Clears the screen and reprints the HyperShell banner when it is due.
#>
function Clear-HyperShellHost {
    [CmdletBinding()]
    param()

    Clear-Host
    Show-HyperShellStartup
}

<#
.SYNOPSIS
    Lists shell history as bare command lines, the way `history` does on Unix.
#>
function Get-HyperShellHistory {
    [CmdletBinding()]
    param()

    Get-History | Select-Object -Property CommandLine
}

# lsd wrappers. `ls` shadows the built-in alias; the rest are new names.
Add-HyperShellAlias -Name 'ls' -Value 'Invoke-LSD' -Shadow
Add-HyperShellAlias -Name 'll' -Value 'Invoke-LSDLong'
Add-HyperShellAlias -Name 'la' -Value 'Invoke-LSDAll'
Add-HyperShellAlias -Name 'lt' -Value 'Invoke-LSDTree'

# Real GNU tools when the Chocolatey packages put them on PATH.
foreach ($gnuTool in @('grep', 'sed', 'awk', 'find')) {
    Add-HyperShellAlias -Name $gnuTool -Value "$gnuTool.exe" -Shadow -RequireCommand
}

# Unix muscle memory for the rest.
Add-HyperShellAlias -Name 'cat' -Value 'Invoke-Cat' -Shadow
Add-HyperShellAlias -Name 'less' -Value 'bat' -Shadow
Add-HyperShellAlias -Name 'which' -Value 'Get-Command' -Shadow
Add-HyperShellAlias -Name 'wget' -Value 'Invoke-WebRequest' -Shadow
Add-HyperShellAlias -Name 'pkill' -Value 'Stop-Process' -Shadow
Add-HyperShellAlias -Name 'ifconfig' -Value 'ipconfig' -Shadow
Add-HyperShellAlias -Name 'clear' -Value 'Clear-HyperShellHost' -Shadow
Add-HyperShellAlias -Name 'history' -Value 'Get-HyperShellHistory' -Shadow
