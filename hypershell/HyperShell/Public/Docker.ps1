# Docker shortcuts and fzf-driven container pickers.
#
# Aliases: dps di dlog dstop

<#
.SYNOPSIS
    Lists every container, running or not, as a table.
#>
function Get-DockerContainer {
    [CmdletBinding()]
    param()

    docker ps --all --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}'
}

<#
.SYNOPSIS
    Lists local images as a table.
#>
function Get-DockerImage {
    [CmdletBinding()]
    param()

    docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}'
}

<#
.SYNOPSIS
    Picks a running container with fzf and follows its logs.
#>
function Show-DockerLog {
    [CmdletBinding()]
    param()

    $containerId = Select-DockerContainerId -Prompt 'Select container for logs: '
    if (-not $containerId) {
        return
    }

    docker logs --tail 100 -f $containerId
}

<#
.SYNOPSIS
    Picks a running container with fzf and stops it.
#>
function Stop-DockerContainer {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive confirmation output, not pipeline data.')]
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $containerId = Select-DockerContainerId -Prompt 'Select container to stop: '
    if (-not $containerId) {
        return
    }

    if ($PSCmdlet.ShouldProcess($containerId, 'docker stop')) {
        docker stop $containerId
        Write-Host "Stopped container $containerId" -ForegroundColor Green
    }
}

<#
.SYNOPSIS
    Picks a running container with fzf and returns its id.
.DESCRIPTION
    Shared by the interactive docker commands. Returns $null when nothing was
    picked, and says so, since an empty selection otherwise looks like a hang.
#>
function Select-DockerContainerId {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive status output, not pipeline data.')]
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [string]$Prompt = 'Select container: '
    )

    $container = docker ps --format '{{.ID}}: {{.Names}}' | fzf --no-preview --prompt $Prompt

    if (-not $container) {
        Write-Host 'No container selected' -ForegroundColor Yellow
        return $null
    }

    return ($container -split ':', 2)[0].Trim()
}

Add-HyperShellAlias -Name 'dps' -Value 'Get-DockerContainer'
Add-HyperShellAlias -Name 'di' -Value 'Get-DockerImage'
Add-HyperShellAlias -Name 'dlog' -Value 'Show-DockerLog'
Add-HyperShellAlias -Name 'dstop' -Value 'Stop-DockerContainer'
