# Command tests.
#
# One or two platform-neutral checks per domain: the pure parsers, the
# argument builders, the platform guards, and the file handling. External
# tools are stubbed so the suite runs on a machine with none of them
# installed.

BeforeAll {
    $script:ModuleRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'HyperShell'

    # Stubs so Pester has something to mock. Real binaries would be shadowed
    # for the duration of the run, which is exactly what we want.
    function global:git { }
    function global:docker { }
    function global:kubectl { }
    function global:fzf { }

    Import-Module $script:ModuleRoot -Force
    $script:Module = Get-Module HyperShell

    $script:TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "hypershell-tests-$(New-Guid)"
    New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null

    # Redirects the module's idea of $HOME, which is how the tests keep
    # ~/.adbdevs and ~/.kube out of the real home directory.
    # $HOME is a read-only automatic variable, so the override has to be a
    # forced Set-Variable in the module's own script scope, which shadows the
    # global one for module code without touching the real session.
    function Set-ModuleHome {
        [CmdletBinding(SupportsShouldProcess)]
        param([string]$Path)

        if (-not $PSCmdlet.ShouldProcess('HyperShell module scope', 'Override $HOME')) {
            return
        }

        $module = Get-Module HyperShell
        & $module { param($p) Set-Variable -Name HOME -Value $p -Scope Script -Force } $Path
    }
}

AfterAll {
    Remove-Item -LiteralPath $script:TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path 'function:global:git', 'function:global:docker',
        'function:global:kubectl', 'function:global:fzf' -ErrorAction SilentlyContinue
}

Describe 'Git helpers' {
    It 'pulls the path out of a git status line' {
        $cases = @{
            ' M sh/git.sh'          = 'sh/git.sh'
            '?? hypershell/new.ps1' = 'hypershell/new.ps1'
            'A  a/b/c.txt'          = 'a/b/c.txt'
            'R  renamed.md'         = 'renamed.md'
        }

        foreach ($line in $cases.Keys) {
            & $script:Module { param($l) ConvertFrom-HyperShellGitStatusLine -Line $l } $line |
                Should -Be $cases[$line]
        }
    }

    It 'ignores lines that are not status entries' {
        foreach ($line in @('', '   ', 'not a status line')) {
            & $script:Module { param($l) ConvertFrom-HyperShellGitStatusLine -Line $l } $line |
                Should -BeNullOrEmpty
        }
    }

    It 'normalizes branch lines into checkout-able names' {
        $cases = @{
            '* main'                        = 'main'
            '  remotes/origin/nova/hs'      = 'nova/hs'
            '  feature/thing'               = 'feature/thing'
        }

        foreach ($line in $cases.Keys) {
            & $script:Module { param($l) ConvertFrom-HyperShellGitBranchLine -Line $l } $line |
                Should -Be $cases[$line]
        }
    }

    It 'passes arguments through to git' {
        Mock git -ModuleName HyperShell { }
        Add-GitChange 'sh/git.sh' 'README.md'
        Should -Invoke git -ModuleName HyperShell -Times 1 -Exactly `
            -ParameterFilter { ($args -join ' ') -eq 'add sh/git.sh README.md' }
    }

    It 'fetches every remote and prunes' {
        Mock git -ModuleName HyperShell { }
        Invoke-GitFetch
        Should -Invoke git -ModuleName HyperShell -Times 1 -Exactly `
            -ParameterFilter { ($args -join ' ') -eq 'fetch --all --prune' }
    }
}

Describe 'Docker helpers' {
    It 'takes the id off the front of an fzf selection' {
        Mock docker -ModuleName HyperShell { 'a1b2c3d4: sparkleflinger' }
        Mock fzf -ModuleName HyperShell { 'a1b2c3d4: sparkleflinger' }

        Select-DockerContainerId -Prompt 'test: ' | Should -Be 'a1b2c3d4'
    }

    It 'returns nothing when the picker is cancelled' {
        Mock docker -ModuleName HyperShell { '' }
        Mock fzf -ModuleName HyperShell { '' }

        Select-DockerContainerId 6> $null | Should -BeNullOrEmpty
    }
}

Describe 'Kubernetes helpers' {
    It 'passes arguments through to kubectl' {
        Mock kubectl -ModuleName HyperShell { }
        Get-KubePod '-n' 'kube-system'
        Should -Invoke kubectl -ModuleName HyperShell -Times 1 -Exactly `
            -ParameterFilter { ($args -join ' ') -eq 'get pods -n kube-system' }
    }

    It 'applies a manifest with -f' {
        Mock kubectl -ModuleName HyperShell { }
        Invoke-KubeApply 'deployment.yaml'
        Should -Invoke kubectl -ModuleName HyperShell -Times 1 -Exactly `
            -ParameterFilter { ($args -join ' ') -eq 'apply -f deployment.yaml' }
    }

    It 'switches KUBECONFIG to a file under ~/.kube/configs' {
        $fakeHome = Join-Path $script:TempRoot 'kube-home'
        $configs = Join-Path $fakeHome '.kube/configs'
        New-Item -ItemType Directory -Path $configs -Force | Out-Null
        Set-Content -Path (Join-Path $configs 'staging') -Value 'apiVersion: v1'

        $previous = $env:KUBECONFIG
        try {
            Set-ModuleHome -Path $fakeHome
            Switch-KubeConfig -ConfigName 'staging' 6> $null
            $env:KUBECONFIG | Should -Be (Join-Path $configs 'staging')
        }
        finally {
            $env:KUBECONFIG = $previous
            Set-ModuleHome -Path $HOME
        }
    }

    It 'warns and returns false for a config that does not exist' {
        Set-ModuleHome -Path (Join-Path $script:TempRoot 'kube-home')
        try {
            $result = Switch-KubeConfig -ConfigName 'nope' -WarningVariable warned -WarningAction SilentlyContinue
            $warned -join ' ' | Should -Match 'not found'
            # Callers can test the result, the way the original did.
            $result | Should -BeFalse
        }
        finally {
            Set-ModuleHome -Path $HOME
        }
    }

    It 'creates the config directory on a fresh machine' {
        $fresh = Join-Path $script:TempRoot 'kube-fresh'
        New-Item -ItemType Directory -Path $fresh -Force | Out-Null
        try {
            Set-ModuleHome -Path $fresh
            Switch-KubeConfig 6> $null
            Test-Path -LiteralPath (Join-Path $fresh '.kube/configs') | Should -BeTrue
        }
        finally {
            Set-ModuleHome -Path $HOME
        }
    }
}

Describe 'Android device aliases' {
    It 'splits an entry on the first colon only' {
        $parsed = & $script:Module { ConvertFrom-HyperShellDeviceAliasLine -Line 'pixel:192.168.1.5:5555' }
        $parsed.Alias | Should -Be 'pixel'
        $parsed.Serial | Should -Be '192.168.1.5:5555'
    }

    It 'rejects blank and malformed entries' {
        foreach ($line in @('', '   ', 'no-colon', 'trailing:')) {
            & $script:Module { param($l) ConvertFrom-HyperShellDeviceAliasLine -Line $l } $line |
                Should -BeNullOrEmpty
        }
    }

    It 'adds, replaces, and removes entries in ~/.adbdevs' {
        $fakeHome = Join-Path $script:TempRoot 'adb-home'
        New-Item -ItemType Directory -Path $fakeHome -Force | Out-Null
        $configFile = Join-Path $fakeHome '.adbdevs'

        $previousSerial = $env:ANDROID_SERIAL
        try {
            Set-ModuleHome -Path $fakeHome

            Set-AndroidDevice '--add' 'pixel' '192.168.1.5:5555' 6> $null
            Set-AndroidDevice '--add' 'tab' 'R5CT30' 6> $null
            Get-Content -LiteralPath $configFile | Should -Contain 'pixel:192.168.1.5:5555'
            Get-Content -LiteralPath $configFile | Should -Contain 'tab:R5CT30'

            # Adding the same alias replaces rather than duplicates.
            Set-AndroidDevice '--add' 'pixel' '10.0.0.9:5555' 6> $null
            @(Get-Content -LiteralPath $configFile | Where-Object { $_ -like 'pixel:*' }).Count |
                Should -Be 1

            Set-AndroidDevice 'pixel' 6> $null
            $env:ANDROID_SERIAL | Should -Be '10.0.0.9:5555'

            Set-AndroidDevice '--remove' 'pixel' 6> $null
            Get-Content -LiteralPath $configFile | Should -Not -Contain 'pixel:10.0.0.9:5555'
        }
        finally {
            $env:ANDROID_SERIAL = $previousSerial
            Set-ModuleHome -Path $HOME
        }
    }

    It 'keeps comments and unparseable lines when rewriting' {
        $fakeHome = Join-Path $script:TempRoot 'adb-preserve'
        New-Item -ItemType Directory -Path $fakeHome -Force | Out-Null
        $configFile = Join-Path $fakeHome '.adbdevs'
        Set-Content -LiteralPath $configFile -Value @('# my devices', 'pixel:1.2.3.4:5555', 'garbage line')

        try {
            Set-ModuleHome -Path $fakeHome
            Set-AndroidDevice '--add' 'tab' 'R5CT30' 6> $null

            $lines = Get-Content -LiteralPath $configFile
            $lines | Should -Contain '# my devices'
            $lines | Should -Contain 'garbage line'
            $lines | Should -Contain 'tab:R5CT30'
        }
        finally {
            Set-ModuleHome -Path $HOME
        }
    }
}

Describe 'Android project discovery' {
    It 'walks up to the nearest Gradle root' {
        $root = Join-Path $script:TempRoot 'gradle-project'
        $deep = Join-Path $root 'app/src/main/kotlin'
        New-Item -ItemType Directory -Path $deep -Force | Out-Null
        Set-Content -Path (Join-Path $root 'build.gradle.kts') -Value ''

        Find-AndroidProject -StartPath $deep | Should -Be $root
    }

    It 'returns nothing outside a Gradle project' {
        $bare = Join-Path $script:TempRoot 'not-a-project'
        New-Item -ItemType Directory -Path $bare -Force | Out-Null

        Find-AndroidProject -StartPath $bare | Should -BeNullOrEmpty
    }

    It 'picks the Gradle wrapper for the platform' {
        $module = $script:Module
        $expected = if ($IsWindows) { 'gradlew.bat' } else { 'gradlew' }
        & $module { Get-HyperShellGradleWrapperName } | Should -Be $expected

        & $module { $script:HyperShellIsWindows = $true }
        try {
            & $module { Get-HyperShellGradleWrapperName } | Should -Be 'gradlew.bat'
        }
        finally {
            & $module { param($w) $script:HyperShellIsWindows = $w } ([bool]$IsWindows)
        }
    }
}

Describe 'Platform guards' {
    It 'warns and returns nothing for Windows-only network commands' -Skip:$IsWindows {
        Get-ProcessByPort -Port 8080 -WarningVariable warned -WarningAction SilentlyContinue |
            Should -BeNullOrEmpty
        $warned -join ' ' | Should -Match 'needs Windows'
    }

    It 'warns and returns nothing for WSL commands' -Skip:$IsWindows {
        ConvertTo-WSLPath -WindowsPath 'C:\dev' -WarningVariable warned -WarningAction SilentlyContinue |
            Should -BeNullOrEmpty
        $warned -join ' ' | Should -Match 'needs Windows'
    }

    It 'finds no JDKs off Windows' -Skip:$IsWindows {
        @(Get-JavaInstallation).Count | Should -Be 0
    }

    It 'names the feature in the warning' {
        & $script:Module { $script:HyperShellIsWindows = $false }
        try {
            & $script:Module { Test-HyperShellWindows -Feature 'Widget polishing' } `
                -WarningVariable warned -WarningAction SilentlyContinue | Should -BeFalse
        }
        finally {
            & $script:Module { param($w) $script:HyperShellIsWindows = $w } ([bool]$IsWindows)
        }
    }
}

Describe 'fzf preview commands' {
    It 'previews directories with the platform listing tool' {
        $module = $script:Module
        try {
            & $module { $script:HyperShellIsWindows = $true }
            & $module { Get-HyperShellDirectoryPreviewCommand } | Should -Match '^cmd /c dir'

            & $module { $script:HyperShellIsWindows = $false }
            & $module { Get-HyperShellDirectoryPreviewCommand } | Should -Match '^ls -la'
        }
        finally {
            & $module { param($w) $script:HyperShellIsWindows = $w } ([bool]$IsWindows)
        }
    }

    It 'previews files with bat when bat is installed' {
        $command = & $script:Module { Get-HyperShellFilePreviewCommand }
        if (Get-Command bat -ErrorAction SilentlyContinue) {
            $command | Should -Match '^bat --color=always'
        }
        else {
            $command | Should -Match '(cat|type)'
        }
    }
}

Describe 'Paths and prompt helpers' {
    It 'replaces the home directory with a tilde' {
        Get-HyperShellNormalizedPath -Path (Join-Path $HOME 'dev') | Should -Be '~/dev'.Replace('/', [IO.Path]::DirectorySeparatorChar)
        Get-HyperShellNormalizedPath -Path '/opt/homebrew' | Should -Be '/opt/homebrew'
        Get-HyperShellNormalizedPath -Path '' | Should -BeNullOrEmpty
    }

    It 'prefers LOCALAPPDATA then XDG_CACHE_HOME for state' {
        $previousLocal = $env:LOCALAPPDATA
        $previousXdg = $env:XDG_CACHE_HOME
        try {
            $env:LOCALAPPDATA = Join-Path $script:TempRoot 'localappdata'
            Get-HyperShellStateDirectory | Should -Be (Join-Path $env:LOCALAPPDATA 'HyperShell')

            $env:LOCALAPPDATA = ''
            $env:XDG_CACHE_HOME = Join-Path $script:TempRoot 'xdg'
            Get-HyperShellStateDirectory | Should -Be (Join-Path $env:XDG_CACHE_HOME 'hypershell')
        }
        finally {
            $env:LOCALAPPDATA = $previousLocal
            $env:XDG_CACHE_HOME = $previousXdg
        }
    }

    It 'stamps the banner date and skips the second run that day' {
        $previousLocal = $env:LOCALAPPDATA
        $previousXdg = $env:XDG_CACHE_HOME
        try {
            $env:LOCALAPPDATA = Join-Path $script:TempRoot 'banner'
            $env:XDG_CACHE_HOME = Join-Path $script:TempRoot 'banner'

            Show-HyperShellStartup -Force -PassThru 6> $null | Should -BeTrue
            $stamp = Get-HyperShellStartupStampPath
            Test-Path -LiteralPath $stamp | Should -BeTrue
            Get-Content -LiteralPath $stamp | Should -Be (Get-Date -Format 'yyyy-MM-dd')

            # Not due again today.
            Test-HyperShellStartupDue | Should -BeFalse
        }
        finally {
            $env:LOCALAPPDATA = $previousLocal
            $env:XDG_CACHE_HOME = $previousXdg
        }
    }

    It 'resolves the dotfiles root from DOTFILES' {
        $previous = $env:DOTFILES
        try {
            $env:DOTFILES = $script:TempRoot
            & $script:Module { Get-HyperShellDotfilesRoot } | Should -Be $script:TempRoot

            $env:DOTFILES = Join-Path $script:TempRoot 'does-not-exist'
            $resolved = & $script:Module { Get-HyperShellDotfilesRoot }
            $resolved | Should -Not -Be $env:DOTFILES
        }
        finally {
            $env:DOTFILES = $previous
        }
    }

    It 'actually sets the window title' {
        # The function swallows host errors by design, so asserting it does
        # not throw would pass no matter what. Read the title back instead,
        # and skip on a host that does not support one.
        $supported = $true
        $previous = $null
        try { $previous = $Host.UI.RawUI.WindowTitle } catch { $supported = $false }

        if (-not $supported) {
            Set-ItResult -Skipped -Because 'this host has no window title'
            return
        }

        try {
            Set-HyperShellWindowTitle -Title 'HyperShell test title'
            $Host.UI.RawUI.WindowTitle | Should -Be 'HyperShell test title'

            Set-HyperShellWindowTitle -Title 'never applied' -WhatIf
            $Host.UI.RawUI.WindowTitle | Should -Be 'HyperShell test title'
        }
        finally {
            try { $Host.UI.RawUI.WindowTitle = $previous }
            catch { Write-Debug "could not restore the window title: $($_.Exception.Message)" }
        }
    }

    It 'installs a fallback prompt when starship is skipped' {
        $previousPrompt = (Get-Command -Name prompt -CommandType Function -ErrorAction SilentlyContinue).ScriptBlock
        try {
            Initialize-HyperShellPrompt -NoStarship
            prompt | Should -Match 'HyperShell'
        }
        finally {
            if ($previousPrompt) {
                Set-Item -Path 'function:prompt' -Value $previousPrompt
            }
        }
    }
}

Describe 'File utilities' {
    It 'creates a file the way touch does' {
        $path = Join-Path $script:TempRoot 'touched.txt'
        New-File -Path $path | Out-Null
        Test-Path -LiteralPath $path | Should -BeTrue
    }

    It 'creates a directory tree the way mkdir -p does' {
        $path = Join-Path $script:TempRoot 'a/b/c'
        New-Directory -Path $path
        Test-Path -LiteralPath $path | Should -BeTrue
    }

    It 'still accepts the original -file parameter name' {
        $path = Join-Path $script:TempRoot 'by-old-name.txt'
        New-File -file $path | Out-Null
        Test-Path -LiteralPath $path | Should -BeTrue
    }

    It 'binds Get-Tail in every call form' {
        # Get-Tail follows the file with -Wait, so it is never pointed at a
        # real one here. Parameter binding happens before the body runs, and a
        # missing path fails immediately rather than waiting, so a binding
        # fault is distinguishable from the expected path error. This exists
        # because an [Alias('lines')] on $Lines once aliased the parameter to
        # itself and broke every single call, with nothing to catch it.
        $missing = Join-Path $script:TempRoot 'no-such-file.log'

        $forms = @(
            { Get-Tail -Path $missing -Lines 2 -ErrorAction Stop }
            { Get-Tail -file $missing -Lines 2 -ErrorAction Stop }
            { Get-Tail $missing 2 -ErrorAction Stop }
            { Get-Tail -path $missing -lines 2 -ErrorAction Stop }
        )

        foreach ($form in $forms) {
            $failure = $null
            try { & $form }
            catch { $failure = $_ }

            $failure | Should -Not -BeNullOrEmpty
            $failure.Exception.Message | Should -Not -Match 'conflicts with the parameter alias'
            $failure.FullyQualifiedErrorId | Should -Match 'PathNotFound|ItemNotFound'
        }
    }

    It 'creates every file touch is given' {
        $first = Join-Path $script:TempRoot 'multi-one.txt'
        $second = Join-Path $script:TempRoot 'multi-two.txt'
        New-File $first $second | Out-Null

        Test-Path -LiteralPath $first | Should -BeTrue
        Test-Path -LiteralPath $second | Should -BeTrue
    }

    It 'refuses a mistyped parameter instead of creating a file named after it' {
        $probe = Join-Path $script:TempRoot 'dash-guard'
        New-Item -ItemType Directory -Path $probe -Force | Out-Null
        Push-Location $probe
        try {
            { New-File -notaparam 'real.txt' -ErrorAction Stop } | Should -Throw
            @(Get-ChildItem -LiteralPath $probe).Count | Should -Be 0
        }
        finally {
            Pop-Location
        }
    }

    It 'errors rather than prompting when mkdir gets no path' {
        # Mandatory would make a bare mkdir block on a prompt, which hangs any
        # script that hits it. It has to fail instead.
        (Get-Command New-Directory).Parameters['Path'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
            ForEach-Object { $_.Mandatory } |
            Should -Not -Contain $true

        { New-Directory -ErrorAction Stop } | Should -Throw
    }

    It 'supports -WhatIf' {
        $path = Join-Path $script:TempRoot 'never-created.txt'
        New-File -Path $path -WhatIf | Out-Null
        Test-Path -LiteralPath $path | Should -BeFalse
    }
}

Describe 'Reloading' {
    It 'keeps the prompt and zoxide alive across a reload' {
        # Import-Module -Force -Global tears down the old module instance,
        # and the global prompt function and zoxide's globals go with it, so
        # reload has to put the session back together afterwards.
        $pwshPath = (Get-Process -Id $PID).Path
        $moduleRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'HyperShell'
        $profilePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'Microsoft.PowerShell_profile.ps1'

        $output = & $pwshPath -NoProfile -NonInteractive -Command @"
`$env:PSModulePath = '$(Split-Path -Parent $moduleRoot)' + [IO.Path]::PathSeparator + `$env:PSModulePath
. '$profilePath'
Update-Profile 6> `$null
"prompt=`$([bool](Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue))"
"@ 2>&1 | Out-String

        $output | Should -Match 'prompt=True'
    }
}

Describe 'PSReadLine configuration' {
    It 'applies and sets the fzf preview options' {
        # This genuinely rebinds keys in the running session, which is fine in
        # a throwaway `make test` process but rude if someone runs Pester
        # interactively, so the environment variable is put back afterwards.
        $previousFzf = $env:FZF_DEFAULT_OPTS
        try {
            { Set-HyperShellPSReadLineOption } | Should -Not -Throw
            $env:FZF_DEFAULT_OPTS | Should -Match '--height 40%'
        }
        finally {
            $env:FZF_DEFAULT_OPTS = $previousFzf
        }
    }
}
