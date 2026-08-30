# Pure helpers: parsing and command building, no side effects.
#
# Everything here takes strings and returns strings or objects, which keeps the
# interactive commands thin and gives the test suite something it can exercise
# on any platform.

<#
.SYNOPSIS
    Pulls the path out of a `git status --short` line.
.DESCRIPTION
    Lines look like " M sh/git.sh" or "?? new-file". Returns the path, or
    $null when the line is not a status entry (a blank line, or fzf noise).
.EXAMPLE
    ConvertFrom-HyperShellGitStatusLine -Line ' M sh/git.sh'   # sh/git.sh
#>
function ConvertFrom-HyperShellGitStatusLine {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Line
    )

    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }

    if ($Line -match '^\s*[MADRCU?!]{1,2}\s+(.+)$') {
        return $Matches[1].Trim()
    }

    return $null
}

<#
.SYNOPSIS
    Normalizes a `git branch --all` line into a checkout-able branch name.
.DESCRIPTION
    Strips the current-branch marker and the remotes/origin/ prefix so the
    result can be handed straight to git checkout.
.EXAMPLE
    ConvertFrom-HyperShellGitBranchLine -Line '  remotes/origin/main'   # main
#>
function ConvertFrom-HyperShellGitBranchLine {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Line
    )

    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }

    $branch = $Line.Trim()
    if ($branch.StartsWith('* ')) {
        $branch = $branch.Substring(2).Trim()
    }

    $branch = $branch -replace '^remotes/origin/', ''

    if ([string]::IsNullOrWhiteSpace($branch)) {
        return $null
    }

    return $branch
}

<#
.SYNOPSIS
    Parses one line of the ~/.adbdevs alias file.
.DESCRIPTION
    Entries are "alias:serial". The serial can itself contain colons when the
    device is a network target, so the split happens on the first colon only.
    Returns $null for blank or malformed lines.
.EXAMPLE
    ConvertFrom-HyperShellDeviceAliasLine -Line 'pixel:192.168.1.5:5555'
#>
function ConvertFrom-HyperShellDeviceAliasLine {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Line
    )

    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $null
    }

    $parts = $Line -split ':', 2
    if ($parts.Length -ne 2 -or [string]::IsNullOrWhiteSpace($parts[0]) -or [string]::IsNullOrWhiteSpace($parts[1])) {
        return $null
    }

    return [pscustomobject]@{
        Alias  = $parts[0]
        Serial = $parts[1]
    }
}

<#
.SYNOPSIS
    Builds the fzf preview command for a directory listing.
.DESCRIPTION
    Windows gets cmd's wide listing, everything else gets ls. Kept separate
    from the fzf commands so the platform choice is testable without fzf.
#>
function Get-HyperShellDirectoryPreviewCommand {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($script:HyperShellIsWindows) {
        return 'cmd /c dir /a /w "{}"'
    }

    return 'ls -la "{}"'
}

<#
.SYNOPSIS
    Builds the fzf preview command for a file.
.DESCRIPTION
    Uses bat when it is installed and falls back to plain output otherwise, so
    the fzf commands still work on a box without bat.
#>
function Get-HyperShellFilePreviewCommand {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (Test-HyperShellCommand -Name 'bat') {
        return 'bat --color=always --style=numbers --line-range=:500 {}'
    }

    if ($script:HyperShellIsWindows) {
        return 'cmd /c type "{}"'
    }

    return 'cat "{}"'
}

<#
.SYNOPSIS
    Returns the name of the Gradle wrapper script for this platform.
#>
function Get-HyperShellGradleWrapperName {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($script:HyperShellIsWindows) {
        return 'gradlew.bat'
    }

    return 'gradlew'
}

<#
.SYNOPSIS
    Resolves the dotfiles checkout root.
.DESCRIPTION
    Prefers the DOTFILES environment variable, falls back to ~/dev/dotfiles,
    and returns $null when neither exists. Nothing in the module hard-codes a
    checkout path; this is the one place that guesses.
#>
function Get-HyperShellDotfilesRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($env:DOTFILES -and (Test-Path -LiteralPath $env:DOTFILES)) {
        return $env:DOTFILES
    }

    $default = Join-Path -Path $HOME -ChildPath 'dev' -AdditionalChildPath 'dotfiles'
    if (Test-Path -LiteralPath $default) {
        return $default
    }

    return $null
}
