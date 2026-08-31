#!/usr/bin/env pwsh
#
# Assert that a Windows dotbot run produced what its layers declare.
#
# The PowerShell twin of assert-links.sh. Same contract: every link the
# layers name has to exist and resolve, every `create` directory has to be
# there, and a floor list guards against a layer that lost its links
# passing on an empty derived set.
#
# It is a separate script rather than a flag on the bash one because the
# two floors are genuinely different. Windows composes only
# dotbot.d/os/windows.yaml, never base.yaml, so the unix floor
# (~/.zshrc, ~/.bashrc.local, ~/bin) is absent there by design and
# asserting it would fail every run.
#
# Usage: assert-links.ps1 -TargetHome DIR -Repo DIR -Layers a.yaml[,b.yaml]

# PSReviewUnusedParameter cannot see the @Layers splat inside
# Get-DeclaredPath through dynamic scoping.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
[CmdletBinding()]
param(
    # The HOME the declared paths are expanded against.
    [Parameter(Mandatory = $true)][string]$TargetHome,

    # Repository root, used to find expected_links.py.
    [Parameter(Mandatory = $true)][string]$Repo,

    # dotbot layer files to derive expectations from.
    [Parameter(Mandatory = $true)][string[]]$Layers
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Links every Windows composition must produce. Their absence from the
# derived set means the yaml lost them, not that this profile skips them.
# Conditional links are deliberately not here: expected_links.py skips any
# entry carrying an `if:` guard, so they can never appear in the set.
$floor = @(
    'AppData/Local/nvim'
    'Documents/PowerShell/Modules/HyperShell'
    'Documents/PowerShell/Microsoft.PowerShell_profile.ps1'
    '.gitconfig'
    '.claude/statusline-command.sh'
)

$derive = Join-Path $Repo '.github/smoke/expected_links.py'
if (-not (Test-Path -LiteralPath $derive)) {
    Write-Host "error: expected_links.py not found at $derive"
    exit 2
}

# Windows yaml mixes separators once expanduser joins a backslash home to a
# forward-slash tail, and a trailing slash is meaningless either way.
function ConvertTo-ComparablePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return ($Path -replace '\\', '/').TrimEnd('/')
}

function Get-DeclaredPath {
    param([Parameter(Mandatory = $true)][string]$Kind)
    $output = & python $derive --home $TargetHome --kind $Kind @Layers
    if ($LASTEXITCODE -ne 0) {
        Write-Host "error: expected_links.py --kind $Kind exited $LASTEXITCODE"
        exit 2
    }
    return @($output | Where-Object { $_ })
}

$failures = 0
$checked = 0

Write-Host "> asserting links under $TargetHome"

$links = Get-DeclaredPath -Kind 'link'
foreach ($path in $links) {
    $checked++
    $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue

    if (-not $item) {
        Write-Host "  x missing: $path"
        $failures++
        continue
    }

    # dotbot makes symlinks, but a directory link can arrive as a junction
    # on a box without symlink privilege. Both are reparse points and both
    # satisfy the contract, so test the attribute rather than the flavour.
    $isLink = [bool]($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
    if (-not $isLink) {
        Write-Host "  x not a link: $path"
        $failures++
        continue
    }

    $target = $item.Target
    if (-not $target) {
        Write-Host "  x link with no target: $path"
        $failures++
    }
    elseif (-not (Test-Path -Path $target)) {
        Write-Host "  x dangling link: $path -> $target"
        $failures++
    }
    else {
        Write-Host "  + $path -> $target"
    }
}

foreach ($path in (Get-DeclaredPath -Kind 'create')) {
    $checked++
    if (Test-Path -LiteralPath $path -PathType Container) {
        Write-Host "  + $path/"
    }
    else {
        Write-Host "  x missing directory: $path"
        $failures++
    }
}

$comparable = @($links | ForEach-Object { ConvertTo-ComparablePath -Path $_ })
foreach ($relative in $floor) {
    $expected = ConvertTo-ComparablePath -Path (Join-Path $TargetHome $relative)
    if ($comparable -notcontains $expected) {
        Write-Host "  x core link missing from the composed layers: $expected"
        $failures++
    }
}

if ($failures -ne 0) {
    Write-Host "x $failures assertion(s) failed across $checked path(s)"
    exit 1
}

Write-Host "+ $checked path(s) verified"
