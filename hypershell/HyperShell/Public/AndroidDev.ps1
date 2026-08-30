# Android app development helpers.
#
# Aliases: gw atest abuild ainstall ktlint ktfmt acd asw
#
# Everything routes through the project's Gradle wrapper, found by walking up
# from the current directory.

# Remembers where the last acd came from, so a later call can get back.
$script:HyperShellLastAndroidProject = $null

<#
.SYNOPSIS
    Finds the closest Gradle project root at or above the current directory.
.DESCRIPTION
    Walks up looking for build.gradle or build.gradle.kts. Returns $null when
    there is none.
#>
function Find-AndroidProject {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [string]$StartPath = $PWD.Path
    )

    $current = $StartPath
    while (-not [string]::IsNullOrEmpty($current)) {
        if ((Test-Path -LiteralPath (Join-Path $current 'build.gradle')) -or
            (Test-Path -LiteralPath (Join-Path $current 'build.gradle.kts'))) {
            return $current
        }

        $parent = Split-Path -Path $current -Parent
        if ($parent -eq $current) {
            break
        }

        $current = $parent
    }

    return $null
}

<#
.SYNOPSIS
    Runs the project's Gradle wrapper.
.EXAMPLE
    gw assembleDebug
#>
function Invoke-GradleWrapper {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) {
        Write-Error 'Not in an Android project directory (no build.gradle found)'
        return
    }

    $gradlew = Join-Path $projectRoot (Get-HyperShellGradleWrapperName)
    if (-not (Test-Path -LiteralPath $gradlew)) {
        Write-Error "$(Get-HyperShellGradleWrapperName) not found in $projectRoot"
        return
    }

    & $gradlew @Arguments
}

<#
.SYNOPSIS
    Runs debug unit tests, optionally filtered by name.
.EXAMPLE
    atest LoginViewModel
#>
function Invoke-AndroidTest {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Progress output ahead of the Gradle run.')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$TestName,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$GradleArgs = @()
    )

    if (-not (Find-AndroidProject)) {
        Write-Error 'Not in an Android project directory'
        return
    }

    if (-not $TestName) {
        Write-Host 'Running debug tests...'
        Invoke-GradleWrapper 'testDebug' @GradleArgs
        return
    }

    $allArgs = @('testDebug', '--tests', "*$TestName*", '--info') + $GradleArgs
    Write-Host "Running Gradle with arguments: $($allArgs -join ' ')"
    Invoke-GradleWrapper @allArgs
}

<#
.SYNOPSIS
    Assembles the debug build.
#>
function Invoke-AndroidBuild {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    Invoke-GradleWrapper 'assembleDebug' @Arguments
}

<#
.SYNOPSIS
    Installs the debug build on the connected device.
#>
function Invoke-AndroidInstall {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    Invoke-GradleWrapper 'installDebug' @Arguments
}

<#
.SYNOPSIS
    Runs ktlintCheck.
#>
function Invoke-KtlintCheck {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    Invoke-GradleWrapper 'ktlintCheck' @Arguments
}

<#
.SYNOPSIS
    Runs ktlintFormat.
#>
function Invoke-KtlintFormat {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    Invoke-GradleWrapper 'ktlintFormat' @Arguments
}

<#
.SYNOPSIS
    Moves to a path relative to the Android project root.
.EXAMPLE
    acd app src main
#>
function Set-AndroidProjectLocation {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Path = @()
    )

    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) {
        Write-Error 'Not in an Android project directory'
        return
    }

    $script:HyperShellLastAndroidProject = $projectRoot

    $target = $projectRoot
    foreach ($segment in $Path) {
        $target = Join-Path $target $segment
    }

    if (-not (Test-Path -LiteralPath $target)) {
        Write-Error "Path not found: $target"
        return
    }

    if ($PSCmdlet.ShouldProcess($target, 'Set-Location')) {
        Set-Location -LiteralPath $target
    }
}

<#
.SYNOPSIS
    Jumps between a Kotlin source file and its test.
.DESCRIPTION
    Uses the first .kt file in the current directory to work out which side of
    src/main and src/test we are on, then moves to the matching directory.
#>
function Switch-AndroidSourceFile {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $current = $PWD.Path
    $file = Get-ChildItem -Filter '*.kt' -File | Select-Object -First 1

    if (-not $file) {
        Write-Error 'No Kotlin file found in current directory'
        return
    }

    $fileName = $file.BaseName

    if ($current -match 'src[/\\]test') {
        $mainPath = $current -replace 'src[/\\]test', 'src/main'
        $target = Get-ChildItem -Path $mainPath -Filter "$($fileName -replace 'Test$', '').kt" -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
    }
    else {
        $testPath = $current -replace 'src[/\\]main', 'src/test'
        $target = Get-ChildItem -Path $testPath -Filter "$($fileName)Test.kt" -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
    }

    if (-not $target) {
        Write-Warning "No counterpart found for $fileName"
        return
    }

    if ($PSCmdlet.ShouldProcess($target.Directory.FullName, 'Set-Location')) {
        Set-Location -LiteralPath $target.Directory.FullName
    }
}

Add-HyperShellAlias -Name 'gw' -Value 'Invoke-GradleWrapper'
Add-HyperShellAlias -Name 'atest' -Value 'Invoke-AndroidTest'
Add-HyperShellAlias -Name 'abuild' -Value 'Invoke-AndroidBuild'
Add-HyperShellAlias -Name 'ainstall' -Value 'Invoke-AndroidInstall'
Add-HyperShellAlias -Name 'ktlint' -Value 'Invoke-KtlintCheck'
Add-HyperShellAlias -Name 'ktfmt' -Value 'Invoke-KtlintFormat'
Add-HyperShellAlias -Name 'acd' -Value 'Set-AndroidProjectLocation'
Add-HyperShellAlias -Name 'asw' -Value 'Switch-AndroidSourceFile'

# Gradle task completion for gw, cached for half an hour because
# `gradlew tasks --all` is slow enough to be felt on every Tab.
Register-ArgumentCompleter -CommandName gw -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $null = $commandAst
    $null = $cursorPosition

    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) {
        return @()
    }

    $cacheFile = Join-Path -Path $projectRoot -ChildPath '.gradle' -AdditionalChildPath 'taskCache.txt'
    $maxCacheAge = [TimeSpan]::FromMinutes(30)

    $tasks = @()
    if (Test-Path -LiteralPath $cacheFile) {
        $cacheAge = (Get-Date) - (Get-Item -LiteralPath $cacheFile).LastWriteTime
        if ($cacheAge -lt $maxCacheAge) {
            $tasks = Get-Content -LiteralPath $cacheFile
        }
    }

    if (-not $tasks) {
        $tasks = & (Join-Path $projectRoot (Get-HyperShellGradleWrapperName)) tasks --all |
            Select-String '^\w+\s+-\s+' |
            ForEach-Object { ($_ -split ' - ')[0].Trim() }

        if ($tasks) {
            $tasks | Set-Content -LiteralPath $cacheFile
        }
    }

    $tasks |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
