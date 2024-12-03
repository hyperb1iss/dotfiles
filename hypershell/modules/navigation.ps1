# Directory navigation and path-related functions

# Function to update location with title update
function Set-LocationWithTitleUpdate {
    param([string]$path)
    Set-Location $path
    $normalizedPath = Get-NormalizedPath -Path $PWD.Path
    Update-Title "HyperShell - $normalizedPath"
}

# Set up location change with history
$global:__LastLocation = $PWD
function Set-LocationWithHistory {
    param([string]$path)
    if ($path -eq '-') {
        $tmp = $PWD
        Set-Location $global:__LastLocation
        $global:__LastLocation = $tmp
    }
    else {
        $global:__LastLocation = $PWD
        Set-Location $path
    }
    Update-Title "HyperShell - $(Get-CurrentDirectoryName)"
}

# Function to create directory and change into it
function New-DirectoryAndEnter {
    param([string]$path)
    New-Item -ItemType Directory -Path $path
    Set-Location -Path $path
}

Set-Alias -Name cd -Value Set-LocationWithHistory -Option AllScope -Force
Set-Alias -Name mkcd -Value New-DirectoryAndEnter -Force 