# Kubernetes shortcuts.
#
# Aliases: k kx kns kgp kaf keti kconfig klogs khelp
#
# Alias names match sh/kubernetes.sh on the Unix side.

<#
.SYNOPSIS
    Lists pods.
#>
function Get-KubePod {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    kubectl get pods @Arguments
}

<#
.SYNOPSIS
    Applies a manifest file.
#>
function Invoke-KubeApply {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    kubectl apply -f @Arguments
}

<#
.SYNOPSIS
    Opens an interactive exec session in a pod.
#>
function Invoke-KubeExec {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    kubectl exec -ti @Arguments
}

<#
.SYNOPSIS
    Switches KUBECONFIG to a named file under ~/.kube/configs.
.DESCRIPTION
    Called with no arguments it lists what is available and which one is
    active.
.EXAMPLE
    kconfig staging
#>
function Switch-KubeConfig {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive listing, not pipeline data.')]
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0)]
        [string]$ConfigName
    )

    $configDir = Join-Path -Path $HOME -ChildPath '.kube' -AdditionalChildPath 'configs'

    # Created on demand so a fresh box has somewhere to drop config files.
    if (-not (Test-Path -LiteralPath $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force -ErrorAction SilentlyContinue | Out-Null
    }

    if ([string]::IsNullOrEmpty($ConfigName)) {
        Write-Host "Current KUBECONFIG: $env:KUBECONFIG"
        Write-Host "Available configs in ${configDir}:"

        if (Test-Path -LiteralPath $configDir) {
            $configs = @(Get-ChildItem -LiteralPath $configDir -File)
            if ($configs.Count -gt 0) {
                $configs | Select-Object -ExpandProperty Name
                return
            }
        }

        Write-Host 'No configs found'
        return
    }

    $configFile = Join-Path $configDir $ConfigName

    if (-not (Test-Path -LiteralPath $configFile)) {
        Write-Warning "Config $ConfigName not found in $configDir"
        return $false
    }

    if ($PSCmdlet.ShouldProcess($ConfigName, 'Set KUBECONFIG')) {
        $env:KUBECONFIG = $configFile
        Write-Host "Switched to $ConfigName kubernetes config"
    }
}

<#
.SYNOPSIS
    Follows the logs of a pod.
.EXAMPLE
    klogs my-pod my-container my-namespace
#>
function Get-KubeLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Pod,

        [Parameter(Position = 1)]
        [string]$Container,

        [Parameter(Position = 2)]
        [string]$Namespace = 'default'
    )

    if ([string]::IsNullOrEmpty($Container)) {
        kubectl logs -n $Namespace $Pod --tail=100 -f
    }
    else {
        kubectl logs -n $Namespace $Pod -c $Container --tail=100 -f
    }
}

<#
.SYNOPSIS
    Prints the Kubernetes quick reference.
#>
function Show-KubernetesHelp {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Coloured reference card, not pipeline data.')]
    [CmdletBinding()]
    param()

    Write-Host '🛳️ Kubernetes Quick Reference' -ForegroundColor Magenta
    Write-Host ''
    Write-Host '📊 Interactive UI:' -ForegroundColor Cyan
    Write-Host '  k9s                      # Full-featured Kubernetes TUI (recommended)'
    Write-Host ''
    Write-Host '🔑 Core Commands:' -ForegroundColor Cyan
    Write-Host '  k                        # Short for kubectl'
    Write-Host '  kx                       # Switch context (kubectx)'
    Write-Host '  kns                      # Switch namespace (kubens)'
    Write-Host '  kgp                      # Get pods'
    Write-Host '  kaf deployment.yaml      # Apply file'
    Write-Host '  klogs pod-name           # Stream logs'
    Write-Host '  keti pod-name -- sh      # Interactive shell'
    Write-Host '  kconfig                  # Switch kubeconfig file'
    Write-Host ''
    Write-Host '📚 Useful kubectl commands:' -ForegroundColor Cyan
    Write-Host '  k get all                # List all resources'
    Write-Host '  k get pods -o wide       # Detailed pod view'
    Write-Host '  k describe pod <name>    # Resource details'
    Write-Host '  k port-forward pod 8080:80    # Port forwarding'
    Write-Host '  k apply -k ./kustomize/  # Apply kustomize dir'
    Write-Host ''
    Write-Host "⚡ Pro tip: k9s beats the aliases for anything exploratory." -ForegroundColor Yellow
}

Add-HyperShellAlias -Name 'k' -Value 'kubectl'
Add-HyperShellAlias -Name 'kx' -Value 'kubectx'
Add-HyperShellAlias -Name 'kns' -Value 'kubens'
Add-HyperShellAlias -Name 'kgp' -Value 'Get-KubePod'
Add-HyperShellAlias -Name 'kaf' -Value 'Invoke-KubeApply'
Add-HyperShellAlias -Name 'keti' -Value 'Invoke-KubeExec'
Add-HyperShellAlias -Name 'kconfig' -Value 'Switch-KubeConfig'
Add-HyperShellAlias -Name 'klogs' -Value 'Get-KubeLog'
Add-HyperShellAlias -Name 'khelp' -Value 'Show-KubernetesHelp'

# kubectl ships its own completer; wire it up when kubectl is installed.
if (Test-HyperShellCommand -Name 'kubectl') {
    Register-ArgumentCompleter -Native -CommandName kubectl -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        $null = $cursorPosition
        $command = @()
        for ($i = 1; $i -lt $commandAst.CommandElements.Count; $i++) {
            $command += $commandAst.CommandElements[$i].Extent.Text
        }

        $completions = kubectl completion powershell $command | Out-String
        if ($completions -match 'compgen') {
            return @()
        }

        $completions.Split("`n", [StringSplitOptions]::RemoveEmptyEntries) |
            ForEach-Object { $_.TrimStart() } |
            Where-Object { $_.StartsWith($wordToComplete) }
    }
}
