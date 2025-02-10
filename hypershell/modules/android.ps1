# Android development utilities for PowerShell

# Android device management with named aliases
function Set-AndroidDevice {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $configFile = Join-Path $env:USERPROFILE '.adbdevs'
    
    # Create config file if it doesn't exist
    if (-not (Test-Path $configFile)) {
        try {
            New-Item -ItemType File -Path $configFile -Force | Out-Null
        }
        catch {
            Write-Error "Cannot create/access $configFile"
            return
        }
    }

    # Handle different operations based on arguments
    switch ($Arguments[0]) {
        '--add' { 
            if ($Arguments.Count -lt 3) {
                Write-Host "Usage: adbdev --add <alias> <serial>"
                return
            }
            $alias = $Arguments[1]
            $serial = $Arguments[2]
            
            # Remove existing entry if any and filter out empty lines
            $content = @(Get-Content $configFile | Where-Object { $_ -and -not $_.StartsWith("$alias`:") })
            # Add new entry
            $content += "$alias`:$serial"
            $content | Set-Content $configFile
            Write-Host "Added device alias '$alias' for serial '$serial'"
        }
        '--remove' { 
            if ($Arguments.Count -lt 2) {
                Write-Host "Usage: adbdev --remove <alias>"
                return
            }
            $alias = $Arguments[1]
            
            # Remove entry and filter out empty lines
            $content = @(Get-Content $configFile | Where-Object { $_ -and -not $_.StartsWith("$alias`:") })
            $content | Set-Content $configFile
            Write-Host "Removed device alias '$alias'"
        }
        '--list' { 
            if (-not (Test-Path $configFile)) {
                Write-Host "No device aliases configured"
                return
            }
            
            $content = @(Get-Content $configFile | Where-Object { $_ })
            if ($content.Count -eq 0) {
                Write-Host "No device aliases configured"
                return
            }
            
            Write-Host "Configured device aliases:"
            $content | ForEach-Object {
                # Split only on the first colon to handle IP:PORT addresses
                $parts = $_ -split ':', 2
                if ($parts.Length -eq 2) {
                    Write-Host ("`t{0,-20} {1}" -f $parts[0], $parts[1])
                }
            }
        }
        { $null -eq $_ } {
            Write-Host @"
Usage:
    adbdev <alias>                    - Set ANDROID_SERIAL to the device with given alias
    adbdev --add <alias> <serial>     - Add or update device alias
    adbdev --remove <alias>           - Remove device alias
    adbdev --list                     - List all device aliases
"@
        }
        default {
            $alias = $Arguments[0]
            $content = @(Get-Content $configFile | Where-Object { $_ })
            $deviceLine = $content | Where-Object { $_.StartsWith("$alias`:") }
            if (-not $deviceLine) {
                Write-Error "No device found with alias '$alias'"
                return
            }
            
            # Split only on the first colon to handle IP:PORT addresses
            $serial = ($deviceLine -split ':', 2)[1]
            $env:ANDROID_SERIAL = $serial
            Write-Host "Set ANDROID_SERIAL=$serial"
        }
    }
}

# Create aliases
Set-Alias -Name adbdev -Value Set-AndroidDevice -Force 