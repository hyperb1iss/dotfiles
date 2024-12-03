# FZF integration and related functions

# Basic file search with preview
function Find-FzfFile {
    $file = Get-ChildItem -Recurse | 
    Where-Object { -not $_.PSIsContainer } | 
    Select-Object -ExpandProperty FullName | 
    fzf --preview 'bat.exe --color=always --style=numbers --line-range=:500 {}'
    if ($file) {
        bat $file
    }
}

# Enhanced file finder with preview
function Find-FzfFileWithPreview {
    $file = Get-ChildItem -Recurse | Where-Object { -not $_.PSIsContainer } |
    Select-Object -ExpandProperty FullName |
    fzf --preview 'bat.exe --color=always --style=numbers --line-range=:500 {}' |
    ForEach-Object { $_.Trim() }
    if ($file) {
        bat $file
    }
}

# Basic directory navigation
function Set-FzfLocation {
    $dir = Get-ChildItem -Directory | 
    Select-Object -ExpandProperty FullName | 
    fzf --preview 'dir /a /w "{}"'
    if ($dir) {
        Set-Location $dir
    }
}

# Enhanced directory navigation with preview
function Set-FzfLocationWithPreview {
    $previewCmd = 'powershell.exe -NoProfile -Command "Get-ChildItem -Force \"{}\" | Format-Wide -AutoSize | Out-String"'
    
    $dir = Get-ChildItem -Directory -Recurse |
    Select-Object -ExpandProperty FullName |
    fzf --preview "$previewCmd" |
    ForEach-Object { $_.Trim() }
    if ($dir) {
        Set-Location $dir
    }
}

# Basic history search
function Get-FzfHistory {
    $command = Get-Content (Get-PSReadLineOption).HistorySavePath | 
    fzf --tac --no-sort
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}

# Enhanced history search with preview
function Search-FzfHistoryWithPreview {
    $command = Get-Content (Get-PSReadLineOption).HistorySavePath |
    fzf --tac --no-sort --preview 'echo {}' --preview-window=up:3:wrap |
    ForEach-Object { $_.Trim() }
    
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    }
}

# Interactive process kill
function Stop-FzfProcess {
    $process = Get-Process |
    Format-Table -AutoSize |
    Out-String -Stream |
    fzf --header-lines=3 --multi --preview 'echo {}' |
    ForEach-Object { ($_ -split '\s+')[1] }

    if ($process) {
        $process | ForEach-Object {
            Stop-Process -Id $_ -Force
            Write-Host "Killed process with ID: $_"
        }
    }
}

# Set up key bindings
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { Find-FzfFile }
Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock { Set-FzfLocation }
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock { Get-FzfHistory }

# Set up enhanced key bindings
Set-PSReadLineKeyHandler -Chord Ctrl+Alt+f -ScriptBlock { Find-FzfFileWithPreview }
Set-PSReadLineKeyHandler -Chord Ctrl+Alt+c -ScriptBlock { Set-FzfLocationWithPreview }
Set-PSReadLineKeyHandler -Chord Ctrl+Alt+r -ScriptBlock { Search-FzfHistoryWithPreview }

# Set up aliases
Set-Alias -Name fkill -Value Stop-FzfProcess