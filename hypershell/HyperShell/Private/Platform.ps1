# Platform detection shared by every HyperShell command.
#
# HyperShell targets Windows, but it has to load cleanly on macOS and Linux so
# the module can be tested without a Windows box. Commands that wrap a
# Windows-only cmdlet call Test-HyperShellWindows and bail out with a warning
# instead of exploding on a missing command.

# Cached once at import. Tests flip this to exercise both branches.
$script:HyperShellIsWindows = [bool]$IsWindows

<#
.SYNOPSIS
    Reports whether HyperShell is running on Windows.
.DESCRIPTION
    Returns $true on Windows. On every other platform it returns $false and,
    when -Feature is supplied, warns that the feature needs Windows. The
    warning is the point: a caller that hits this gets told why nothing
    happened rather than a confusing missing-cmdlet error.
.EXAMPLE
    if (-not (Test-HyperShellWindows -Feature 'DNS cache flush')) { return }
#>
function Test-HyperShellWindows {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0)]
        [string]$Feature
    )

    if ($script:HyperShellIsWindows) {
        return $true
    }

    if ($Feature) {
        Write-Warning "$Feature needs Windows. HyperShell skipped it on this platform."
    }

    return $false
}

<#
.SYNOPSIS
    Tests whether an external command is on PATH.
.DESCRIPTION
    A thin wrapper over Get-Command so callers do not repeat the
    -ErrorAction SilentlyContinue dance, and so tests have one seam to mock.
#>
function Test-HyperShellCommand {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )

    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}
