# Android device aliases for adb.
#
# Aliases: adbdev
#
# The alias file is ~/.adbdevs, the same file sh/adb.sh uses, so a machine
# running both shells shares one device list.

<#
.SYNOPSIS
    Manages named adb device aliases and sets ANDROID_SERIAL.
.DESCRIPTION
    Entries live in ~/.adbdevs as "alias:serial". A serial can be a network
    target such as 192.168.1.5:5555, so only the first colon separates the
    two fields.
.EXAMPLE
    adbdev --add pixel 192.168.1.5:5555
.EXAMPLE
    adbdev pixel
#>
function Set-AndroidDevice {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'Interactive listing and confirmation output.')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Arguments = @()
    )

    $configFile = Join-Path $HOME '.adbdevs'

    if (-not (Test-Path -LiteralPath $configFile)) {
        try {
            New-Item -ItemType File -Path $configFile -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Cannot create or access $configFile"
            return
        }
    }

    $entries = @(
        Get-Content -LiteralPath $configFile -ErrorAction SilentlyContinue |
            ForEach-Object { ConvertFrom-HyperShellDeviceAliasLine -Line $_ } |
            Where-Object { $_ }
    )

    switch ($Arguments[0]) {
        '--add' {
            if ($Arguments.Count -lt 3) {
                Write-Host 'Usage: adbdev --add <alias> <serial>'
                return
            }

            $name = $Arguments[1]
            $serial = $Arguments[2]

            if (-not $PSCmdlet.ShouldProcess($name, 'Add device alias')) {
                return
            }

            $kept = $entries | Where-Object { $_.Alias -ne $name }
            $lines = @($kept | ForEach-Object { "$($_.Alias):$($_.Serial)" }) + "${name}:${serial}"
            Set-Content -LiteralPath $configFile -Value $lines
            Write-Host "Added device alias '$name' for serial '$serial'"
        }

        '--remove' {
            if ($Arguments.Count -lt 2) {
                Write-Host 'Usage: adbdev --remove <alias>'
                return
            }

            $name = $Arguments[1]

            if (-not $PSCmdlet.ShouldProcess($name, 'Remove device alias')) {
                return
            }

            $lines = @($entries | Where-Object { $_.Alias -ne $name } | ForEach-Object { "$($_.Alias):$($_.Serial)" })
            Set-Content -LiteralPath $configFile -Value $lines
            Write-Host "Removed device alias '$name'"
        }

        '--list' {
            if ($entries.Count -eq 0) {
                Write-Host 'No device aliases configured'
                return
            }

            Write-Host 'Configured device aliases:'
            foreach ($entry in $entries) {
                Write-Host ("`t{0,-20} {1}" -f $entry.Alias, $entry.Serial)
            }
        }

        { $null -eq $_ } {
            Write-Host @'
Usage:
    adbdev <alias>                    - Set ANDROID_SERIAL to the device with given alias
    adbdev --add <alias> <serial>     - Add or update device alias
    adbdev --remove <alias>           - Remove device alias
    adbdev --list                     - List all device aliases
'@
        }

        default {
            $name = $Arguments[0]
            $match = $entries | Where-Object { $_.Alias -eq $name } | Select-Object -First 1

            if (-not $match) {
                Write-Error "No device found with alias '$name'"
                return
            }

            if ($PSCmdlet.ShouldProcess($name, 'Set ANDROID_SERIAL')) {
                $env:ANDROID_SERIAL = $match.Serial
                Write-Host "Set ANDROID_SERIAL=$($match.Serial)"
            }
        }
    }
}

Add-HyperShellAlias -Name 'adbdev' -Value 'Set-AndroidDevice'
