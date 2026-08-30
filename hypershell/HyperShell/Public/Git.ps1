# Git shortcuts and fzf-driven git browsers.
#
# Aliases: gst ga gcom gpsh gpull gf gco gcp gadd gbr glog
#
# Names match the Unix side in sh/git.sh so muscle memory carries across.

<#
.SYNOPSIS
    Shows the working tree status.
#>
function Get-GitStatus {
    [CmdletBinding()]
    param()

    git status
}

<#
.SYNOPSIS
    Stages paths.
#>
function Add-GitChange {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    git add @Arguments
}

<#
.SYNOPSIS
    Commits with a message.
#>
function Invoke-GitCommit {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    git commit -m @Arguments
}

<#
.SYNOPSIS
    Pushes the current branch.
#>
function Push-GitChange {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    git push @Arguments
}

<#
.SYNOPSIS
    Pulls the current branch.
#>
function Invoke-GitPull {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    git pull @Arguments
}

<#
.SYNOPSIS
    Fetches every remote and prunes deleted branches.
#>
function Invoke-GitFetch {
    [CmdletBinding()]
    param()

    git fetch --all --prune
}

<#
.SYNOPSIS
    Checks out a branch, tag, or path.
#>
function Invoke-GitCheckout {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    git checkout @Arguments
}

<#
.SYNOPSIS
    Cherry-picks commits.
#>
function Invoke-GitCherryPick {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    git cherry-pick @Arguments
}

<#
.SYNOPSIS
    Picks files to stage with fzf.
.DESCRIPTION
    Multi-select over `git status --short`, with the diff in the preview pane.
#>
function Add-FzfGitChange {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive progress output, not pipeline data.')]
    [CmdletBinding()]
    param()

    $files = git status -s |
        fzf --multi --preview 'git diff --color=always {2}' |
        ForEach-Object { ConvertFrom-HyperShellGitStatusLine -Line $_ } |
        Where-Object { $_ }

    if (-not $files) {
        return
    }

    foreach ($file in $files) {
        Write-Host "Adding $file"
        git add $file
    }

    git status -s
}

<#
.SYNOPSIS
    Picks a branch to check out with fzf.
#>
function Switch-FzfGitBranch {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $branch = git branch --all |
        Where-Object { $_ -notmatch 'HEAD' } |
        fzf --preview 'git log --color=always {}' |
        ForEach-Object { ConvertFrom-HyperShellGitBranchLine -Line $_ } |
        Select-Object -First 1

    if (-not $branch) {
        return
    }

    if ($PSCmdlet.ShouldProcess($branch, 'git checkout')) {
        git checkout $branch
    }
}

<#
.SYNOPSIS
    Browses the git log with fzf.
#>
function Show-FzfGitLog {
    [CmdletBinding()]
    param()

    $commit = git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' |
        fzf --ansi --no-sort --reverse --tiebreak=index --preview 'git show --color=always {2}' |
        ForEach-Object { ($_ -split '\s+') | Where-Object { $_ -match '^[0-9a-f]{4,40}$' } | Select-Object -First 1 } |
        Select-Object -First 1

    if (-not $commit) {
        return
    }

    # On Windows HyperShell aliases `less` to bat, which rejects -R. Resolving
    # the application is only half the job: invoking the bare name afterwards
    # goes straight back through the alias, so the resolved command object is
    # what gets called.
    $lessApp = Get-Command -Name 'less' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($lessApp) {
        git show --color=always $commit | & $lessApp -R
    }
    else {
        git show --color=always $commit
    }
}

Add-HyperShellAlias -Name 'gst' -Value 'Get-GitStatus'
Add-HyperShellAlias -Name 'ga' -Value 'Add-GitChange'
Add-HyperShellAlias -Name 'gcom' -Value 'Invoke-GitCommit'
Add-HyperShellAlias -Name 'gpsh' -Value 'Push-GitChange'
Add-HyperShellAlias -Name 'gpull' -Value 'Invoke-GitPull'
Add-HyperShellAlias -Name 'gf' -Value 'Invoke-GitFetch'
Add-HyperShellAlias -Name 'gco' -Value 'Invoke-GitCheckout'
Add-HyperShellAlias -Name 'gcp' -Value 'Invoke-GitCherryPick'
Add-HyperShellAlias -Name 'gadd' -Value 'Add-FzfGitChange'
Add-HyperShellAlias -Name 'gbr' -Value 'Switch-FzfGitBranch'
Add-HyperShellAlias -Name 'glog' -Value 'Show-FzfGitLog'
