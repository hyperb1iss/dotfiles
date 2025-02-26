# zoxide.ps1 - Fast directory navigation using zoxide
# https://github.com/ajeetdsouza/zoxide

# Initialize zoxide for PowerShell
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # Initialize with 'z' as the command (compatible with previous z.ps1)
    Invoke-Expression (& { (zoxide init powershell --cmd z) -join "`n" })
}
else {
    Write-Warning "zoxide not found. Please install it with 'cargo install zoxide' or your system's package manager."
} 