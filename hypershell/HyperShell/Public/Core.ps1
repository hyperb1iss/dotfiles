# Core session configuration.
#
# Aliases: reload
#
# Importing the module only defines commands. The interactive setup lives in
# functions the profile calls, so `Import-Module HyperShell` stays quiet and
# fast in scripts and CI.

<#
.SYNOPSIS
    Applies HyperShell's PSReadLine configuration.
.DESCRIPTION
    Emacs keybindings, history search on the arrow keys, menu completion on
    Tab, SilkCircuit-leaning syntax colours, and the fzf chords. Called from
    the profile; safe to call again to reapply after changing options by hand.
.EXAMPLE
    Set-HyperShellPSReadLineOption
#>
function Set-HyperShellPSReadLineOption {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not $PSCmdlet.ShouldProcess('PSReadLine', 'Apply HyperShell options')) {
        return
    }

    if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
        Write-Warning 'PSReadLine is not available, skipping keybinding setup.'
        return
    }

    Import-Module PSReadLine -ErrorAction SilentlyContinue

    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    Set-PSReadLineOption -Colors @{
        Command   = [ConsoleColor]::Cyan
        Parameter = [ConsoleColor]::DarkCyan
        Operator  = [ConsoleColor]::DarkGray
        Variable  = [ConsoleColor]::Green
        String    = [ConsoleColor]::Yellow
        Number    = [ConsoleColor]::Magenta
        Type      = [ConsoleColor]::DarkYellow
        Comment   = [ConsoleColor]::DarkGreen
    }

    # fzf chords. Plain chords are the quick versions, Ctrl+Alt adds previews.
    Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { Find-FzfFile }
    Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock { Set-FzfLocation }
    Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock { Get-FzfHistory }
    Set-PSReadLineKeyHandler -Chord Ctrl+Alt+f -ScriptBlock { Find-FzfFileWithPreview }
    Set-PSReadLineKeyHandler -Chord Ctrl+Alt+c -ScriptBlock { Set-FzfLocationWithPreview }
    Set-PSReadLineKeyHandler -Chord Ctrl+Alt+r -ScriptBlock { Search-FzfHistoryWithPreview }

    $env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --preview '$(Get-HyperShellFilePreviewCommand)'"
}

<#
.SYNOPSIS
    Imports the optional companion modules when they are installed.
.DESCRIPTION
    posh-git and Terminal-Icons are nice to have, not required. Starship
    already renders git state in the prompt, so posh-git is only here for its
    completions. Missing modules are skipped without noise.
#>
function Import-HyperShellCompanionModule {
    [CmdletBinding()]
    param()

    foreach ($name in @('posh-git', 'Terminal-Icons')) {
        if (Get-Module -ListAvailable -Name $name) {
            Import-Module -Name $name -Global -ErrorAction SilentlyContinue
        }
    }
}

<#
.SYNOPSIS
    Reloads HyperShell into the current session.
.DESCRIPTION
    Forces a global reimport of the module. Dot-sourcing $PROFILE from inside
    a function would load into that function's scope and vanish on return, so
    this reloads the part that holds every command. Prompt, zoxide, and
    PSReadLine setup still need a fresh session.
.EXAMPLE
    reload
#>
function Update-Profile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive confirmation line, not pipeline data.')]
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not $PSCmdlet.ShouldProcess('HyperShell', 'Reload module')) {
        return
    }

    Import-Module -Name $script:HyperShellRoot -Force -Global
    Write-Host 'HyperShell reloaded. Start a new session to redo prompt setup.' -ForegroundColor Green
}

Add-HyperShellAlias -Name 'reload' -Value 'Update-Profile'
