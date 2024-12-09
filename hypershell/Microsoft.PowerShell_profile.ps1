# Microsoft.PowerShell_profile.ps1
# HyperShell: A high-tech, Linux-inspired environment for Windows PowerShell
# https://github.com/hyperbliss/dotfiles/hypershell

# Get the directory containing the modules
$modulesDir = Join-Path $HOME "dotfiles\hypershell\modules"

# Load all .ps1 files from the modules directory
if (Test-Path $modulesDir) {
    Get-ChildItem -Path $modulesDir -Filter "*.ps1" | ForEach-Object {
        try {
            . $_.FullName
        }
        catch {
            Write-Warning "Failed to load module: $($_.Name)`nError: $($_.Exception.Message)"
        }
    }
}
else {
    Write-Warning "Modules directory not found at: $modulesDir"
}

# Show startup banner
Show-HyperShellStartup
