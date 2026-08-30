#Requires -Version 5.1
<#
.SYNOPSIS
    pkg-sync.ps1 - resolve and install packages.conf on Windows

.DESCRIPTION
    The PowerShell half of bin/pkg-sync. It reads the same packages.conf
    with the same grammar so a Windows box needs no bash, no WSL, and no
    second list to keep in step.

    Parity with the bash reader is a hard requirement, and it is one
    command to check on any machine with pwsh:

        diff <(bin/pkg-sync list winget desktop) \
             <(pwsh -NoProfile -File bin/pkg-sync.ps1 list winget desktop)

    Export lives in the bash script alone: `winget import` documents are
    read by humans and CI, and one JSON emitter is easier to trust than
    two that have to agree byte for byte.

.EXAMPLE
    .\bin\pkg-sync.ps1 list winget desktop

.EXAMPLE
    .\bin\pkg-sync.ps1 install winget desktop -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('list', 'install', 'help')]
    [string]$Command = 'help',

    [Parameter(Position = 1)]
    [string]$Manager = 'winget',

    [Parameter(Position = 2)]
    [string]$Role = '',

    [switch]$DryRun,

    [string]$Manifest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:KnownManagers = @('apt', 'pacman', 'cargo', 'ppa', 'winget')
$script:ExitCode = 0

# Write-Error under `$ErrorActionPreference = 'Stop'` terminates the whole
# script, which would turn a usage mistake into a stack trace and lose the
# exit code the bash twin uses. Go straight to stderr instead.
function Write-Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    [Console]::Error.WriteLine("[!!] pkg-sync: $Message")
    $script:ExitCode = 2
}

function Get-RepoRoot {
    Split-Path -Parent $PSScriptRoot
}

function Show-Usage {
    @'
pkg-sync.ps1 - resolve and install packages from packages.conf

usage:
  pkg-sync.ps1 list [<manager>] [<role>]
  pkg-sync.ps1 install [<manager>] [<role>] [-DryRun]

  <manager>  apt, pacman, cargo, ppa, winget. Defaults to winget.
  <role>     desktop or server. Defaults to .dotfiles_role, else desktop.

examples:
  pkg-sync.ps1 list winget desktop
  pkg-sync.ps1 install winget desktop -DryRun
'@ | Write-Output
}

<#
.SYNOPSIS
    Resolve packages.conf down to one package per line.
.DESCRIPTION
    A line-for-line mirror of the awk resolver in bin/pkg-sync: strip the
    CR and the comment, trim, skip blanks and [sections], then read each
    source token as <manager>[=<package>][@<roles>]. The @ is split before
    the = so apt=git-core@server reads the way it looks. Order is manifest
    order and duplicates are dropped across the whole file, both of which
    the parity check depends on.
#>
function Resolve-Manifest {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ManagerName,
        [Parameter(Mandatory = $true)][string]$RoleName
    )

    $seen = @{}
    $resolved = New-Object System.Collections.Generic.List[string]
    $lineNumber = 0

    foreach ($rawLine in [System.IO.File]::ReadAllLines($Path)) {
        $lineNumber++
        $line = $rawLine -replace "`r$", ''
        $line = $line -replace '#.*', ''
        $line = $line.Trim()
        if ($line -eq '') { continue }
        if ($line.StartsWith('[')) { continue }

        $fields = $line -split '\s+'
        if ($fields.Count -lt 3) {
            throw "pkg-sync: $Path line ${lineNumber}: expected <name> <roles> <source>..."
        }

        $name = $fields[0]
        $roles = $fields[1]
        $selected = New-Object System.Collections.Generic.List[string]

        foreach ($field in $fields[2..($fields.Count - 1)]) {
            $token = $field
            if ($token.StartsWith('bin=')) { continue }

            $scope = $roles
            $at = $token.IndexOf('@')
            if ($at -ge 0) {
                $scope = $token.Substring($at + 1)
                $token = $token.Substring(0, $at)
            }

            $package = $name
            $eq = $token.IndexOf('=')
            if ($eq -ge 0) {
                $package = $token.Substring($eq + 1)
                $token = $token.Substring(0, $eq)
            }

            if ($script:KnownManagers -notcontains $token) {
                throw "pkg-sync: $Path line ${lineNumber}: unknown manager: '$token'"
            }
            if ($token -ne $ManagerName) { continue }
            if (",$scope," -notlike "*,$RoleName,*") { continue }
            if ($package -eq '') {
                throw "pkg-sync: $Path line ${lineNumber}: empty package name"
            }
            $selected.Add($package)
        }

        foreach ($package in $selected) {
            if ($seen.ContainsKey($package)) { continue }
            $seen[$package] = $true
            $resolved.Add($package)
        }
    }

    return $resolved
}

function Get-DefaultRole {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    $roleFile = Join-Path $RepoRoot '.dotfiles_role'
    if (Test-Path -LiteralPath $roleFile) {
        $first = (Get-Content -LiteralPath $roleFile -TotalCount 1)
        if ($first) {
            $trimmed = ($first -replace '\s', '')
            if ($trimmed) { return $trimmed }
        }
    }
    return 'desktop'
}

<#
.SYNOPSIS
    Install the resolved winget ids, one at a time.
.DESCRIPTION
    Per package rather than per batch, so one retired id cannot sink the
    run. That is the same skip-with-a-warning contract the apt path in
    bin/pkg-sync keeps. --id with -e matches the identifier exactly
    instead of fuzzy-matching a display name.
#>
function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string[]]$Ids,
        [switch]$WhatIfOnly
    )

    if (-not $WhatIfOnly -and -not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warning "winget not found, skipping $($Ids.Count) package(s)"
        return
    }

    foreach ($id in $Ids) {
        $wingetArgs = @(
            'install', '--id', $id, '-e',
            '--accept-package-agreements', '--accept-source-agreements'
        )
        if ($WhatIfOnly) {
            Write-Output "  winget $($wingetArgs -join ' ')"
            continue
        }
        Write-Output "  winget install $id"
        & winget @wingetArgs
        # winget returns a non-zero code for "already installed" as well as
        # for a genuine failure, so the exit code only decides whether to
        # say something, never whether to stop.
        if ($LASTEXITCODE -ne 0) {
            Write-Output "[warn] skipped: $id (winget exit $LASTEXITCODE)"
        }
    }
}

function Invoke-Main {
    if ($Command -eq 'help') {
        Show-Usage
        return
    }

    $repoRoot = Get-RepoRoot
    $manifestPath = $Manifest
    if (-not $manifestPath) {
        if ($env:PKG_MANIFEST) {
            $manifestPath = $env:PKG_MANIFEST
        }
        else {
            $manifestPath = Join-Path $repoRoot 'packages.conf'
        }
    }
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        Write-Fail "manifest not found: $manifestPath"
        return
    }

    if ($script:KnownManagers -notcontains $Manager) {
        Write-Fail "unknown manager: $Manager"
        return
    }

    $resolvedRole = $Role
    if (-not $resolvedRole) { $resolvedRole = Get-DefaultRole -RepoRoot $repoRoot }

    # The resolver throws on a malformed row. Catch it so a bad manifest
    # reads as one line on stderr and exit 2, the way the bash twin does,
    # instead of a PowerShell stack trace and exit 1.
    try {
        $packages = Resolve-Manifest -Path $manifestPath -ManagerName $Manager -RoleName $resolvedRole
    }
    catch {
        [Console]::Error.WriteLine($_.Exception.Message)
        $script:ExitCode = 2
        return
    }

    if ($Command -eq 'list') {
        foreach ($package in $packages) { Write-Output $package }
        return
    }

    if ($Manager -ne 'winget') {
        Write-Fail "install is winget only on Windows, got: $Manager"
        return
    }

    if ($packages.Count -eq 0) {
        Write-Output ">> no winget packages for role $resolvedRole"
        return
    }

    Write-Output ">> installing winget packages for role $resolvedRole"
    Install-WingetPackage -Ids $packages -WhatIfOnly:$DryRun
}

# Invoke-Main writes the package list to the success stream, so the exit
# code rides a script variable rather than a return value. `exit (Invoke-Main)`
# would swallow every line it printed.
Invoke-Main
exit $script:ExitCode
