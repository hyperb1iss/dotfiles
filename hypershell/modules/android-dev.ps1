# Android Development Tools for HyperShell
# Provides specialized functions for Android app development workflows

# Store last used project directory for context switching
$script:lastAndroidProject = $null

function Find-AndroidProject {
    # Look for build.gradle or build.gradle.kts up the directory tree
    $current = Get-Location
    while ($null -ne $current) {
        if ((Test-Path (Join-Path $current "build.gradle")) -or (Test-Path (Join-Path $current "build.gradle.kts"))) {
            return $current
        }
        $current = Split-Path $current -Parent
    }
    return $null
}

function Invoke-GradleWrapper {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    
    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) {
        Write-Error "Not in an Android project directory (no build.gradle found)"
        return
    }

    $gradlew = Join-Path $projectRoot "gradlew.bat"
    if (-not (Test-Path $gradlew)) {
        Write-Error "gradlew.bat not found in project root"
        return
    }

    & $gradlew $Arguments
}

function Invoke-AndroidTest {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [string]$TestName,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$GradleArgs
    )

    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) {
        Write-Error "Not in an Android project directory"
        return
    }

    if (-not $TestName) {
        # Run all tests when no specific test is provided
        Write-Host "Running all tests..."
        Invoke-GradleWrapper "test" $GradleArgs
        return
    }

    # Pass the test pattern directly to Gradle
    $baseArgs = @("testDebug", "--tests", "*$TestName*", "--info")
    $allArgs = $baseArgs + $GradleArgs

    Write-Host "Running Gradle with arguments: $($allArgs -join ' ')"
    Invoke-GradleWrapper $allArgs
}

function Invoke-AndroidBuild {
    Invoke-GradleWrapper "assembleDebug" $args
}

function Invoke-KtlintCheck {
    Invoke-GradleWrapper "ktlintCheck" $args
}

function Invoke-KtlintFormat {
    Invoke-GradleWrapper "ktlintFormat" $args
}

function Set-AndroidProjectLocation {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Path
    )

    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) {
        Write-Error "Not in an Android project directory"
        return
    }

    # Save current project context
    $script:lastAndroidProject = $projectRoot

    # Go to specified path under project root
    if ($Path) {
        $targetPath = Join-Path $projectRoot ($Path -join '\')
        if (Test-Path $targetPath) {
            Set-Location $targetPath
        }
        else {
            Write-Error "Path not found: $targetPath"
        }
    }
}

# Quick switch between test and implementation files
function Switch-AndroidSourceFile {
    $current = Get-Location
    $file = Get-ChildItem -Filter "*.kt" | Select-Object -First 1
    
    if (-not $file) {
        Write-Error "No Kotlin file found in current directory"
        return
    }

    $fileName = $file.BaseName
    if ($current -match "src[/\\]test") {
        # In test directory, switch to main implementation
        $mainPath = $current -replace "src[/\\]test", "src/main"
        $implFile = Get-ChildItem -Path $mainPath -Filter "$($fileName -replace 'Test$', '').kt" -Recurse |
        Select-Object -First 1
        if ($implFile) {
            Set-Location $implFile.Directory
        }
    }
    else {
        # In main directory, switch to test
        $testPath = $current -replace "src[/\\]main", "src/test"
        $testFile = Get-ChildItem -Path $testPath -Filter "$($fileName)Test.kt" -Recurse |
        Select-Object -First 1
        if ($testFile) {
            Set-Location $testFile.Directory
        }
    }
}

function Invoke-AndroidInstall {
    Invoke-GradleWrapper "installDebug" $args
}

# Set up aliases
Set-Alias -Name gw -Value Invoke-GradleWrapper -Force
Set-Alias -Name atest -Value Invoke-AndroidTest -Force
Set-Alias -Name abuild -Value Invoke-AndroidBuild -Force
Set-Alias -Name ainstall -Value Invoke-AndroidInstall -Force
Set-Alias -Name ktlint -Value Invoke-KtlintCheck -Force
Set-Alias -Name ktfmt -Value Invoke-KtlintFormat -Force
Set-Alias -Name acd -Value Set-AndroidProjectLocation -Force
Set-Alias -Name asw -Value Switch-AndroidSourceFile -Force

# Register argument completer for gradle tasks
Register-ArgumentCompleter -CommandName gw -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    
    $projectRoot = Find-AndroidProject
    if (-not $projectRoot) { return @() }

    # Cache gradle tasks in a file to avoid running gradle tasks each time
    $cacheFile = Join-Path $projectRoot ".gradle/taskCache.txt"
    $maxCacheAge = [TimeSpan]::FromMinutes(30)

    $tasks = @()
    if (Test-Path $cacheFile) {
        $cacheAge = (Get-Date) - (Get-Item $cacheFile).LastWriteTime
        if ($cacheAge -lt $maxCacheAge) {
            $tasks = Get-Content $cacheFile
        }
    }

    if (-not $tasks) {
        $tasks = & (Join-Path $projectRoot "gradlew.bat") tasks --all |
        Select-String '^\w+\s+-\s+' |
        ForEach-Object { ($_ -split ' - ')[0].Trim() }
        
        if ($tasks) {
            $tasks | Set-Content $cacheFile
        }
    }

    $tasks | Where-Object { $_ -like "$wordToComplete*" } |
    ForEach-Object { 
        [System.Management.Automation.CompletionResult]::new(
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
