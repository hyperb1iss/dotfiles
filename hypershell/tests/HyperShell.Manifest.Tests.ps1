# Manifest tests.
#
# The manifest is the contract: it decides what the module exports. These
# tests keep it honest against the files it claims to describe, so a new
# command or alias cannot be added without appearing in the manifest.

BeforeAll {
    $script:ModuleRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'HyperShell'
    $script:ManifestPath = Join-Path $script:ModuleRoot 'HyperShell.psd1'
    $script:Manifest = Import-PowerShellDataFile -LiteralPath $script:ManifestPath

    Import-Module $script:ModuleRoot -Force
    $script:Module = Get-Module HyperShell

    # Every function defined at the top level of a Public file, read straight
    # from the source rather than from the loaded module.
    $script:PublicFunctions = @(
        Get-ChildItem -LiteralPath (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1' | ForEach-Object {
            $parseErrors = $null
            $tokens = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$parseErrors)
            $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) |
                ForEach-Object { $_.Name }
        }
    ) | Sort-Object
}

Describe 'HyperShell manifest' {
    It 'passes Test-ModuleManifest' {
        { Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop } | Should -Not -Throw
    }

    It 'declares the identity fields' {
        $script:Manifest.ModuleVersion | Should -Not -BeNullOrEmpty
        $script:Manifest.GUID | Should -Match '^[0-9a-f]{8}-'
        $script:Manifest.Author | Should -Not -BeNullOrEmpty
        $script:Manifest.Description | Should -Not -BeNullOrEmpty
        $script:Manifest.RootModule | Should -Be 'HyperShell.psm1'
    }

    It 'targets PowerShell 7.4 Core' {
        $script:Manifest.PowerShellVersion | Should -Be '7.4'
        $script:Manifest.CompatiblePSEditions | Should -Be @('Core')
    }

    It 'requires only modules the code actually uses' {
        # PSReadLine ships with PowerShell 7 and backs the keybindings.
        # posh-git and Terminal-Icons are optional, so they must not be here:
        # a RequiredModules entry makes Import-Module fail outright when the
        # module is missing.
        $script:Manifest.RequiredModules | Should -Be @('PSReadLine')
        $script:Manifest.PrivateData.HyperShell.OptionalModules |
            Should -Be @('posh-git', 'Terminal-Icons')
    }

    It 'exports no wildcards' {
        foreach ($name in @($script:Manifest.FunctionsToExport) + @($script:Manifest.AliasesToExport)) {
            $name | Should -Not -Match '\*'
        }

        $script:Manifest.CmdletsToExport | Should -BeNullOrEmpty
        $script:Manifest.VariablesToExport | Should -BeNullOrEmpty
    }

    It 'lists every function defined in Public' {
        $missing = $script:PublicFunctions | Where-Object { $_ -notin $script:Manifest.FunctionsToExport }
        $missing -join ', ' | Should -BeNullOrEmpty
    }

    It 'lists no function that Public does not define' {
        $extra = $script:Manifest.FunctionsToExport | Where-Object { $_ -notin $script:PublicFunctions }
        $extra -join ', ' | Should -BeNullOrEmpty
    }

    It 'lists exactly the aliases the module declares' {
        # Declared covers every Add-HyperShellAlias call, including the ones
        # the platform rules skip, so this holds on Windows and Unix alike.
        $declared = & $script:Module { $script:HyperShellDeclaredAlias } | Sort-Object -Unique
        $listed = $script:Manifest.AliasesToExport | Sort-Object -Unique

        ($declared | Where-Object { $_ -notin $listed }) -join ', ' | Should -BeNullOrEmpty
        ($listed | Where-Object { $_ -notin $declared }) -join ', ' | Should -BeNullOrEmpty
    }
}
