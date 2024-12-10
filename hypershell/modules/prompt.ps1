# Prompt configuration and related functions

function Show-HyperShellStartup {
    $esc = [char]27
    $version = "1.0.0"
    
    Write-Host "$esc[38;5;213m⟨$esc[38;5;207m⟨$esc[38;5;201m⟨ $esc[1m$esc[38;5;219m☆ $esc[38;5;159mHYPER$esc[38;5;213mSHELL$esc[38;5;219m::$esc[38;5;123m$version $esc[22m$esc[38;5;201m⟩$esc[38;5;207m⟩$esc[38;5;213m⟩$esc[0m"
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