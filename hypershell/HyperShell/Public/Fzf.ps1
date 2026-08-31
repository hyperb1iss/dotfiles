# fzf-driven file, directory, history, and process pickers.
#
# Aliases: fkill
#
# The keyboard chords that reach these live in Set-HyperShellPSReadLineOption,
# because they are PSReadLine configuration rather than command definitions.

<#
.SYNOPSIS
    Picks a file with fzf and prints it.
#>
function Find-FzfFile {
    [CmdletBinding()]
    param()

    $file = Get-ChildItem -Recurse -File |
        Select-Object -ExpandProperty FullName |
        fzf --preview (Get-HyperShellFilePreviewCommand)

    if ($file) {
        bat $file
    }
}

<#
.SYNOPSIS
    Picks a file with fzf and prints it, trimming the selection.
.DESCRIPTION
    The Ctrl+Alt+f variant. Behaves like Find-FzfFile but tolerates padded
    output from terminals that pad the selection line.
#>
function Find-FzfFileWithPreview {
    [CmdletBinding()]
    param()

    $file = Get-ChildItem -Recurse -File |
        Select-Object -ExpandProperty FullName |
        fzf --preview (Get-HyperShellFilePreviewCommand) |
        ForEach-Object { $_.Trim() }

    if ($file) {
        bat $file
    }
}

<#
.SYNOPSIS
    Picks a child directory with fzf and moves into it.
#>
function Set-FzfLocation {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $dir = Get-ChildItem -Directory |
        Select-Object -ExpandProperty FullName |
        fzf --preview (Get-HyperShellDirectoryPreviewCommand)

    if (-not $dir) {
        return
    }

    if ($PSCmdlet.ShouldProcess($dir, 'Set-Location')) {
        Set-Location -LiteralPath $dir
    }
}

<#
.SYNOPSIS
    Picks a directory anywhere below the current one and moves into it.
#>
function Set-FzfLocationWithPreview {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $dir = Get-ChildItem -Directory -Recurse |
        Select-Object -ExpandProperty FullName |
        fzf --preview (Get-HyperShellDirectoryPreviewCommand) |
        ForEach-Object { $_.Trim() }

    if (-not $dir) {
        return
    }

    if ($PSCmdlet.ShouldProcess($dir, 'Set-Location')) {
        Set-Location -LiteralPath $dir
    }
}

<#
.SYNOPSIS
    Searches PSReadLine history with fzf and inserts the result.
#>
function Get-FzfHistory {
    [CmdletBinding()]
    param()

    $command = Get-Content (Get-PSReadLineOption).HistorySavePath | fzf --tac --no-sort

    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}

<#
.SYNOPSIS
    Searches PSReadLine history with fzf, with the command in a preview pane.
#>
function Search-FzfHistoryWithPreview {
    [CmdletBinding()]
    param()

    $command = Get-Content (Get-PSReadLineOption).HistorySavePath |
        fzf --tac --no-sort --preview 'echo {}' --preview-window=up:3:wrap |
        ForEach-Object { $_.Trim() }

    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}

<#
.SYNOPSIS
    Picks processes with fzf and kills them.
.DESCRIPTION
    The picker prints its own "<pid> <name> <cpu>" lines rather than parsing
    Format-Table output. The table's second column is NPM(K), not the process
    id, so the old column-index parse killed whatever process happened to have
    a pid matching some other process's memory figure.
#>
function Stop-FzfProcess {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive confirmation output, not pipeline data.')]
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $selected = Get-Process |
        Sort-Object -Property Id |
        ForEach-Object { '{0,-8} {1,-32} {2}' -f $_.Id, $_.ProcessName, $_.CPU } |
        fzf --multi --preview 'echo {}' |
        ForEach-Object { ($_ -split '\s+', 2)[0].Trim() } |
        Where-Object { $_ -match '^\d+$' }

    foreach ($processId in $selected) {
        if ($PSCmdlet.ShouldProcess($processId, 'Stop-Process')) {
            Stop-Process -Id $processId -Force
            Write-Host "Killed process with ID: $processId"
        }
    }
}

Add-HyperShellAlias -Name 'fkill' -Value 'Stop-FzfProcess'
