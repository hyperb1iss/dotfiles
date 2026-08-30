#Requires -Version 5.1
<#
.SYNOPSIS
    install.ps1 - the Windows `make install`

.DESCRIPTION
    Everything the Makefile does on Linux and macOS, done here for
    Windows: initialize the submodules, install the packages the manifest
    resolves for this role, compose the dotbot layers, and record the
    role in .dotfiles_role.

    Windows composes exactly one layer, dotbot.d/os/windows.yaml. base
    and role/desktop link unix paths (~/.zshrc, ~/.bashrc.local, ~/bin)
    and shell out to bash for the SilkCircuit installer, so the Windows
    layer carries its own copy of the handful of links worth sharing.

    -Role therefore narrows the winget package set and decides what lands
    in .dotfiles_role. It does not change which layers compose, because
    there is only the one.

    Administrator is detected, never demanded. The steps that genuinely
    need elevation say so and are skipped with a note when it is missing,
    so an unelevated run still installs the whole user environment.

.PARAMETER Role
    desktop (default) or server. Selects the winget rows in packages.conf
    and is written to .dotfiles_role, which the shell reads to decide how
    much to load.

.PARAMETER SkipPackages
    Link and configure without touching winget. What CI wants, and what
    you want on a re-run that only changed a config file.

.PARAMETER SkipSubmodules
    Leave dotbot and tpm at whatever revision is checked out.

.PARAMETER DryRun
    Print the winget commands and the dotbot invocation instead of
    running them.

.EXAMPLE
    .\install.ps1

.EXAMPLE
    .\install.ps1 -Role server -SkipPackages
#>
# This script is a console installer: the coloured progress lines are its
# user interface, not data anyone pipes. Write-Output here would mix the
# banner into a caller's object stream.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Progress output for an interactive installer')]
[CmdletBinding()]
param(
    [ValidateSet('desktop', 'server')]
    [string]$Role = 'desktop',

    [switch]$SkipPackages,

    [switch]$SkipSubmodules,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:RepoRoot = $PSScriptRoot
$script:ExitCode = 0

# $IsWindows only exists from PowerShell 6, and this script still has to
# run under the 5.1 that ships in the box.
$script:OnWindows = $true
if (Test-Path Variable:\IsWindows) { $script:OnWindows = (Get-Variable IsWindows -ValueOnly) }

# -------------------------------------------------------------
# Output
# -------------------------------------------------------------
function Write-Step {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host ">> $Message" -ForegroundColor Magenta
}

function Write-Note {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "  $Message" -ForegroundColor DarkGray
}

function Write-Skip {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "-- $Message" -ForegroundColor Yellow
}

function Write-Ok {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[ok] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[!!] $Message" -ForegroundColor Red
}

# -------------------------------------------------------------
# Environment
# -------------------------------------------------------------

<#
.SYNOPSIS
    True when this process is elevated.
.DESCRIPTION
    Called once and cached. The Windows identity API does not exist off
    Windows, so a pwsh run on macOS or Linux answers false rather than
    throwing, which keeps the script lintable and dry-runnable anywhere.
#>
function Test-Admin {
    if (-not $script:OnWindows) { return $false }
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Get-PythonCommand {
    foreach ($candidate in @('python', 'python3', 'py')) {
        $found = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($found) { return $found.Source }
    }
    return $null
}

<#
.SYNOPSIS
    Put a Python on PATH, because dotbot is written in it.
.DESCRIPTION
    winget is the bootstrap and the only one. If it is missing there is
    nothing sensible left to try, so the caller gets a message and a
    non-zero exit rather than a half-finished install.
#>
function Install-Python {
    Write-Step 'Python is missing, installing it with winget'

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Fail 'winget is unavailable. Install Python by hand and re-run.'
        return $null
    }

    & winget install --id Python.Python.3.12 -e `
        --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Note "winget exited $LASTEXITCODE; checking PATH anyway"
    }

    # A fresh winget install lands in the machine and user PATH, neither
    # of which this process has read since it started.
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"

    return Get-PythonCommand
}

# -------------------------------------------------------------
# Steps
# -------------------------------------------------------------

function Initialize-Submodule {
    Write-Step 'Updating submodules'
    if ($DryRun) {
        Write-Note "git -C $script:RepoRoot submodule update --init --recursive"
        return
    }
    & git -C $script:RepoRoot submodule update --init --recursive
    if ($LASTEXITCODE -ne 0) {
        Write-Skip "git submodule update exited $LASTEXITCODE, continuing"
    }
}

function Install-ManifestPackage {
    $reader = Join-Path $script:RepoRoot 'bin/pkg-sync.ps1'
    if (-not (Test-Path -LiteralPath $reader)) {
        Write-Skip "bin/pkg-sync.ps1 is missing, skipping packages"
        return
    }
    # A child pwsh would need pwsh on PATH, which is one of the things
    # this very step installs. Dot-sourcing is not an option either
    # because the reader calls exit. So: same host, same session.
    & $reader install winget $Role -DryRun:$DryRun
}

<#
.SYNOPSIS
    The layer list for this machine.
.DESCRIPTION
    One layer today. dotbot.d/private.yaml is deliberately not composed:
    every `if:` guard in it is a POSIX `[ -f ... ]` test and both of its
    shell steps are POSIX too, and dotbot runs shell through cmd.exe on
    Windows, so the whole layer would silently no-op at best. The Windows
    layer carries its own cmd-syntax guards for the same AGENTS.md links.
#>
function Get-Layer {
    $layers = @((Join-Path $script:RepoRoot 'dotbot.d/os/windows.yaml'))

    $private = Join-Path $HOME 'dev/dotfiles-private'
    if (Test-Path -LiteralPath $private) {
        Write-Note 'dotfiles-private found; its dotbot layer is POSIX only and is not composed here.'
        Write-Note 'The Windows layer links ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md on its own.'
    }

    return $layers
}

function Invoke-Dotbot {
    param(
        [Parameter(Mandatory = $true)][string]$Python,
        [Parameter(Mandatory = $true)][string[]]$Layers
    )

    # -d is not optional. The layer lives in dotbot.d/os/, and without a
    # base directory dotbot resolves every relative link source against
    # that folder instead of the checkout.
    $dotbotArgs = @(
        (Join-Path $script:RepoRoot 'dotbot/bin/dotbot'),
        '-d', $script:RepoRoot,
        '-c'
    ) + $Layers

    Write-Step 'Composing dotbot layers'
    foreach ($layer in $Layers) { Write-Note $layer }

    if ($DryRun) {
        Write-Note "$Python $($dotbotArgs -join ' ')"
        return
    }

    & $Python @dotbotArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "dotbot exited $LASTEXITCODE"
        $script:ExitCode = 1
    }
}

function Write-RoleFile {
    $roleFile = Join-Path $script:RepoRoot '.dotfiles_role'
    if ($DryRun) {
        Write-Note "write $Role to $roleFile"
        return
    }
    # No BOM and a trailing newline, because bin/pkg-sync reads this file
    # with `head -n1` under WSL and a BOM would ride along in the value.
    [System.IO.File]::WriteAllText($roleFile, "$Role`n", (New-Object System.Text.UTF8Encoding($false)))
    Write-Note "recorded role $Role in .dotfiles_role"
}

<#
.SYNOPSIS
    The steps that genuinely need an elevated process.
.DESCRIPTION
    Setting the default WSL version writes machine state. Missing
    elevation is a skipped step and a printed note, never a failed
    install, so the unelevated path still gets the full user environment.
#>
function Invoke-ElevatedStep {
    param([Parameter(Mandatory = $true)][bool]$Elevated)

    if (-not $Elevated) {
        Write-Skip 'Not elevated: leaving the default WSL version alone.'
        Write-Note 'Re-run from an administrator prompt to apply it.'
        return
    }
    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
        Write-Skip 'wsl is not installed, skipping the default version'
        return
    }

    Write-Step 'Setting WSL 2 as the default version'
    if ($DryRun) {
        Write-Note 'wsl --set-default-version 2'
        return
    }
    & wsl --set-default-version 2
    if ($LASTEXITCODE -ne 0) {
        Write-Skip "wsl --set-default-version exited $LASTEXITCODE"
    }
}

# -------------------------------------------------------------
# Main
# -------------------------------------------------------------
function Invoke-Main {
    Write-Host ''
    Write-Host '  hyperb1iss dotfiles :: Windows install' -ForegroundColor Magenta
    Write-Host ''

    $elevated = Test-Admin
    if ($elevated) {
        Write-Note 'running elevated'
    }
    else {
        Write-Note 'running unelevated; system-level steps will be skipped by name'
    }

    if ($SkipSubmodules) {
        Write-Skip 'Skipping submodules (-SkipSubmodules)'
    }
    else {
        Initialize-Submodule
    }

    if ($SkipPackages) {
        Write-Skip 'Skipping winget packages (-SkipPackages)'
    }
    else {
        Install-ManifestPackage
    }

    $python = Get-PythonCommand
    if (-not $python) { $python = Install-Python }
    if (-not $python) {
        Write-Fail 'No Python on PATH, so dotbot cannot run. Nothing was linked.'
        $script:ExitCode = 2
        return
    }
    Write-Note "python: $python"

    $layers = Get-Layer
    Invoke-Dotbot -Python $python -Layers $layers
    if ($script:ExitCode -ne 0) { return }

    Write-RoleFile
    Invoke-ElevatedStep -Elevated $elevated

    Write-Host ''
    Write-Ok "Install complete. Open a new PowerShell session to pick it all up."
    Write-Host ''
}

Invoke-Main
exit $script:ExitCode
