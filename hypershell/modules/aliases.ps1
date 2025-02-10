# Command aliases and replacements

# LSD aliases
function Invoke-LSD { lsd $args }
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
New-Alias -Name ls -Value Invoke-LSD -Force

function Invoke-LSDLong { lsd -l $args }
New-Alias -Name ll -Value Invoke-LSDLong -Force

function Invoke-LSDAll { lsd -la $args }
New-Alias -Name la -Value Invoke-LSDAll -Force

function Invoke-LSDTree { lsd --tree $args }
New-Alias -Name lt -Value Invoke-LSDTree -Force

# Use real GNU tools when available
if (Get-Command grep.exe -ErrorAction SilentlyContinue) { New-Alias -Name grep -Value grep.exe -Force }
if (Get-Command find.exe -ErrorAction SilentlyContinue) { New-Alias -Name find -Value find.exe -Force }
if (Get-Command sed.exe -ErrorAction SilentlyContinue) { New-Alias -Name sed -Value sed.exe -Force }
if (Get-Command awk.exe -ErrorAction SilentlyContinue) { New-Alias -Name awk -Value awk.exe -Force }

# Other Linux-like aliases
Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
function Invoke-Cat {
    bat --style=plain --pager=never $args
}
New-Alias -Name cat -Value Invoke-Cat -Force
New-Alias -Name less -Value bat -Force
New-Alias -Name which -Value Get-Command -Force
New-Alias -Name wget -Value Invoke-WebRequest -Force
New-Alias -Name pkill -Value Stop-Process -Force
New-Alias -Name ifconfig -Value ipconfig -Force

# Clear screen with startup banner
function Clear-Host-Custom {
    Clear-Host
    Show-HyperShellStartup
}
Set-Alias -Name clear -Value Clear-Host-Custom

# History command
function Get-History-Custom {
    Get-History | Select-Object -Property CommandLine
}
Set-Alias -Name history -Value Get-History-Custom 