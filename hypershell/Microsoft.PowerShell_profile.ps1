# Microsoft.PowerShell_profile.ps1
# HyperShell: A high-tech, Linux-inspired environment for Windows PowerShell
# https://github.com/hyperbliss/dotfiles/hypershell

# Get the directory containing the modules
$modulesDir = Join-Path $HOME "dotfiles\hypershell\modules"

# Load all modules
$moduleFiles = @(
    "core.ps1",
    "prompt.ps1",
    "aliases.ps1",
    "navigation.ps1",
    "fzf.ps1",
    "git.ps1",
    "wsl.ps1",
    "utils.ps1"
)

foreach ($module in $moduleFiles) {
    $modulePath = Join-Path $modulesDir $module
    if (Test-Path $modulePath) {
        . $modulePath
    }
    else {
        Write-Warning "Module not found: $module at $modulePath"
    }
}

# Show startup banner
Show-HyperShellStartup
