# Import tests.
#
# An import has to be silent, repeatable, and export exactly what the platform
# rules say it should. On macOS and Linux that means the sixteen shadowing
# aliases stay out of the session.

BeforeAll {
    $script:ModuleRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'HyperShell'
    $script:Manifest = Import-PowerShellDataFile -LiteralPath (Join-Path $script:ModuleRoot 'HyperShell.psd1')

    # Names that only make sense on Windows: they cover a PowerShell built-in
    # alias or a real Unix binary.
    $script:ShadowAliases = @(
        'ls', 'cat', 'less', 'which', 'wget', 'pkill', 'ifconfig', 'clear',
        'history', 'grep', 'sed', 'awk', 'find', 'touch', 'mkdir', 'tail'
    )
}

Describe 'HyperShell import' {
    BeforeAll {
        Remove-Module HyperShell -Force -ErrorAction SilentlyContinue
        $script:importWarnings = @()
        $script:importErrors = @()
        Import-Module $script:ModuleRoot -Force `
            -WarningVariable importWarnings `
            -ErrorVariable importErrors `
            -ErrorAction SilentlyContinue
        $script:importWarnings = $importWarnings
        $script:importErrors = $importErrors
        $script:Module = Get-Module HyperShell
    }

    It 'imports without errors' {
        $script:importErrors -join "`n" | Should -BeNullOrEmpty
    }

    It 'imports without warnings' {
        # Unapproved verbs are the usual source of an import warning, so this
        # doubles as a naming check.
        $script:importWarnings -join "`n" | Should -BeNullOrEmpty
    }

    It 'reports the manifest version' {
        $script:Module.Version.ToString() | Should -Be $script:Manifest.ModuleVersion
    }

    It 'exports exactly the functions the manifest lists' {
        $exported = $script:Module.ExportedFunctions.Keys | Sort-Object
        $listed = $script:Manifest.FunctionsToExport | Sort-Object

        ($listed | Where-Object { $_ -notin $exported }) -join ', ' | Should -BeNullOrEmpty
        ($exported | Where-Object { $_ -notin $listed }) -join ', ' | Should -BeNullOrEmpty
    }

    It 'exports exactly the aliases the platform rules allow' {
        $exported = $script:Module.ExportedAliases.Keys | Sort-Object
        $expected = if ($IsWindows) {
            $script:Manifest.AliasesToExport | Sort-Object
        }
        else {
            $script:Manifest.AliasesToExport | Where-Object { $_ -notin $script:ShadowAliases } | Sort-Object
        }

        ($expected | Where-Object { $_ -notin $exported }) -join ', ' | Should -BeNullOrEmpty
        ($exported | Where-Object { $_ -notin $expected }) -join ', ' | Should -BeNullOrEmpty
    }

    It 'leaves the system tools alone off Windows' -Skip:$IsWindows {
        foreach ($name in $script:ShadowAliases) {
            $script:Module.ExportedAliases.Keys | Should -Not -Contain $name
        }
    }

    It 'exports no cmdlets or variables' {
        $script:Module.ExportedCmdlets.Count | Should -Be 0
        $script:Module.ExportedVariables.Count | Should -Be 0
    }

    It 'reimports cleanly' {
        { Import-Module $script:ModuleRoot -Force -ErrorAction Stop } | Should -Not -Throw
        (Get-Module HyperShell).ExportedFunctions.Count |
            Should -Be $script:Manifest.FunctionsToExport.Count
    }

    It 'every exported alias points at something the module exports' {
        $functions = $script:Module.ExportedFunctions.Keys
        foreach ($alias in $script:Module.ExportedAliases.Values) {
            # Aliases onto external tools (k, kx, kns) are fine, and so is a
            # built-in cmdlet (which -> Get-Command); what this catches is a
            # Verb-Noun target the module claims to ship but does not.
            if ($alias.Definition -match '^[A-Z][a-z]+-') {
                if (-not (Get-Command $alias.Definition -CommandType Cmdlet -ErrorAction SilentlyContinue)) {
                    $functions | Should -Contain $alias.Definition
                }
            }
        }
    }
}
