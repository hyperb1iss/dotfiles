# zoxide integration.
#
# https://github.com/ajeetdsouza/zoxide
#
# zoxide's init script declares its functions and the z alias in the global
# scope, so the module can install it from a function. The profile calls
# Initialize-HyperShellZoxide; importing the module does not, because a shell
# integration has no business running inside a script or a test.

<#
.SYNOPSIS
    Returns zoxide's PowerShell init script.
.DESCRIPTION
    Returns $null when zoxide is not installed. The z command is used rather
    than zoxide's default cd override, matching the Unix side.
#>
function Get-HyperShellZoxideInitScript {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (-not (Test-HyperShellCommand -Name 'zoxide')) {
        return $null
    }

    try {
        return ((zoxide init powershell --cmd z) -join "`n")
    }
    catch {
        Write-Warning "HyperShell could not read the zoxide init script: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Installs zoxide's z command into the session.
.EXAMPLE
    Initialize-HyperShellZoxide
#>
function Initialize-HyperShellZoxide {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not $PSCmdlet.ShouldProcess('zoxide', 'Install shell integration')) {
        return
    }

    $init = Get-HyperShellZoxideInitScript
    if (-not $init) {
        Write-Warning "zoxide not found. Install it with your package manager or 'cargo install zoxide'."
        return
    }

    . ([scriptblock]::Create($init))
}
