# Utility functions

# Touch command
function New-File {
    param([string]$file)
    if ($file) {
        New-Item -ItemType File -Name $file
    }
    else {
        Write-Host "Usage: touch <filename>"
    }
}
Set-Alias -Name touch -Value New-File -Force

# Mkdir command (creates full path)
function New-Directory {
    param([string]$path)
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}
Set-Alias -Name mkdir -Value New-Directory -Force

# Tail command
function Get-Tail {
    param(
        [Parameter(Mandatory = $true)][string]$file,
        [int]$lines = 10
    )
    Get-Content -Tail $lines -Wait $file
}
Set-Alias -Name tail -Value Get-Tail

# Find command
function Find-Files {
    param(
        [Parameter(Mandatory = $true)][string]$pattern
    )
    Get-ChildItem -Recurse | Where-Object { $_.Name -match $pattern }
}
Set-Alias -Name find -Value Find-Files 