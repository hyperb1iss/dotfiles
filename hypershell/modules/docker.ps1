# Docker integration and related functions for HyperShell
# Ensure you have Docker and FZF installed

# List all Docker containers in a table format (all states)
function Get-DockerContainers {
  docker ps --all --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}"
}
Set-Alias -Name dps -Value Get-DockerContainers -Force

# List Docker images in a table format
function Get-DockerImages {
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
}
Set-Alias -Name di -Value Get-DockerImages -Force

# Interactive function: Show logs for a selected container
function Show-DockerLogs {
  # List containers with id and name, then use FZF for selection
  $container = docker ps --format "{{.ID}}: {{.Names}}" | fzf --no-preview --prompt "Select container for logs: "
  if ($container) {
    $containerId = $container -split ':' | Select-Object -First 1
    docker logs --tail 100 -f $containerId
  }
  else {
    Write-Host "No container selected" -ForegroundColor Yellow
  }
}
Set-Alias -Name dlog -Value Show-DockerLogs -Force

# Interactive function: Stop a selected container
function Stop-DockerContainer {
  $container = docker ps --format "{{.ID}}: {{.Names}}" | fzf --no-preview --prompt "Select container to stop: "
  if ($container) {
    $containerId = $container -split ':' | Select-Object -First 1
    docker stop $containerId
    Write-Host "Stopped container $containerId" -ForegroundColor Green
  }
  else {
    Write-Host "No container selected" -ForegroundColor Yellow
  }
}
Set-Alias -Name dstop -Value Stop-DockerContainer -Force 