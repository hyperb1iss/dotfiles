# Alias registration policy.
#
# Every HyperShell alias goes through Add-HyperShellAlias so that one place
# decides what gets exported. Two rules matter:
#
#   -Shadow          the alias covers a name that already means something else
#                    (a PowerShell built-in alias, or a real binary on Unix).
#                    Those are registered on Windows only. On macOS and Linux,
#                    shadowing `ls`, `cat`, or `find` would break the system
#                    tools the rest of the environment depends on.
#   -RequireCommand  the alias points at an external binary, so it is only
#                    registered when that binary resolves.
#
# The names that survive both rules are collected here and handed to
# Export-ModuleMember by HyperShell.psm1.

$script:HyperShellAlias = [System.Collections.Generic.List[string]]::new()

<#
.SYNOPSIS
    Registers a HyperShell alias and marks it for export.
.DESCRIPTION
    Applies the platform and availability rules described above, then creates
    the alias in module scope. Aliases that are skipped are simply absent, so
    the module never exports a name that does not resolve.
.PARAMETER Shadow
    The alias covers an existing command name, so it is Windows-only.
.PARAMETER RequireCommand
    Only register when the alias target resolves as a command.
#>
function Add-HyperShellAlias {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name,

        [Parameter(Mandatory, Position = 1)]
        [string]$Value,

        [switch]$Shadow,

        [switch]$RequireCommand
    )

    if ($Shadow -and -not $script:HyperShellIsWindows) {
        return
    }

    if ($RequireCommand -and -not (Test-HyperShellCommand -Name $Value)) {
        return
    }

    Set-Alias -Name $Name -Value $Value -Scope Script -Force
    $script:HyperShellAlias.Add($Name)
}
