# install-claude-statusline.ps1
# Points Claude Code at the SilkCircuit status line.
#
# settings.json is Claude Code's own live file and is deliberately not tracked in
# dotfiles, so merge in the single key we own rather than linking over the whole
# file and clobbering hooks, plugins, and permissions.

$ErrorActionPreference = 'Stop'

$ElectricPurple = "`e[38;2;225;53;255m"
$NeonCyan = "`e[38;2;128;255;234m"
$SuccessGreen = "`e[38;2;80;250;123m"
$Reset = "`e[0m"

$claudeDir = Join-Path $HOME '.claude'
$settingsPath = Join-Path $claudeDir 'settings.json'

# Git Bash strips unquoted backslashes, so the command must use forward slashes
$command = '~/.claude/statusline-command.sh'

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
}

if (Test-Path $settingsPath) {
    $raw = Get-Content $settingsPath -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        $settings = [PSCustomObject]@{}
    } else {
        $settings = $raw | ConvertFrom-Json
    }
} else {
    $settings = [PSCustomObject]@{}
}

if ($settings.statusLine -and $settings.statusLine.command -eq $command) {
    Write-Host "${NeonCyan}Claude status line already configured${Reset}"
    exit 0
}

if (Test-Path $settingsPath) {
    Copy-Item $settingsPath "$settingsPath.bak" -Force
}

$statusLine = [PSCustomObject]@{
    type    = 'command'
    command = $command
}
$settings | Add-Member -NotePropertyName statusLine -NotePropertyValue $statusLine -Force

# Depth must be generous: hooks and plugin config nest several levels and the
# default of 2 would silently flatten them into strings
$settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding utf8

Write-Host "${ElectricPurple}SilkCircuit${Reset} status line wired into ${NeonCyan}$settingsPath${Reset} ${SuccessGreen}✓${Reset}"
