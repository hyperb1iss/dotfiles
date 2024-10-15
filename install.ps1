# install.ps1
# This script initiates the Dotbot installation process for Windows,
# including Python installation if necessary

# Function to check if running as administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running with administrator privileges
if (-not (Test-Admin)) {
    Write-Host "This script requires administrator privileges. Please run as administrator." -ForegroundColor Red
    exit 1
}

# Function to install Python using winget
function Install-Python {
    Write-Host "Python is not installed. Attempting to install Python..." -ForegroundColor Yellow

    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Python.Python.3.11
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install Python using winget. Please install Python manually and retry." -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "Winget is not available. Please install Python manually and retry." -ForegroundColor Red
        exit 1
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Check for Python installation
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Install-Python
}

# Verify Python installation
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python installation failed or PATH was not updated. Please install Python manually and retry." -ForegroundColor Red
    exit 1
}

# Execute Dotbot
Write-Host "Executing Dotbot..." -ForegroundColor Green
python "dotbot\bin\dotbot" -c "windows.yaml"

Write-Host "Installation process completed." -ForegroundColor Green
