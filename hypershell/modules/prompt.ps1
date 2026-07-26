# Prompt configuration and related functions

function Test-HyperShellInteractiveSession {
    return -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected
}

function Get-HyperShellStateDirectory {
    if ($env:LOCALAPPDATA) {
        return Join-Path $env:LOCALAPPDATA "HyperShell"
    }

    if ($env:XDG_CACHE_HOME) {
        return Join-Path $env:XDG_CACHE_HOME "hypershell"
    }

    return Join-Path $HOME ".cache\hypershell"
}

function Get-HyperShellStartupStampPath {
    return Join-Path (Get-HyperShellStateDirectory) "startup-banner.date"
}

function Test-HyperShellStartupDue {
    if (-not (Test-HyperShellInteractiveSession)) {
        return $false
    }

    $stampPath = Get-HyperShellStartupStampPath
    $today = Get-Date -Format "yyyy-MM-dd"
    $lastShown = Get-Content -Path $stampPath -TotalCount 1 -ErrorAction SilentlyContinue

    return $lastShown -ne $today
}

function Set-HyperShellStartupShown {
    $stateDir = Get-HyperShellStateDirectory
    $stampPath = Get-HyperShellStartupStampPath

    try {
        New-Item -Path $stateDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Set-Content -Path $stampPath -Value (Get-Date -Format "yyyy-MM-dd") -Encoding ASCII -ErrorAction Stop
    }
    catch {
        # Startup should stay graceful even if the cache path is unavailable.
    }
}

function Show-HyperShellStartup {
    param(
        [switch]$Force,
        [switch]$PassThru
    )

    if (-not $Force -and -not (Test-HyperShellStartupDue)) {
        if ($PassThru) {
            return $false
        }

        return
    }

    $esc = [char]27
    $version = "1.0.0"

    Set-HyperShellStartupShown
    Write-Host "$esc[38;5;213m⟨$esc[38;5;207m⟨$esc[38;5;201m⟨ $esc[1m$esc[38;5;219m☆ $esc[38;5;159mHYPER$esc[38;5;213mSHELL$esc[38;5;219m::$esc[38;5;123m$version $esc[22m$esc[38;5;201m⟩$esc[38;5;207m⟩$esc[38;5;213m⟩$esc[0m"

    if ($PassThru) {
        return $true
    }
}

# Load Starship prompt
Invoke-Expression (&starship init powershell)

# Function to normalize a path for display
function Get-NormalizedPath {
    param([string]$Path)
    $homePath = $HOME
    if ($Path.StartsWith($homePath)) {
        return $Path.Replace($homePath, "~")
    }
    return $Path
}

# Function to get the current directory name
function Get-CurrentDirectoryName {
    $normalizedPath = Get-NormalizedPath -Path $PWD.Path
    return (Split-Path -Leaf $normalizedPath)
}

# Function to update the terminal title
function Update-Title {
    param([string]$Title)
    $host.UI.RawUI.WindowTitle = $Title
}

# Initial title update
$initialPath = Get-NormalizedPath -Path $PWD.Path
Update-Title "HyperShell - $initialPath" 

# Capture and wrap the original prompt function to update the title on every prompt

if ($function:prompt) {
    # Save the original Starship prompt function in a global variable
    $global:__OriginalStarshipPrompt = $function:prompt
  
    function prompt {
        # Check if directory has changed since the last prompt
        if (-not $global:__LastPromptPath -or $global:__LastPromptPath -ne $PWD) {
            $global:__LastPromptPath = $PWD
            $currentPath = Get-NormalizedPath -Path $PWD.Path
            Update-Title "HyperShell - $currentPath"
        }
        # Call the original Starship prompt to render the usual prompt
        & $global:__OriginalStarshipPrompt
    }
}
