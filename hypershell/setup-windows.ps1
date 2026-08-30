# setup-windows.ps1
#
# Windows environment setup for everything that is not a package.
#
# Packages come from install.ps1, which runs bin/pkg-sync.ps1 against
# packages.conf and installs them with winget. This script covers the rest:
# the rustup toolchain, the PowerShell modules HyperShell declares, VS Code
# extensions, PATH and environment variables, and the developer mode switch.
#
# It no longer demands administrator rights up front. Everything here works
# unelevated except the PowerShellGet repair and the developer mode registry
# key, and those two check for elevation themselves and print a skip line
# rather than aborting the whole run.

<#
.SYNOPSIS
    Reports whether this session is elevated.
#>
function Test-Administrator {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        return ([Security.Principal.WindowsPrincipal]$identity).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

$isElevated = Test-Administrator
if (-not $isElevated) {
    Write-Host "Running unelevated. Steps that need administrator rights will be skipped." -ForegroundColor Yellow
}

# ── Rust ─────────────────────────────────────────────────────────────────────
# Rust comes from rustup, never a package manager.
#
# Chocolatey's `rust` package drops a GNU-host toolchain into
# C:\ProgramData\chocolatey\bin, which lives in the *system* PATH. Windows
# evaluates system PATH before user PATH, and ~\.cargo\bin is in the user
# PATH, so the Chocolatey copy shadows rustup no matter what Add-ToPath does
# further down this script. Projects then build against a mingw linker and
# fail with "cannot execute 'ld'", or hit E0514 rustc-mismatch errors against
# artifacts an earlier rustup build left in target/.
#
# rustup is also the only installer that honours a repo's rust-toolchain.toml,
# which several projects here pin.
if ((Test-Path "C:\ProgramData\chocolatey\lib\rust") -and (Get-Command choco -ErrorAction SilentlyContinue)) {
    if ($isElevated) {
        Write-Host "Removing Chocolatey's rust package (it shadows rustup)..." -ForegroundColor Yellow
        choco uninstall rust -y
    }
    else {
        Write-Host "Chocolatey's rust package is installed and shadows rustup." -ForegroundColor Yellow
        Write-Host "  Run 'choco uninstall rust -y' from an elevated prompt." -ForegroundColor Yellow
    }
}

if (!(Get-Command rustup -ErrorAction SilentlyContinue)) {
    Write-Host "Installing rustup (MSVC host)..." -ForegroundColor Yellow
    $rustupInit = Join-Path $env:TEMP "rustup-init.exe"
    Invoke-WebRequest -Uri "https://win.rustup.rs/x86_64" -OutFile $rustupInit
    & $rustupInit -y --default-host x86_64-pc-windows-msvc --default-toolchain stable
    Remove-Item $rustupInit -Force -ErrorAction SilentlyContinue
}
else {
    Write-Host "Updating rustup..." -ForegroundColor Yellow
    rustup self update
    rustup update stable
}

# Diagnostic function
function Test-PowerShellModule {
    Write-Host "Diagnosing PowerShell modules..." -ForegroundColor Yellow
    $psGetModule = Get-Module -Name PowerShellGet -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    $packageManagementModule = Get-Module -Name PackageManagement -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

    Write-Host "PowerShellGet version: $($psGetModule.Version)"
    Write-Host "PackageManagement version: $($packageManagementModule.Version)"

    $psGetPath = $psGetModule.ModuleBase
    $packageManagementPath = $packageManagementModule.ModuleBase

    Write-Host "PowerShellGet path: $psGetPath"
    Write-Host "PackageManagement path: $packageManagementPath"

    if (Test-Path $psGetPath) {
        Write-Host "PowerShellGet module files exist."
    }
    else {
        Write-Host "PowerShellGet module files are missing!" -ForegroundColor Red
    }

    if (Test-Path $packageManagementPath) {
        Write-Host "PackageManagement module files exist."
    }
    else {
        Write-Host "PackageManagement module files are missing!" -ForegroundColor Red
    }
}

# Attempt to repair PowerShellGet and PackageManagement.
#
# This writes into $env:ProgramFiles, so it is the one step here that
# genuinely needs elevation.
function Repair-PowerShellModule {
    Write-Host "Attempting to repair PowerShellGet and PackageManagement..." -ForegroundColor Yellow

    $tempFolder = Join-Path $env:TEMP "PSModules"
    New-Item -ItemType Directory -Force -Path $tempFolder | Out-Null

    # Download and install PackageManagement
    $packageManagementUrl = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
    $packageManagementPath = Join-Path $tempFolder "PackageManagement.zip"
    Invoke-WebRequest -Uri $packageManagementUrl -OutFile $packageManagementPath
    Expand-Archive -Path $packageManagementPath -DestinationPath "$tempFolder\PackageManagement" -Force

    # Download and install PowerShellGet
    $powerShellGetUrl = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
    $powerShellGetPath = Join-Path $tempFolder "PowerShellGet.zip"
    Invoke-WebRequest -Uri $powerShellGetUrl -OutFile $powerShellGetPath
    Expand-Archive -Path $powerShellGetPath -DestinationPath "$tempFolder\PowerShellGet" -Force

    # Copy files, ignoring errors for files in use
    Copy-Item "$tempFolder\PackageManagement\*" -Destination "$env:ProgramFiles\PowerShell\7\Modules\PackageManagement" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item "$tempFolder\PowerShellGet\*" -Destination "$env:ProgramFiles\PowerShell\7\Modules\PowerShellGet" -Recurse -Force -ErrorAction SilentlyContinue

    # Reload modules
    Remove-Module PackageManagement -Force -ErrorAction SilentlyContinue
    Remove-Module PowerShellGet -Force -ErrorAction SilentlyContinue
    Import-Module PackageManagement -Force
    Import-Module PowerShellGet -Force
}

# Run diagnostics
Test-PowerShellModule

if ($isElevated) {
    Repair-PowerShellModule

    # Run diagnostics again to verify repair
    Test-PowerShellModule
}
else {
    Write-Host "Skipping the PowerShellGet repair: it writes to $env:ProgramFiles and needs administrator rights." -ForegroundColor Yellow
}

# Install the PowerShell modules HyperShell declares.
#
# The manifest is the source of truth so this list cannot drift:
# RequiredModules is what the module imports, and
# PrivateData.HyperShell.OptionalModules is what it picks up when present.
Write-Host "Installing PowerShell modules..." -ForegroundColor Yellow
$manifestPath = Join-Path -Path $PSScriptRoot -ChildPath "HyperShell" -AdditionalChildPath "HyperShell.psd1"

if (Test-Path -LiteralPath $manifestPath) {
    $hyperShellManifest = Import-PowerShellDataFile -LiteralPath $manifestPath
    $moduleNames = @(
        $hyperShellManifest.RequiredModules | ForEach-Object {
            if ($_ -is [hashtable]) { $_.ModuleName } else { $_ }
        }
        $hyperShellManifest.PrivateData.HyperShell.OptionalModules
    ) | Where-Object { $_ } | Select-Object -Unique

    foreach ($moduleName in $moduleNames) {
        Write-Host "  $moduleName" -ForegroundColor Cyan
        if (Get-Command Install-PSResource -ErrorAction SilentlyContinue) {
            # -TrustRepository keeps this non-interactive; without it PSResourceGet
            # stops for a confirmation prompt on an untrusted PSGallery.
            Install-PSResource -Name $moduleName -Scope CurrentUser -TrustRepository -ErrorAction Continue
        }
        else {
            Install-Module -Name $moduleName -Scope CurrentUser -Force -SkipPublisherCheck
        }
    }
}
else {
    Write-Warning "HyperShell manifest not found at $manifestPath, skipping module installation."
}

# Setup Visual Studio Code extensions
Write-Host "Setting up Visual Studio Code extensions..." -ForegroundColor Yellow
$extensions = @(
    "ms-vscode.powershell",
    "vscodevim.vim",
    "dracula-theme.theme-dracula",
    "rust-lang.rust-analyzer",
    "ms-python.python"
)

foreach ($extension in $extensions) {
    $installed = code --list-extensions | Where-Object { $_ -eq $extension }
    if (-not $installed) {
        Write-Host "Installing VSCode extension: $extension" -ForegroundColor Cyan
        code --install-extension $extension
    }
    else {
        Write-Host "VSCode extension already installed: $extension" -ForegroundColor Green
    }
}

# Function to add a directory to system PATH
function Add-ToPath {
    param (
        [string]$Directory
    )
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$Directory*") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$Directory", "User")
        Write-Host "Added $Directory to PATH." -ForegroundColor Green
    }
    else {
        Write-Host "$Directory is already in PATH." -ForegroundColor Yellow
    }
}

# Add common directories to PATH. The GnuWin32, unxutils, and cygwin entries
# are what put grep, sed, awk, and find on PATH, which is what HyperShell's
# aliases for those names bind to.
Add-ToPath "$env:USERPROFILE\bin"
Add-ToPath "$env:USERPROFILE\.local\bin"
Add-ToPath "$env:USERPROFILE\.cargo\bin"
Add-ToPath "C:\Program Files (x86)\GnuWin32\bin"
Add-ToPath "C:\Tools\unxutils"
Add-ToPath "C:\cygwin64\bin"

# Function to set environment variables
function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Name,
        [string]$Value
    )
    if (-not $PSCmdlet.ShouldProcess($Name, "Set user environment variable")) {
        return
    }
    [Environment]::SetEnvironmentVariable($Name, $Value, "User")
    [Environment]::SetEnvironmentVariable($Name, $Value, "Process")
    Write-Host "Set $Name to $Value" -ForegroundColor Green
}

# Set Neovim as the global editor
Write-Host "Setting Neovim as the global editor..." -ForegroundColor Yellow

# Ensure Neovim is in the PATH
$nvimPath = (Get-Command nvim -ErrorAction SilentlyContinue).Source
if ($nvimPath) {
    # Set EDITOR and VISUAL environment variables
    Set-EnvironmentVariable "EDITOR" $nvimPath
    Set-EnvironmentVariable "VISUAL" $nvimPath

    # Set Git to use Neovim
    git config --global core.editor "nvim"
    Write-Host "Git configured to use Neovim as default editor." -ForegroundColor Green
}
else {
    Write-Host "Neovim (nvim) not found in PATH. Please ensure it's installed correctly." -ForegroundColor Red
}

# Enable Developer Mode. Writes to HKLM, so it needs elevation.
$devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if ($isElevated) {
    Set-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -Value 1
    Write-Host "Developer Mode enabled." -ForegroundColor Green
}
else {
    Write-Host "Skipping Developer Mode: writing to HKLM needs administrator rights." -ForegroundColor Yellow
    Write-Host "  Enable it from Settings, or rerun this script elevated." -ForegroundColor Yellow
}

Write-Host "Windows environment setup complete!" -ForegroundColor Green
Write-Host "Please restart your PowerShell session to ensure all changes take effect." -ForegroundColor Yellow
