# setup-windows.ps1
# This script sets up the Windows environment with necessary tools and configurations

# Ensure script is run as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

# Install Chocolatey if not already installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install or upgrade necessary tools
choco upgrade -y `
    powershell-core `
    microsoft-windows-terminal `
    git `
    vscode `
    nodejs `
    python `
    rust `
    fzf `
    ripgrep `
    bat `
    lsd `
    starship `
    neovim `
    gnuwin32-coreutils.install `
    grep `
    findutils `
    sed `
    gawk `
    which `
    unxutils `
    cygwin `
    mingw `
    curl `
    wget `
    7zip `
    bzip2 `
    openssh `
    make `
    delta `
    zoxide


# Diagnostic function
function Test-PowerShellModules {
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

# Attempt to repair PowerShellGet and PackageManagement
function Repair-PowerShellModules {
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
Test-PowerShellModules

# Attempt repair
Repair-PowerShellModules

# Run diagnostics again to verify repair
Test-PowerShellModules

# Install PowerShell modules
Write-Host "Installing PowerShell modules..." -ForegroundColor Yellow
Install-Module -Name PSReadLine -Force -SkipPublisherCheck
Install-Module -Name posh-git -Force
Install-Module -Name Terminal-Icons -Force

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

# Add common directories to PATH
Add-ToPath "$env:USERPROFILE\bin"
Add-ToPath "$env:USERPROFILE\.local\bin"
Add-ToPath "$env:USERPROFILE\.cargo\bin"
Add-ToPath "C:\Program Files (x86)\GnuWin32\bin"
Add-ToPath "C:\Tools\unxutils"
Add-ToPath "C:\cygwin64\bin"

# Function to set environment variables
function Set-EnvironmentVariable {
    param (
        [string]$Name,
        [string]$Value
    )
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

# Install zoxide via cargo if not already installed
if (!(Get-Command zoxide -ErrorAction SilentlyContinue)) {
    Write-Host "Installing zoxide via cargo..." -ForegroundColor Yellow
    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        cargo install zoxide
        Write-Host "zoxide installed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Cargo not found. Please install Rust and Cargo first." -ForegroundColor Red
    }
}
else {
    Write-Host "zoxide is already installed." -ForegroundColor Green
}

# Enable Developer Mode
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1

Write-Host "Windows environment setup complete!" -ForegroundColor Green
Write-Host "Please restart your PowerShell session to ensure all changes take effect." -ForegroundColor Yellow