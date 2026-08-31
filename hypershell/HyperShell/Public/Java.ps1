# Java version switching.
#
# Aliases: setjdk javalist, plus a java<version> alias per installed JDK
#
# The install locations are Windows paths, so discovery returns nothing on
# other platforms. Unix machines get the same commands from sh/java.sh.

<#
.SYNOPSIS
    Discovers installed JDKs.
.DESCRIPTION
    Looks in the usual Windows install roots for Oracle, Eclipse Temurin,
    Adoptium, and Microsoft OpenJDK. Reads the version out of each JDK's
    release file and falls back to parsing the directory name. Returns an
    empty list on non-Windows platforms.
#>
function Get-JavaInstallation {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    if (-not $script:HyperShellIsWindows) {
        return
    }

    $searchRoots = @(
        'C:\Program Files\Java\*jdk*'
        'C:\Program Files\Eclipse Foundation\*jdk*'
        'C:\Program Files\Eclipse Adoptium\*'
        'C:\Program Files\Microsoft\jdk*'
    )

    $installations = @()
    foreach ($root in $searchRoots) {
        if (-not (Test-Path $root)) {
            continue
        }

        foreach ($dir in Get-ChildItem -Path $root -Directory) {
            $version = $null
            $releaseFile = Join-Path $dir.FullName 'release'

            if (Test-Path -LiteralPath $releaseFile) {
                $releaseContent = Get-Content -LiteralPath $releaseFile -Raw
                if ($releaseContent -match 'JAVA_VERSION="?(1\.)?([0-9]+)') {
                    $version = $Matches[2]
                }
            }

            if (-not $version -and $dir.Name -match '(?:jdk-?|openjdk-?)*(1\.)?([0-9]+)') {
                $version = $Matches[2]
            }

            if ($version) {
                $installations += [pscustomobject]@{
                    Version = [int]$version
                    Path    = $dir.FullName
                    Name    = $dir.Name
                }
            }
        }
    }

    return $installations | Sort-Object Version
}

<#
.SYNOPSIS
    Switches JAVA_HOME and PATH to a given JDK version.
.DESCRIPTION
    Called with no version it lists what is installed and marks the active one.
.EXAMPLE
    setjdk 21
#>
function Set-JavaVersion {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Coloured listing for an interactive shell.')]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0)]
        [string]$Version
    )

    if (-not (Test-HyperShellWindows -Feature 'Java version switching')) {
        return
    }

    $installations = @(Get-JavaInstallation)

    if (-not $Version) {
        Write-Host 'Available Java versions:' -ForegroundColor Cyan
        Write-Host '═══════════════════════' -ForegroundColor Cyan

        foreach ($install in $installations) {
            $marker = if ($install.Path -eq $env:JAVA_HOME) { '* ' } else { '  ' }
            Write-Host "$marker Java $($install.Version) ($($install.Name))"
            Write-Host "    Path: $($install.Path)"
            Write-Host "    Commands: java$($install.Version), setjdk $($install.Version)`n"
        }

        Write-Host 'Usage:'
        Write-Host "  - Use 'java<version>' (e.g., java21) for quick switching"
        Write-Host "  - Use 'setjdk <version>' (e.g., setjdk 21) for explicit switching"
        return
    }

    $selected = $installations | Where-Object { $_.Version -eq $Version } | Select-Object -First 1

    if (-not $selected) {
        Write-Host "Error: Java $Version is not installed" -ForegroundColor Red
        Write-Host "Use 'setjdk' without arguments to see available versions" -ForegroundColor Yellow
        return $false
    }

    if (-not $PSCmdlet.ShouldProcess("Java $Version", 'Set JAVA_HOME and PATH')) {
        return
    }

    $env:JAVA_HOME = $selected.Path
    $javaPath = Join-Path $env:JAVA_HOME 'bin'

    # Drop any JDK bin directory already on PATH before adding the new one.
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

<#
.SYNOPSIS
    Creates a java<version> alias for every installed JDK.
.DESCRIPTION
    The aliases land in the global scope because their names are only known at
    runtime, which is also why they cannot appear in the module manifest.
#>
function Register-JavaAlias {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    foreach ($install in @(Get-JavaInstallation)) {
        $version = $install.Version
        $functionName = "Switch-ToJava$version"

        if (-not $PSCmdlet.ShouldProcess("java$version", 'Register alias')) {
            continue
        }

        . ([scriptblock]::Create("function global:$functionName { Set-JavaVersion $version }"))
        Set-Alias -Name "java$version" -Value $functionName -Force -Scope Global
    }
}

Add-HyperShellAlias -Name 'setjdk' -Value 'Set-JavaVersion'
Add-HyperShellAlias -Name 'javalist' -Value 'Get-JavaInstallation'

Register-JavaAlias
