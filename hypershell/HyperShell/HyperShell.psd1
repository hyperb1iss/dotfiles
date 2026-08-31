@{
    RootModule           = 'HyperShell.psm1'
    ModuleVersion        = '2.0.0'
    GUID                 = '6c6d779c-0bc8-42de-b1ce-18228d6196b5'
    Author               = 'Stefanie Jane'
    CompanyName          = 'hyperbliss.tech'
    Copyright            = '(c) 2024 Stefanie Jane. Licensed under the MIT License.'
    Description          = 'A Linux-inspired PowerShell environment: git, docker, kubernetes, android, java, and network commands with fzf pickers, a starship prompt, and Unix-shaped aliases. Windows is the target; the module loads and tests cleanly on macOS and Linux.'

    PowerShellVersion    = '7.4'
    CompatiblePSEditions = @('Core')

    # PSReadLine ships in the box with PowerShell 7 and holds the keybindings
    # and fzf chords. posh-git and Terminal-Icons are genuinely optional, so
    # they are listed under PrivateData instead of forcing an import failure
    # on a machine that does not have them.
    RequiredModules      = @('PSReadLine')

    FunctionsToExport    = @(
        # Aliases.ps1
        'Clear-HyperShellHost'
        'Get-HyperShellHistory'
        'Invoke-Cat'
        'Invoke-LSD'
        'Invoke-LSDAll'
        'Invoke-LSDLong'
        'Invoke-LSDTree'

        # Android.ps1
        'Set-AndroidDevice'

        # AndroidDev.ps1
        'Find-AndroidProject'
        'Invoke-AndroidBuild'
        'Invoke-AndroidInstall'
        'Invoke-AndroidTest'
        'Invoke-GradleWrapper'
        'Invoke-KtlintCheck'
        'Invoke-KtlintFormat'
        'Set-AndroidProjectLocation'
        'Switch-AndroidSourceFile'

        # Core.ps1
        'Import-HyperShellCompanionModule'
        'Set-HyperShellPSReadLineOption'
        'Update-Profile'

        # Docker.ps1
        'Get-DockerContainer'
        'Get-DockerImage'
        'Select-DockerContainerId'
        'Show-DockerLog'
        'Stop-DockerContainer'

        # Fzf.ps1
        'Find-FzfFile'
        'Find-FzfFileWithPreview'
        'Get-FzfHistory'
        'Search-FzfHistoryWithPreview'
        'Set-FzfLocation'
        'Set-FzfLocationWithPreview'
        'Stop-FzfProcess'
        'Stop-ProcessByName'

        # Git.ps1
        'Add-FzfGitChange'
        'Add-GitChange'
        'Get-GitStatus'
        'Invoke-GitCheckout'
        'Invoke-GitCherryPick'
        'Invoke-GitCommit'
        'Invoke-GitFetch'
        'Invoke-GitPull'
        'Push-GitChange'
        'Show-FzfGitLog'
        'Switch-FzfGitBranch'

        # Java.ps1
        'Get-JavaInstallation'
        'Register-JavaAlias'
        'Set-JavaVersion'

        # Kubernetes.ps1
        'Get-KubeLog'
        'Get-KubePod'
        'Invoke-KubeApply'
        'Invoke-KubeExec'
        'Show-KubernetesHelp'
        'Switch-KubeConfig'

        # Network.ps1
        'Clear-DNSCache'
        'Get-ActiveConnection'
        'Get-DNSInfo'
        'Get-NetworkInterface'
        'Get-NetworkStatistic'
        'Get-ProcessByPort'
        'Get-PublicIP'
        'Test-NetworkConnectivity'
        'Test-PortAvailability'

        # Prompt.ps1
        'Get-HyperShellCurrentDirectoryName'
        'Get-HyperShellNormalizedPath'
        'Get-HyperShellStarshipInitScript'
        'Get-HyperShellStartupStampPath'
        'Get-HyperShellStateDirectory'
        'Initialize-HyperShellPrompt'
        'Invoke-HyperShellPrompt'
        'Set-HyperShellStartupShown'
        'Set-HyperShellWindowTitle'
        'Show-HyperShellInspiration'
        'Show-HyperShellStartup'
        'Test-HyperShellInteractiveSession'
        'Test-HyperShellStartupDue'

        # Utils.ps1
        'Find-File'
        'Get-Tail'
        'New-Directory'
        'New-File'

        # Wsl.ps1
        'ConvertFrom-WSLPath'
        'ConvertTo-WSLPath'
        'Enter-WSL'

        # Zoxide.ps1
        'Get-HyperShellZoxideInitScript'
        'Initialize-HyperShellZoxide'
    )

    # Every alias HyperShell can register. The sixteen that shadow a built-in
    # alias or a real Unix binary (ls, cat, less, which, wget, pkill, ifconfig,
    # clear, history, grep, sed, awk, find, touch, mkdir, tail) are created on
    # Windows only, so on macOS and Linux the module exports the rest of this
    # list and leaves the system tools alone. See Private/Alias.ps1.
    AliasesToExport      = @(
        'abuild'
        'acd'
        'adbdev'
        'ainstall'
        'asw'
        'atest'
        'awk'
        'cat'
        'clear'
        'di'
        'dlog'
        'dns'
        'dps'
        'dstop'
        'find'
        'fkill'
        'flushdns'
        'ga'
        'gadd'
        'gbr'
        'gco'
        'gcom'
        'gcp'
        'gf'
        'glog'
        'gpsh'
        'gpull'
        'grep'
        'gst'
        'gw'
        'history'
        'ifconfig'
        'javalist'
        'k'
        'kaf'
        'kconfig'
        'keti'
        'kgp'
        'khelp'
        'klogs'
        'kns'
        'ktfmt'
        'ktlint'
        'kx'
        'la'
        'less'
        'll'
        'ls'
        'lt'
        'mkdir'
        'netcons'
        'netstats'
        'nics'
        'ping2'
        'pkill'
        'port'
        'pubip'
        'reload'
        'sed'
        'setjdk'
        'tail'
        'testport'
        'touch'
        'wget'
        'which'
        'wsld'
    )

    CmdletsToExport      = @()
    VariablesToExport    = @()

    PrivateData          = @{
        PSData     = @{
            Tags       = @('Shell', 'Profile', 'Windows', 'HyperShell', 'SilkCircuit', 'Starship')
            LicenseUri = 'https://github.com/hyperb1iss/dotfiles/blob/main/LICENSE'
            ProjectUri = 'https://github.com/hyperb1iss/dotfiles'
        }

        HyperShell = @{
            # Installed by setup-windows.ps1 alongside RequiredModules, but the
            # module imports them only when they happen to be present.
            OptionalModules = @('posh-git', 'Terminal-Icons')
        }
    }
}
