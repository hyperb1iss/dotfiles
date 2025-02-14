# Git integration and enhanced functionality

# Basic Git aliases
function Get-GitStatus { git status }
Set-Alias -Name gst -Value Get-GitStatus

function Add-GitChanges { git add $args }
Set-Alias -Name ga -Value Add-GitChanges

function Invoke-GitCommit { git commit -m $args }
Set-Alias -Name gcom -Value Invoke-GitCommit

function Push-GitChanges { git push $args }
Set-Alias -Name gpsh -Value Push-GitChanges

function Invoke-GitPull { git pull $args }
Set-Alias -Name gpull -Value Invoke-GitPull

function Invoke-GitFetch { git fetch --all --prune }
Set-Alias -Name gf -Value Invoke-GitFetch

function Invoke-GitCheckout { git checkout $args }
Set-Alias -Name gco -Value Invoke-GitCheckout

function Invoke-GitCherryPick { git cherry-pick $args }
Set-Alias -Name gcp -Value Invoke-GitCherryPick

# Interactive git add with FZF
function Add-FzfGitChanges {
    $files = git status -s |
    fzf --multi --preview 'git diff --color=always {2}' |
    ForEach-Object { 
        $line = $_
        if ($line -match '^\s*[MADRCU\?]+ (.+)$') {
            $matches[1]
        }
    }

    if ($files) {
        $files | ForEach-Object { 
            Write-Host "Adding $_"
            git add $_
        }
        git status -s
    }
}
Set-Alias -Name gadd -Value Add-FzfGitChanges

# Interactive git checkout branch
function Switch-FzfGitBranch {
    $branch = git branch --all |
    Where-Object { $_ -notmatch 'HEAD' } |
    fzf --preview 'git log --color=always {}' |
    ForEach-Object { $_.TrimStart('* ').TrimStart().Replace('remotes/origin/', '') }

    if ($branch) {
        git checkout $branch
    }
}
Set-Alias -Name gbr -Value Switch-FzfGitBranch

# Interactive git log browser
function Show-FzfGitLog {
    $commit = git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
    fzf --ansi --no-sort --reverse --tiebreak=index --preview 'git show --color=always {2}' |
    ForEach-Object { ($_ -split '\s+')[1] }

    if ($commit) {
        git show --color=always $commit | less -R
    }
}
Set-Alias -Name glog -Value Show-FzfGitLog