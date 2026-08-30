# Network inspection helpers.
#
# Aliases: port netcons ping2 dns nics pubip flushdns testport netstats
#
# Most of these wrap the Windows NetTCPIP and DnsClient cmdlets, which do not
# exist on macOS or Linux. Those warn and return instead of failing with a
# missing-command error. Test-NetworkConnectivity, Test-PortAvailability, and
# Get-PublicIP work everywhere.

<#
.SYNOPSIS
    Finds the process holding a local port.
.EXAMPLE
    port 8080
#>
function Get-ProcessByPort {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive summary line, the process object is still returned.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [int]$Port,

        [Parameter(Position = 1)]
        [ValidateSet('TCP', 'UDP')]
        [string]$Protocol = 'TCP'
    )

    if (-not (Test-HyperShellWindows -Feature 'Port owner lookup')) {
        return
    }

    if ($Protocol -eq 'TCP') {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    }
    else {
        $connection = Get-NetUDPEndpoint -LocalPort $Port -ErrorAction SilentlyContinue
    }

    if (-not $connection) {
        Write-Host "No process found using port $Port ($Protocol)"
        return
    }

    $process = Get-Process -Id $connection.OwningProcess
    Write-Host "Port $Port ($Protocol) is being used by process: $($process.Name) (PID: $($process.Id))"
    return $process
}

<#
.SYNOPSIS
    Lists established TCP connections with their owning processes.
#>
function Get-ActiveConnection {
    [CmdletBinding()]
    param()

    if (-not (Test-HyperShellWindows -Feature 'Active connection listing')) {
        return
    }

    Get-NetTCPConnection |
        Where-Object { $_.State -eq 'Established' } |
        ForEach-Object {
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
        } |
        Format-Table -AutoSize
}

<#
.SYNOPSIS
    Pings a host.
.EXAMPLE
    ping2 hyperbliss.tech -Count 8
#>
function Test-NetworkConnectivity {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Progress line ahead of the real results.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Target,

        [Parameter(Position = 1)]
        [int]$Count = 4
    )

    Write-Host "Testing connectivity to $Target..."
    Test-Connection -TargetName $Target -Count $Count
}

<#
.SYNOPSIS
    Dumps the common DNS record types for a domain.
#>
function Get-DNSInfo {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Section headers between record tables.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Domain
    )

    if (-not (Test-HyperShellWindows -Feature 'DNS record lookup')) {
        return
    }

    Write-Host ('DNS Records for {0}:' -f $Domain)
    foreach ($type in @('A', 'AAAA', 'MX', 'NS', 'SOA', 'TXT')) {
        Write-Host "`n$type Records:"
        Resolve-DnsName -Name $Domain -Type $type | Format-Table
    }
}

<#
.SYNOPSIS
    Lists network adapters.
#>
function Get-NetworkInterface {
    [CmdletBinding()]
    param()

    if (-not (Test-HyperShellWindows -Feature 'Network adapter listing')) {
        return
    }

    Get-NetAdapter |
        Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress |
        Format-Table -AutoSize
}

<#
.SYNOPSIS
    Prints this machine's public IP address.
#>
function Get-PublicIP {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'One-line interactive answer.')]
    [CmdletBinding()]
    param()

    try {
        $response = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
        Write-Host "Public IP: $($response.ip)"
    }
    catch {
        Write-Error "Failed to retrieve public IP: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Flushes the DNS resolver cache.
#>
function Clear-DNSCache {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive confirmation line.')]
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not (Test-HyperShellWindows -Feature 'DNS cache flush')) {
        return
    }

    if ($PSCmdlet.ShouldProcess('DNS client cache', 'Clear')) {
        Clear-DnsClientCache
        Write-Host 'DNS cache cleared successfully'
    }
}

<#
.SYNOPSIS
    Tests whether a TCP port on a host accepts connections.
.EXAMPLE
    testport hyperbliss.tech 443
#>
function Test-PortAvailability {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive summary line, the boolean is still returned.')]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$ComputerName,

        [Parameter(Mandatory, Position = 1)]
        [int]$Port,

        [Parameter(Position = 2)]
        [int]$TimeoutMilliseconds = 1000
    )

    $tcpClient = $null
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $result = $tcpClient.BeginConnect($ComputerName, $Port, $null, $null)
        $connected = $result.AsyncWaitHandle.WaitOne($TimeoutMilliseconds)

        if ($connected) {
            $tcpClient.EndConnect($result)
            Write-Host ('Port {0} on {1} is open' -f $Port, $ComputerName)
            return $true
        }

        Write-Host ('Port {0} on {1} is closed or filtered' -f $Port, $ComputerName)
        return $false
    }
    catch {
        Write-Host ('Error testing port {0} on {1}: {2}' -f $Port, $ComputerName, $_.Exception.Message)
        return $false
    }
    finally {
        if ($null -ne $tcpClient) {
            $tcpClient.Close()
        }
    }
}

<#
.SYNOPSIS
    Summarizes TCP connection states and per-adapter traffic.
#>
function Get-NetworkStatistic {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Section headers between the two tables.')]
    [CmdletBinding()]
    param()

    if (-not (Test-HyperShellWindows -Feature 'Network statistics')) {
        return
    }

    Write-Host 'TCP Connection Statistics:'
    Get-NetTCPConnection | Group-Object State | Select-Object Name, Count | Format-Table -AutoSize

    Write-Host "`nNetwork Interface Statistics:"
    Get-NetAdapter | ForEach-Object {
        $adapter = $_
        try {
            $stats = $adapter | Get-NetAdapterStatistics -ErrorAction Stop
            [PSCustomObject]@{
                Name          = $adapter.Name
                Status        = $adapter.Status
                ReceivedBytes = [math]::Round($stats.ReceivedBytes / 1MB, 2)
                SentBytes     = [math]::Round($stats.SentBytes / 1MB, 2)
                TotalBytes    = [math]::Round(($stats.ReceivedBytes + $stats.SentBytes) / 1MB, 2)
                Error         = $null
            }
        }
        catch {
            [PSCustomObject]@{
                Name          = $adapter.Name
                Status        = $adapter.Status
                ReceivedBytes = 0
                SentBytes     = 0
                TotalBytes    = 0
                Error         = 'Statistics not available'
            }
        }
    } | Format-Table -AutoSize @{
        Label = 'Interface'; Expression = { $_.Name }
    }, @{
        Label = 'Status'; Expression = { $_.Status }
    }, @{
        Label = 'Received (MB)'; Expression = { if ($_.Error) { 'N/A' } else { $_.ReceivedBytes } }
    }, @{
        Label = 'Sent (MB)'; Expression = { if ($_.Error) { 'N/A' } else { $_.SentBytes } }
    }, @{
        Label = 'Total (MB)'; Expression = { if ($_.Error) { 'N/A' } else { $_.TotalBytes } }
    }
}

Add-HyperShellAlias -Name 'port' -Value 'Get-ProcessByPort'
Add-HyperShellAlias -Name 'netcons' -Value 'Get-ActiveConnection'
Add-HyperShellAlias -Name 'ping2' -Value 'Test-NetworkConnectivity'
Add-HyperShellAlias -Name 'dns' -Value 'Get-DNSInfo'
Add-HyperShellAlias -Name 'nics' -Value 'Get-NetworkInterface'
Add-HyperShellAlias -Name 'pubip' -Value 'Get-PublicIP'
Add-HyperShellAlias -Name 'flushdns' -Value 'Clear-DNSCache'
Add-HyperShellAlias -Name 'testport' -Value 'Test-PortAvailability'
Add-HyperShellAlias -Name 'netstats' -Value 'Get-NetworkStatistic'
