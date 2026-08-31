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
        [Parameter(Position = 0, ValueFromRemainingArguments)]
        [Alias('file')]
        [string[]]$Path
    )

    if (-not $Path) {
        Write-Warning 'Usage: touch <filename>'
        return
    }

    # ValueFromRemainingArguments is what makes `touch a b c` work, but it
    # also swallows a mistyped parameter name as a literal filename, so
    # `touch -notaparam x` would quietly create a file called -notaparam.
    # Anything that looks like a parameter is rejected instead.
    $looksLikeParameter = @($Path | Where-Object { $_ -like '-*' })
    if ($looksLikeParameter) {
        Write-Error "Not a parameter of touch: $($looksLikeParameter -join ', '). For a file whose name starts with a dash, use ./$($looksLikeParameter[0])"
        return
    }

    foreach ($item in $Path) {
        if ($PSCmdlet.ShouldProcess($item, 'Create file')) {
            New-Item -ItemType File -Path $item
        }
    }
}

<#
.SYNOPSIS
    Creates a directory and every missing parent, the way mkdir -p does.
#>
function New-Directory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Not Mandatory: that would prompt for input on a bare `mkdir`, which
        # hangs a script. The original errored out instead, so this does too.
        [Parameter(Position = 0)]
        [string]$Path
    )

    if (-not $Path) {
        Write-Error 'Usage: mkdir <directory>'
        return
    }

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
        [Alias('file')]
        [string]$Path,

        # No [Alias('lines')] here: parameter names are case insensitive, so
        # aliasing Lines to itself makes every call fail to bind. -lines
        # already works by case-insensitive match.
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

<#
.SYNOPSIS
    Stops processes by name, the way unix pkill does.
.DESCRIPTION
    Stop-Process binds an integer id positionally, so aliasing pkill
    straight to it broke the muscle-memory call shape `pkill node`.
    This wrapper matches process names instead.
#>
function Stop-ProcessByName {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )

    $procs = @(Get-Process -Name "*$Name*" -ErrorAction SilentlyContinue)
    if ($procs.Count -eq 0) {
        Write-Warning "No processes match '$Name'"
        return
    }

    foreach ($proc in $procs) {
        if ($PSCmdlet.ShouldProcess("$($proc.ProcessName) ($($proc.Id))", 'Stop-Process')) {
            Stop-Process -Id $proc.Id
        }
    }
}

Add-HyperShellAlias -Name 'touch' -Value 'New-File' -Shadow
Add-HyperShellAlias -Name 'mkdir' -Value 'New-Directory' -Shadow
Add-HyperShellAlias -Name 'tail' -Value 'Get-Tail' -Shadow

# GNU find.exe wins when Aliases.ps1 found one; this is the fallback.
if ('find' -notin $script:HyperShellAlias) {
    Add-HyperShellAlias -Name 'find' -Value 'Find-File' -Shadow
}
