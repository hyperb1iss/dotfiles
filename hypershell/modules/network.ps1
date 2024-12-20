# Network-related functions and utilities

# Function to find process using a specific port
function Get-ProcessByPort {
    param (
        [Parameter(Mandatory = $true)]
        [int]$Port,
        [Parameter(Mandatory = $false)]
        [ValidateSet('TCP', 'UDP')]
        [string]$Protocol = 'TCP'
    )
    
    if ($Protocol -eq 'TCP') {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    }
    else {
        $connection = Get-NetUDPEndpoint -LocalPort $Port -ErrorAction SilentlyContinue
    }
    
    if ($connection) {
        $process = Get-Process -Id $connection.OwningProcess
        Write-Host "Port $Port ($Protocol) is being used by process: $($process.Name) (PID: $($process.Id))"
        return $process
    }
    else {
        Write-Host "No process found using port $Port ($Protocol)"
    }
}
Set-Alias -Name port -Value Get-ProcessByPort -Force

# Function to display active network connections
function Get-ActiveConnections {
    $connections = Get-NetTCPConnection | Where-Object State -eq 'Established'
    $connections | ForEach-Object {
        $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            LocalAddress  = $_.LocalAddress
            LocalPort     = $_.LocalPort
            RemoteAddress = $_.RemoteAddress
            RemotePort    = $_.RemotePort
            State         = $_.State
            ProcessName   = $process.Name
            PID           = $_.OwningProcess
        }
    } | Format-Table -AutoSize
}
Set-Alias -Name netcons -Value Get-ActiveConnections -Force

# Function to test network connectivity
function Test-NetworkConnectivity {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [Parameter(Mandatory = $false)]
        [int]$Count = 4
    )
    
    Write-Host "Testing connectivity to $Target..."
    Test-Connection -TargetName $Target -Count $Count
}
Set-Alias -Name ping2 -Value Test-NetworkConnectivity -Force

# Function to get DNS information
function Get-DNSInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )
    
    Write-Host ("DNS Records for {0}:" -f $Domain)
    $recordTypes = @('A', 'AAAA', 'MX', 'NS', 'SOA', 'TXT')
    foreach ($type in $recordTypes) {
        Write-Host "`n$type Records:"
        Resolve-DnsName -Name $Domain -Type $type | Format-Table
    }
}
Set-Alias -Name dns -Value Get-DNSInfo -Force

# Function to show network interfaces
function Get-NetworkInterfaces {
    Get-NetAdapter | 
    Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress |
    Format-Table -AutoSize
}
Set-Alias -Name nics -Value Get-NetworkInterfaces -Force

# Function to get public IP address
function Get-PublicIP {
    try {
        $ip = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
        Write-Host "Public IP: $($ip.ip)"
    }
    catch {
        Write-Error "Failed to retrieve public IP: $_"
    }
}
Set-Alias -Name pubip -Value Get-PublicIP -Force

# Function to flush DNS cache
function Clear-DNSCache {
    Clear-DnsClientCache
    Write-Host "DNS cache cleared successfully"
}
Set-Alias -Name flushdns -Value Clear-DNSCache -Force

# Function to test port availability
function Test-PortAvailability {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [int]$Port,
        [Parameter(Mandatory = $false)]
        [int]$TimeoutMilliseconds = 1000
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $result = $tcpClient.BeginConnect($ComputerName, $Port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne($TimeoutMilliseconds)
        
        if ($success) {
            $tcpClient.EndConnect($result)
            Write-Host ("Port {0} on {1} is open" -f $Port, $ComputerName)
            return $true
        }
        else {
            Write-Host ("Port {0} on {1} is closed or filtered" -f $Port, $ComputerName)
            return $false
        }
    }
    catch {
        Write-Host ("Error testing port {0} on {1}: {2}" -f $Port, $ComputerName, $_)
        return $false
    }
    finally {
        if ($tcpClient -ne $null) {
            $tcpClient.Close()
        }
    }
}
Set-Alias -Name testport -Value Test-PortAvailability -Force

# Function to show network statistics
function Get-NetworkStatistics {
    $stats = Get-NetTCPConnection | Group-Object State | Select-Object Name, Count
    Write-Host "TCP Connection Statistics:"
    $stats | Format-Table -AutoSize
    
    Write-Host "`nNetwork Interface Statistics:"
    Get-NetAdapter | ForEach-Object {
        try {
            $stats = $_ | Get-NetAdapterStatistics -ErrorAction Stop
            [PSCustomObject]@{
                Name          = $_.Name
                Status        = $_.Status
                ReceivedBytes = [math]::Round($stats.ReceivedBytes / 1MB, 2)
                SentBytes     = [math]::Round($stats.SentBytes / 1MB, 2)
                TotalBytes    = [math]::Round(($stats.ReceivedBytes + $stats.SentBytes) / 1MB, 2)
                Error         = $null
            }
        }
        catch {
            [PSCustomObject]@{
                Name          = $_.Name
                Status        = $_.Status
                ReceivedBytes = 0
                SentBytes     = 0
                TotalBytes    = 0
                Error         = "Statistics not available"
            }
        }
    } | Format-Table -AutoSize @{
        Label = "Interface"; Expression = { $_.Name }
    }, @{
        Label = "Status"; Expression = { $_.Status }
    }, @{
        Label = "Received (MB)"; Expression = { if ($_.Error) { "N/A" } else { $_.ReceivedBytes } }
    }, @{
        Label = "Sent (MB)"; Expression = { if ($_.Error) { "N/A" } else { $_.SentBytes } }
    }, @{
        Label = "Total (MB)"; Expression = { if ($_.Error) { "N/A" } else { $_.TotalBytes } }
    }
}
Set-Alias -Name netstats -Value Get-NetworkStatistics -Force 