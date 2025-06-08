# Kubernetes utility functions for PowerShell - Streamlined

# Essential aliases
Set-Alias -Name k -Value kubectl
Set-Alias -Name kx -Value kubectx
Set-Alias -Name kns -Value kubens

# Core functions with aliases
function Get-KubePods { kubectl get pods @args }
function Apply-KubeFile { kubectl apply -f @args }
function Invoke-KubeExec { kubectl exec -ti @args }

Set-Alias -Name kgp -Value Get-KubePods
Set-Alias -Name kaf -Value Apply-KubeFile
Set-Alias -Name keti -Value Invoke-KubeExec

# Switch Kubernetes config
function Switch-KubeConfig {
    param(
        [Parameter(Position=0)]
        [string]$ConfigName
    )
    
    $configDir = "$env:USERPROFILE\.kube\configs"
    
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    if ([string]::IsNullOrEmpty($ConfigName)) {
        Write-Host "Current KUBECONFIG: $env:KUBECONFIG"
        Write-Host "Available configs in ${configDir}:"
        if (Test-Path $configDir) {
            Get-ChildItem -Path $configDir -File | Select-Object -ExpandProperty Name
        } else {
            Write-Host "No configs found"
        }
        return
    }
    
    $configFile = Join-Path $configDir $ConfigName
    
    if (Test-Path $configFile) {
        $env:KUBECONFIG = $configFile
        Write-Host "Switched to $ConfigName kubernetes config"
    } else {
        Write-Host "Config $ConfigName not found in $configDir"
        return $false
    }
}

Set-Alias -Name kconfig -Value Switch-KubeConfig

# Get pod logs
function Get-KubeLogs {
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Pod,
        
        [Parameter(Position=1)]
        [string]$Container,
        
        [Parameter(Position=2)]
        [string]$Namespace = "default"
    )
    
    if ([string]::IsNullOrEmpty($Container)) {
        kubectl logs -n $Namespace $Pod --tail=100 -f
    } else {
        kubectl logs -n $Namespace $Pod -c $Container --tail=100 -f
    }
}

Set-Alias -Name klogs -Value Get-KubeLogs

# Kubernetes help function
function Show-KubernetesHelp {
    Write-Host "🛳️ Kubernetes Quick Reference" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "📊 Interactive UI:" -ForegroundColor Cyan
    Write-Host "  k9s                      # Full-featured Kubernetes TUI (recommended)"
    Write-Host ""
    Write-Host "🔑 Core Commands:" -ForegroundColor Cyan
    Write-Host "  k                        # Short for kubectl"
    Write-Host "  kx                       # Switch context (kubectx)"
    Write-Host "  kns                      # Switch namespace (kubens)"
    Write-Host "  kgp                      # Get pods"
    Write-Host "  kaf deployment.yaml      # Apply file"
    Write-Host "  klogs pod-name           # Stream logs"
    Write-Host "  keti pod-name -- sh      # Interactive shell"
    Write-Host "  kconfig                  # Switch kubeconfig file"
    Write-Host ""
    Write-Host "📚 Useful kubectl commands:" -ForegroundColor Cyan
    Write-Host "  k get all                # List all resources"
    Write-Host "  k get pods -o wide       # Detailed pod view"
    Write-Host "  k describe pod <name>    # Resource details"
    Write-Host "  k port-forward pod 8080:80    # Port forwarding"
    Write-Host "  k apply -k ./kustomize/  # Apply kustomize dir"
    Write-Host ""
    Write-Host "⚡ Pro tip: Use k9s for almost everything - it's much faster than aliases!" -ForegroundColor Yellow
}

Set-Alias -Name khelp -Value Show-KubernetesHelp

# Set up kubectl autocompletion
# Note: This requires PSReadLine module
if (Get-Module -ListAvailable -Name PSReadLine) {
    # Register the kubectl argument completer if kubectl exists
    if (Get-Command kubectl -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName kubectl -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            $commandElements = $commandAst.CommandElements
            $command = @()
            for ($i = 1; $i -lt $commandElements.Count; $i++) {
                $command += $commandElements[$i].Extent.Text
            }
            $completions = kubectl completion powershell $command | Out-String
            
            if ($completions -match "compgen") {
                return @()
            }
            
            $completions = $completions.Split("`n", [StringSplitOptions]::RemoveEmptyEntries)
            
            $results = @()
            foreach ($comp in $completions) {
                $comp = $comp.TrimStart()
                if ($comp.StartsWith($wordToComplete)) {
                    $results += $comp
                }
            }
            
            return $results
        }
    }
}
