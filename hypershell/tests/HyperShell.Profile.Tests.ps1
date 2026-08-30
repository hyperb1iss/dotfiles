# Profile tests.
#
# The profile is what a real session runs, so it gets exercised the way a real
# session would: a fresh pwsh with -NoProfile and a PSModulePath pointing at
# this checkout, which is also how the installer arranges things on a machine.

BeforeAll {
    $script:HyperShellDir = Split-Path -Parent $PSScriptRoot
    $script:ProfilePath = Join-Path $script:HyperShellDir 'Microsoft.PowerShell_profile.ps1'

    # A directory that looks like a PSModulePath entry: <dir>/HyperShell/...
    # The installer builds the same shape with a symlink.
    $script:ModulePathRoot = $script:HyperShellDir

    function Invoke-InFreshSession {
        param([string]$Script)

        $pwshPath = (Get-Process -Id $PID).Path
        $wrapper = @"
`$env:PSModulePath = '$($script:ModulePathRoot)' + [IO.Path]::PathSeparator + `$env:PSModulePath
$Script
"@
        $output = & $pwshPath -NoProfile -NonInteractive -Command $wrapper 2>&1
        return ($output | Out-String)
    }
}

Describe 'HyperShell profile' {
    It 'loads in a fresh session and imports the module' {
        $output = Invoke-InFreshSession @"
. '$($script:ProfilePath)'
"module: `$((Get-Module HyperShell).Name)"
"functions: `$((Get-Module HyperShell).ExportedFunctions.Count)"
"@
        $output | Should -Match 'module: HyperShell'
        $output | Should -Match 'functions: \d+'
        $output | Should -Not -Match 'Exception|ParserError|CommandNotFoundException'
    }

    It 'resolves the module off PSModulePath rather than a hardcoded path' {
        $output = Invoke-InFreshSession @"
Import-Module HyperShell
(Get-Module HyperShell).Path
"@
        $output.Trim() | Should -BeLike '*HyperShell*HyperShell.psm1'
    }

    It 'installs a prompt' {
        $output = Invoke-InFreshSession @"
. '$($script:ProfilePath)'
"prompt: `$([bool](Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue))"
"@
        $output | Should -Match 'prompt: True'
    }

    It 'warns rather than throwing when the module is missing' {
        # PSModulePath points at a dedicated empty directory, not the system
        # temp root: PowerShell enumerates every entry on that path looking
        # for modules, and scanning a busy /var/folders tree takes a minute
        # and a half.
        $emptyRoot = Join-Path ([IO.Path]::GetTempPath()) "hypershell-empty-$(New-Guid)"
        New-Item -ItemType Directory -Path $emptyRoot -Force | Out-Null
        $profileCopy = Join-Path $emptyRoot 'orphan-profile.ps1'
        Copy-Item -LiteralPath $script:ProfilePath -Destination $profileCopy -Force

        try {
            $pwshPath = (Get-Process -Id $PID).Path
            $output = & $pwshPath -NoProfile -NonInteractive -Command @"
`$env:PSModulePath = '$emptyRoot'
`$env:DOTFILES = Join-Path '$emptyRoot' 'no-dotfiles-here'
`$env:HOME = Join-Path '$emptyRoot' 'no-home-here'
. '$profileCopy'
'survived'
"@ 2>&1 | Out-String

            $output | Should -Match 'survived'
            $output | Should -Match 'HyperShell module not found'
        }
        finally {
            Remove-Item -LiteralPath $emptyRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'hardcodes no dotfiles checkout path' {
        $content = Get-Content -LiteralPath $script:ProfilePath -Raw
        $content | Should -Not -Match '\$HOME\\dotfiles'
        $content | Should -Not -Match 'dotfiles\\hypershell'
    }
}
