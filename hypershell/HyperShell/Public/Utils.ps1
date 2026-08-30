# Small Unix-shaped utilities.
#
# Aliases: touch mkdir tail find

<#
.SYNOPSIS
    Creates an empty file, the way touch does.
#>
function New-File {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)]
        [string]$Path
    )

    if (-not $Path) {
        Write-Warning 'Usage: touch <filename>'
        return
    }

    if ($PSCmdlet.ShouldProcess($Path, 'Create file')) {
        New-Item -ItemType File -Path $Path
    }
}

<#
.SYNOPSIS
    Creates a directory and every missing parent, the way mkdir -p does.
#>
function New-Directory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    if ($PSCmdlet.ShouldProcess($Path, 'Create directory')) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

<#
.SYNOPSIS
    Follows the tail of a file.
#>
function Get-Tail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [int]$Lines = 10
    )

    Get-Content -Path $Path -Tail $Lines -Wait
}

<#
.SYNOPSIS
    Finds files under the current directory whose name matches a pattern.
.DESCRIPTION
    The PowerShell stand-in for GNU find. On Windows the `find` alias prefers
    a real find.exe when one is installed and only falls back to this.
#>
function Find-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pattern
    )

    Get-ChildItem -Recurse | Where-Object { $_.Name -match $Pattern }
}

Add-HyperShellAlias -Name 'touch' -Value 'New-File' -Shadow
Add-HyperShellAlias -Name 'mkdir' -Value 'New-Directory' -Shadow
Add-HyperShellAlias -Name 'tail' -Value 'Get-Tail' -Shadow

# GNU find.exe wins when Aliases.ps1 found one; this is the fallback.
if ('find' -notin $script:HyperShellAlias) {
    Add-HyperShellAlias -Name 'find' -Value 'Find-File' -Shadow
}
