# Java version switching functionality for Windows PowerShell
# Assumes JDKs are installed in standard locations

function Get-JavaInstallations {
    $javaHomes = @(
        # Standard Oracle JDK locations
        "C:\Program Files\Java\*jdk*",
        # Standard OpenJDK locations
        "C:\Program Files\Eclipse Foundation\*jdk*",
        # AdoptOpenJDK / Eclipse Temurin locations
        "C:\Program Files\Eclipse Adoptium\*",
        # Microsoft OpenJDK
        "C:\Program Files\Microsoft\jdk*"
    )

    $installations = @()
    foreach ($path in $javaHomes) {
        if (Test-Path $path) {
            Get-ChildItem -Path $path -Directory | ForEach-Object {
                $version = $null
                $releaseFile = Join-Path $_.FullName "release"
                
                if (Test-Path $releaseFile) {
                    $releaseContent = Get-Content $releaseFile -Raw
                    if ($releaseContent -match 'JAVA_VERSION="?(1\.)?([0-9]+)') {
                        $version = $matches[2]
                    }
                }
                
                if (-not $version) {
                    # Fallback to directory name parsing
                    if ($_.Name -match '(?:jdk-?|openjdk-?)*(1\.)?([0-9]+)') {
                        $version = $matches[2]
                    }
                }

                if ($version) {
                    $installations += @{
                        Version = [int]$version
                        Path    = $_.FullName
                        Name    = $_.Name
                    }
                }
            }
        }
    }

    return $installations | Sort-Object Version
}

function Set-JavaVersion {
    param (
        [Parameter(Mandatory = $false)]
        [string]$Version
    )

    if (-not $Version) {
        Write-Host "Available Java versions:" -ForegroundColor Cyan
        Write-Host "═══════════════════════" -ForegroundColor Cyan
        $installations = Get-JavaInstallations
        
        $currentJavaHome = $env:JAVA_HOME
        foreach ($install in $installations) {
            $marker = if ($install.Path -eq $currentJavaHome) { "* " } else { "  " }
            Write-Host "$marker Java $($install.Version) ($($install.Name))"
            Write-Host "    Path: $($install.Path)"
            Write-Host "    Commands: java$($install.Version), setjdk $($install.Version)`n"
        }

        Write-Host "Usage:"
        Write-Host "  - Use 'java<version>' (e.g., java11) for quick switching"
        Write-Host "  - Use 'setjdk <version>' (e.g., setjdk 11) for explicit switching"
        return
    }

    $installations = Get-JavaInstallations
    $selected = $installations | Where-Object { $_.Version -eq $Version } | Select-Object -First 1

    if (-not $selected) {
        Write-Host "Error: Java $Version is not installed" -ForegroundColor Red
        Write-Host "Use 'setjdk' without arguments to see available versions" -ForegroundColor Yellow
        return $false
    }

    $env:JAVA_HOME = $selected.Path
    $javaPath = Join-Path $env:JAVA_HOME "bin"
    
    # Update PATH - remove existing Java paths and add the new one
    $paths = $env:Path -split ';' | Where-Object { 
        $_ -notmatch 'Java\\.*\\bin' -and 
        $_ -notmatch 'jdk.*\\bin' -and
        $_ -notmatch 'Eclipse Foundation\\.*\\bin' -and
        $_ -notmatch 'Eclipse Adoptium\\.*\\bin'
    }
    $env:Path = ($paths + $javaPath) -join ';'

    Write-Host "Switched to Java $Version" -ForegroundColor Green
    java -version
    return $true
}

# Create dynamic aliases for all installed Java versions
function Register-JavaAliases {
    Get-JavaInstallations | ForEach-Object {
        $version = $_.Version
        $aliasName = "java$version"
        
        # Create a function instead of a script block
        $functionName = "Switch-ToJava$version"
        $scriptBlock = [ScriptBlock]::Create("function global:$functionName { Set-JavaVersion $version }")
        . $scriptBlock
        
        # Create alias pointing to the function
        Set-Alias -Name $aliasName -Value $functionName -Force -Scope Global
    }
}

# Set up main aliases
Set-Alias -Name setjdk -Value Set-JavaVersion -Force
Set-Alias -Name javalist -Value Set-JavaVersion -Force

# Register Java version aliases when the module loads
Register-JavaAliases