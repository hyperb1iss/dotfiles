#!/usr/bin/env pwsh
#
# ╭──────────────────────────────────────────────────────────────╮
# │  pslint ⚡ PowerShell linter & formatter                     │
# │  Part of the SilkCircuit dotfiles ecosystem                  │
# ╰──────────────────────────────────────────────────────────────╯
#
# The PowerShell twin of bin/shellint. Lints every git-tracked .ps1,
# .psm1 and .psd1 with PSScriptAnalyzer, or rewrites them in place with
# Invoke-Formatter when -Format is passed.
#
# Severity policy: Error and Warning are blocking and set a nonzero exit
# code. Information is printed and ignored, so advisory nits stay visible
# without stopping a commit while genuine defects do.
#
# Rule selection comes from PSScriptAnalyzerSettings.psd1 when the repo
# ships one (root first, then hypershell/), otherwise the PSGallery
# preset. Formatting falls back to the CodeFormatting preset, since
# PSGallery carries rule selection only and would be a no-op.

[CmdletBinding()]
param(
    # Rewrite files in place instead of reporting findings.
    [switch]$Format
)

$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────────────────────
# SilkCircuit Neon Palette (24-bit RGB)
# ─────────────────────────────────────────────────────────────
$esc = [char]27
$reset = "$esc[0m"
$bold = "$esc[1m"
$scPurple = "$esc[38;2;225;53;255m"  # #e135ff - Electric Purple
$scCyan = "$esc[38;2;128;255;234m"   # #80ffea - Neon Cyan
$scPink = "$esc[38;2;255;121;198m"   # #ff79c6 - Hot Pink
$scGreen = "$esc[38;2;80;250;123m"   # #50fa7b - Success Green
$scRed = "$esc[38;2;255;99;99m"      # #ff6363 - Error Red
$scOrange = "$esc[38;2;255;180;100m" # #ffb464 - Warning Orange
$scGray = "$esc[38;2;98;114;164m"    # #6272a4 - Muted Gray
$scWhite = "$esc[38;2;248;248;242m"  # #f8f8f2 - Pure White

# ─────────────────────────────────────────────────────────────
# Dependency and repository discovery
# ─────────────────────────────────────────────────────────────
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Host "  ${scRed}${bold}✖ error:${reset} PSScriptAnalyzer is not installed"
    Write-Host "  ${scGray}◦ install it with:${reset} ${scCyan}Install-PSResource PSScriptAnalyzer -TrustRepository${reset}"
    exit 1
}
Import-Module PSScriptAnalyzer

$repoRoot = & git -C $PSScriptRoot rev-parse --show-toplevel 2> $null
if (-not $repoRoot) {
    Write-Host "  ${scRed}${bold}✖ error:${reset} not inside a git work tree"
    exit 1
}

# Tracked files only, so submodules, build output and anything ignored
# stay out of the run.
$tracked = @(& git -C $repoRoot ls-files '*.ps1' '*.psm1' '*.psd1')

# PSScriptAnalyzerSettings.psd1 is a settings file, not a module
# manifest, so the manifest rules would flag it for fields it is never
# supposed to carry. Analyze everything else.
$files = @($tracked | Where-Object {
        $_ -and ((Split-Path $_ -Leaf) -ne 'PSScriptAnalyzerSettings.psd1')
    })

if ($files.Count -eq 0) {
    Write-Host "  ${scGreen}✓${reset} ${scGray}no PowerShell files tracked${reset}"
    exit 0
}

$settingsFile = @(
    (Join-Path $repoRoot 'PSScriptAnalyzerSettings.psd1'),
    (Join-Path (Join-Path $repoRoot 'hypershell') 'PSScriptAnalyzerSettings.psd1')
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

# PSGallery selects rules and carries no formatting rules at all, so the
# formatter needs its own fallback or it becomes a silent no-op.
$activeSettings = if ($settingsFile) { $settingsFile }
elseif ($Format) { 'CodeFormatting' }
else { 'PSGallery' }

$settingsLabel = if ($settingsFile) {
    [System.IO.Path]::GetRelativePath($repoRoot, $settingsFile)
}
else {
    "$activeSettings preset"
}

# ─────────────────────────────────────────────────────────────
# Format mode: rewrite in place, report what moved
# ─────────────────────────────────────────────────────────────
if ($Format) {
    Write-Host "  ${scPurple}◈${reset} formatting ${bold}${scWhite}$($files.Count) files${reset} ${scGray}($settingsLabel)${reset}"

    $rewritten = [System.Collections.Generic.List[string]]::new()
    foreach ($rel in $files) {
        $full = Join-Path $repoRoot $rel
        $before = Get-Content -LiteralPath $full -Raw
        if (-not $before) { continue }

        $after = Invoke-Formatter -ScriptDefinition $before -Settings $activeSettings
        if ($after -ne $before) {
            Set-Content -LiteralPath $full -Value $after -NoNewline -Encoding utf8NoBOM
            $rewritten.Add($rel)
        }
    }

    if ($rewritten.Count -eq 0) {
        Write-Host "  ${scGreen}✓${reset} ${scGray}already formatted${reset}"
    }
    else {
        foreach ($rel in $rewritten) {
            Write-Host "  ${scGreen}✓${reset} ${scPink}reformatted${reset} ${scCyan}$rel${reset}"
        }
    }
    exit 0
}

# ─────────────────────────────────────────────────────────────
# Lint mode: findings by file, then a roll-up by rule
# ─────────────────────────────────────────────────────────────
Write-Host "  ${scCyan}⚡${reset} analyzing ${bold}${scWhite}$($files.Count) files${reset} ${scGray}($settingsLabel)${reset}"

$findings = foreach ($rel in $files) {
    Invoke-ScriptAnalyzer -Path (Join-Path $repoRoot $rel) -Settings $activeSettings
}
$findings = @($findings)

if ($findings.Count -eq 0) {
    Write-Host "  ${scGreen}✓${reset} ${scGray}no issues in${reset} ${scCyan}$($files.Count) files${reset}"
    exit 0
}

$glyphs = @{
    Error       = "${scRed}✖${reset}"
    Warning     = "${scOrange}⚠${reset}"
    Information = "${scGray}◦${reset}"
}
$ruleWidth = ($findings | ForEach-Object { $_.RuleName.Length } | Measure-Object -Maximum).Maximum

foreach ($group in $findings | Group-Object { [System.IO.Path]::GetRelativePath($repoRoot, $_.ScriptPath) } | Sort-Object Name) {
    Write-Host ""
    Write-Host "  ${scPink}◈${reset} ${bold}${scWhite}$($group.Name)${reset}"
    foreach ($f in $group.Group | Sort-Object Line) {
        $glyph = $glyphs[[string]$f.Severity]
        $where = "{0}:{1}" -f $f.Line, $f.Column
        $rule = $f.RuleName.PadRight($ruleWidth)
        Write-Host "    $glyph ${scGray}$where${reset} ${scCyan}$rule${reset} $($f.Message)"
    }
}

Write-Host ""
Write-Host "  ${scPurple}▸${reset} ${bold}findings by rule${reset}"
foreach ($group in $findings | Group-Object RuleName | Sort-Object Count, Name -Descending) {
    Write-Host ("    {0}{1,4}{2} {3}" -f $scWhite, $group.Count, $reset, $group.Name)
}

$blocking = @($findings | Where-Object { $_.Severity -in @('Error', 'Warning') }).Count
$advisory = $findings.Count - $blocking

Write-Host ""
if ($advisory -gt 0) {
    Write-Host "  ${scGray}◦ $advisory information-severity findings, not blocking${reset}"
}

if ($blocking -gt 0) {
    Write-Host "  ${scRed}${bold}✖ $blocking blocking findings${reset} ${scGray}(error/warning severity)${reset}"
    exit 1
}

Write-Host "  ${scGreen}✓${reset} ${scGray}nothing blocking${reset}"
exit 0
