# Core PowerShell configuration and settings

# Import essential modules
Import-Module PSReadLine
Import-Module posh-git
Import-Module Terminal-Icons

# Configure PSReadLine for Linux-style keybindings
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Enable syntax highlighting
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

# Configure environment variables
$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Function to reload the profile
function Update-Profile {
    . $PROFILE
    Write-Host "PowerShell profile reloaded." -ForegroundColor Green
}
Set-Alias -Name reload -Value Update-Profile