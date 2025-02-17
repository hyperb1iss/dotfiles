# z.ps1 - Hypershell Directory Tracker and Jumper
#
# Copyright (c) 2025 Stefanie Jane
# Original z.sh Copyright (c) 2009 rupa deadwyler
# Licensed under the WTFPL license, Version 2
#
# Description:
#   This PowerShell script is a port of z.sh, providing functionality to track frequently used directories
#   and enabling quick jumps to these directories. It monitors your directory usage and assigns scores based
#   on both the frequency and recency of access, allowing efficient navigation.
#
# Features:
#   - Automatic directory tracking via a custom prompt function.
#   - Rankings update each time you change directories.
#   - Jump quickly to a directory using the "z" function.
#   - List, add, and remove directory entries.
#   - Supports multiple operating modes:
#       • "frecent" (default): a combination of frequency and recency.
#       • "rank": prioritizes the usage frequency.
#       • "recent": prioritizes the last access time.
#   - Registers a PowerShell argument completer for in-line tab completion.
#
# Usage:
#   The prompt function will automatically record your current directory.
#
#   Use the "z" command as follows:
#
#       z [options] <directory query>
#
#   Options:
#       -l, --list      : List all matching directories with their scores.
#       -r, --rank      : Use ranking mode only.
#       -t, --recent    : Use recent mode only.
#       -c, --current   : Restrict matches to subdirectories of the current directory.
#       -e, --echo      : Echo the best match, without changing directories.
#       -x, --remove    : Remove the current directory from tracking.
#       --add           : Manually add a directory to the tracking database.
#
# Environment Variables:
#   Z_DATA                : File path for tracking data (default "$HOME\.z").
#   Z_NO_RESOLVE_SYMLINKS : If set, disables symlink resolution.
#   Z_EXCLUDE_DIRS        : Semicolon-separated list of directories to exclude from tracking.
#   Z_MAX_SCORE           : Maximum accumulated score before aging is applied (default 9000).
#
# Installation:
#   Import or source this module in your PowerShell profile (e.g., Microsoft.PowerShell_profile.ps1)
#   to enable directory tracking and jumping.
#

# Store the original prompt function if it exists
$originalPrompt = $function:prompt

# The custom prompt function augments the usual PowerShell prompt by tracking the current directory.
function prompt {
    # This custom prompt function wraps the original prompt (if defined) and injects
    # directory tracking functionality. It resolves the current directory (with or without symlink resolution)
    # and calls Add-ZDirectory to update the directory history.
    
    # Call the original prompt function if it exists; otherwise, display a basic prompt.
    $promptResult = if ($originalPrompt) {
        & $originalPrompt
    }
    else {
        "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
    }

    # Get the current working directory.
    $currentLocation = Get-Location
    # Resolve symlinks unless disabled by Z_NO_RESOLVE_SYMLINKS.
    if ($env:Z_NO_RESOLVE_SYMLINKS) {
        $dirToAdd = $currentLocation.Path
    }
    else {
        try {
            $resolved = Resolve-Path -Path $currentLocation.Path -ErrorAction SilentlyContinue
            if ($resolved) {
                $dirToAdd = $resolved.Path
            }
            else {
                $dirToAdd = $currentLocation.Path
            }
        }
        catch {
            $dirToAdd = $currentLocation.Path
        }
    }

    # Attempt to track the current directory (ignoring errors).
    try {
        Add-ZDirectory $dirToAdd | Out-Null
    }
    catch {
        Write-Debug "Failed to track directory: $_"
    }

    # Return the computed prompt string.
    $promptResult
}

function Add-ZDirectory {
    param([string]$Directory)
  
    # Determine the tracking data file location.
    # Use the environment variable Z_DATA if set, otherwise default to "$HOME\.z".
    $dataFile = $env:Z_DATA
    if (-not $dataFile) { $dataFile = Join-Path $HOME ".z" }
  
    # Do not track if the directory is the home directory or the system root.
    if ($Directory -eq $HOME -or $Directory -eq ([IO.Path]::GetPathRoot($Directory))) {
        return
    }
  
    # Exclude the directory if it matches any in Z_EXCLUDE_DIRS (semicolon-separated list).
    if ($env:Z_EXCLUDE_DIRS) {
        $excludes = $env:Z_EXCLUDE_DIRS -split ';'
        foreach ($exclude in $excludes) {
            if ($Directory -like "$exclude*") { return }
        }
    }
  
    # Create the data file if it does not yet exist.
    if (-not (Test-Path $dataFile)) {
        New-Item -Path $dataFile -ItemType File -Force | Out-Null
    }
  
    # Read the existing tracking data from the file (each entry is a line).
    # Each entry is expected to be in the format "Directory|Rank|Timestamp".
    $lines = @()
    if (Test-Path $dataFile) {
        $lines = @(Get-Content $dataFile -ErrorAction SilentlyContinue)
    }

    # Get the current timestamp (seconds since epoch).
    $timestamp = [int64](Get-Date -UFormat %s)
    $found = $false
    
    # Loop through the data to update this directory's ranking if it already exists.
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ([string]::IsNullOrWhiteSpace($lines[$i])) { continue }
        
        try {
            $parts = $lines[$i] -split '\|'
            # Expect each line to contain three parts: Directory, Rank, and Timestamp.
            if ($parts.Count -ne 3) { continue }
            
            if ($parts[0] -eq $Directory) {
                # Increase rank by 1 and update the timestamp.
                $newScore = [double]($parts[1]) + 1
                $lines[$i] = "{0}|{1}|{2}" -f $Directory, $newScore, $timestamp
                $found = $true
                break
            }
        }
        catch {
            Write-Debug "Failed to process line $i : $_"
            continue
        }
    }
    
    # If no existing entry, add the directory with an initial rank of 1.
    if (-not $found) {
        $lines += "{0}|1|{1}" -f $Directory, $timestamp
    }
    
    # Remove any empty lines.
    $lines = @($lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    # Apply aging to adjust rankings if the total score is above the threshold.
    $maxScore = if ($env:Z_MAX_SCORE) { [double]$env:Z_MAX_SCORE } else { 9000 }
    $lines = Update-Aging -Lines $lines -MaxScore $maxScore

    # Use file locking for an atomic update to prevent race conditions.
    $lockFile = Lock-File -FilePath $dataFile
    try {
        $tempFile = "$dataFile.$(Get-Random)"
        # Write the updated data to a temporary file.
        Set-Content -Path $tempFile -Value $lines -Force
        try {
            # Replace the original file with the new one.
            Move-Item -Path $tempFile -Destination $dataFile -Force -ErrorAction Stop
        }
        catch {
            Remove-Item $tempFile -Force
        }
    }
    finally {
        # Always release the file lock.
        Unlock-File -LockFile $lockFile
    }
}

function Get-ZJump {
    param(
        [string[]]$Query,
        [string]$Mode = "frecent",
        [switch]$RestrictCurrent
    )

    # Determine the data file location (defaulting to "$HOME\.z" if Z_DATA is not set).
    $dataFile = $env:Z_DATA
    if (-not $dataFile) { $dataFile = Join-Path $HOME ".z" }
    if (-not (Test-Path $dataFile)) { return $null }

    $now = [int64](Get-Date -UFormat %s)
    if ($RestrictCurrent) {
        $currentDir = (Get-Location).Path
    }
    
    if ($Query.Count -gt 0) {
        $q = ($Query -join " ")
        $pattern = $q -replace ' ', '.*'
        # Candidate buckets:
        $bestMatchSensitive = $null
        $bestScoreSensitive = - [double]::MaxValue
        $bestMatchInsensitive = $null
        $bestScoreInsensitive = - [double]::MaxValue
        # New bucket for entries whose basename starts with the query
        $bestMatchBase = $null
        $bestScoreBase = - [double]::MaxValue
    }
    else {
        $bestMatch = $null
        $bestScore = - [double]::MaxValue
    }

    # Read the tracking file and iterate over each valid entry.
    $lines = @(Get-Content $dataFile -ErrorAction SilentlyContinue | Where-Object { $_ -match '\|' })
    foreach ($line in $lines) {
        try {
            $parts = $line -split '\|'
            if ($parts.Count -ne 3) { continue }
            
            $path = $parts[0]
            $rank = [double]$parts[1]
            $timestamp = [int64]$parts[2]
            
            # Skip the directory if it no longer exists.
            if (-not (Test-Path $path)) { continue }
            
            # If required, restrict the search to subdirectories of the current directory.
            if ($RestrictCurrent -and ($path -notlike ("{0}*" -f $currentDir))) {
                continue
            }
            
            # Calculate the age of the entry.
            $age = $now - $timestamp
            # Determine the score based on the chosen mode:
            #  - "rank": uses the directory's usage frequency (rank).
            #  - "recent": uses (timestamp - now) so that more recently visited directories yield a higher (less negative) value.
            #  - "frecent" (default): balances frequency and recency as rank divided by (age + 1).
            if ($Mode -eq "rank") {
                $score = $rank
            }
            elseif ($Mode -eq "recent") {
                $score = $timestamp - $now
            }
            else {
                $score = $rank / ($age + 1)
            }
            
            if ($Query.Count -gt 0) {
                $basename = [System.IO.Path]::GetFileName($path)
                # Phase 1: If the basename starts with the query, record it in the "base" candidate bucket.
                if ($basename.StartsWith($q, [System.StringComparison]::CurrentCultureIgnoreCase)) {
                    if ($score -gt $bestScoreBase) {
                        $bestScoreBase = $score
                        $bestMatchBase = $path
                    }
                }

                # Phase 2: For all entries (whether or not their basename starts with the query),
                # calculate an effective score that gives a bonus if the basename starts with the query.
                if ($basename.StartsWith($q, [System.StringComparison]::CurrentCultureIgnoreCase)) {
                    # boost the score by 50% if the basename starts with the query
                    $effectiveScore = $score * 1.5
                }
                else {
                    $effectiveScore = $score
                }

                # Debug output
                if ($env:Z_DEBUG) {
                    Write-Debug "Path: $path"
                    Write-Debug "Query: '$q' | Basename: $basename | Raw Score: $score | Effective Score: $effectiveScore"
                }

                if ([regex]::IsMatch($path, $pattern)) {
                    if ($effectiveScore -gt $bestScoreSensitive) {
                        $bestScoreSensitive = $effectiveScore
                        $bestMatchSensitive = $path
                    }
                }
                elseif ([regex]::IsMatch($path, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
                    if ($effectiveScore -gt $bestScoreInsensitive) {
                        $bestScoreInsensitive = $effectiveScore
                        $bestMatchInsensitive = $path
                    }
                }
            }
            else {
                if ($score -gt $bestScore) {
                    $bestScore = $score
                    $bestMatch = $path
                }
            }
        }
        catch {
            Write-Debug "Failed to process line: $_"
            continue
        }
    }
    if ($Query.Count -gt 0) {
        # If we found any candidate whose basename starts with the query, prefer it.
        if ($bestMatchBase) {
            if ($env:Z_DEBUG) {
                Write-Debug "Selecting base candidate: $bestMatchBase (Score: $bestScoreBase)"
            }
            return $bestMatchBase
        }

        if ($bestMatchSensitive) {
            if ($env:Z_DEBUG) {
                Write-Debug "Current best sensitive match: $bestMatchSensitive (Score: $bestScoreSensitive)"
            }
            return $bestMatchSensitive
        }
        elseif ($bestMatchInsensitive) {
            if ($env:Z_DEBUG) {
                Write-Debug "Current best insensitive match: $bestMatchInsensitive (Score: $bestScoreInsensitive)"
            }
            return $bestMatchInsensitive
        }
        else {
            return $null
        }
    }
    else {
        return $bestMatch
    }
}

function Get-ZList {
    param(
        [string[]]$Query,
        [switch]$RestrictCurrent
    )
  
    # Compute the data file location (defaulting to "$HOME\.z" if not provided).
    $dataFile = $env:Z_DATA
    if (-not $dataFile) { $dataFile = Join-Path $HOME ".z" }
    if (-not (Test-Path $dataFile)) { return @() }
  
    $now = [int64](Get-Date -UFormat %s)
    if ($RestrictCurrent) {
        $currentDir = (Get-Location).Path
    }
    $results = @()
  
    # Process each entry in the data file and calculate the score.
    $lines = @(Get-Content $dataFile -ErrorAction SilentlyContinue | Where-Object { $_ -match '\|' })
    foreach ($line in $lines) {
        try {
            $parts = $line -split '\|'
            if ($parts.Count -ne 3) { continue }
            
            $path = $parts[0]
            $rank = [double]$parts[1]
            $timestamp = [int64]$parts[2]
            
            # Skip non-existing directories.
            if (-not (Test-Path $path)) { continue }
            
            # Enforce subdirectory restrictions if needed.
            if ($RestrictCurrent -and ($path -notlike ("{0}*" -f $currentDir))) {
                continue
            }
            
            # Compute the aging effect and derive the score.
            $age = $now - $timestamp
            # Compute the frecent score: using rank divided by (age + 1)
            # so that directories accessed frequently and recently rank higher.
            $score = $rank / ($age + 1)
  
            # Filter results by query string if provided using regex matching on the full path.
            if ($Query.Count -gt 0) {
                $q = ($Query -join " ")
                $pattern = $q -replace ' ', '.*'
                if (-not ([regex]::IsMatch($path, $pattern)) -and -not ([regex]::IsMatch($path, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase))) {
                    continue
                }
            }
            
            # Append the matching entry.
            $results += [PSCustomObject]@{
                Path  = $path
                Score = $score
                Rank  = $rank
            }
        }
        catch {
            Write-Debug "Failed to process line: $_"
            continue
        }
    }
    # Return the sorted list (highest scores first).
    return $results | Sort-Object Score -Descending
}

function z {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$args
    )

    # Main directory-jump function.
    # Usage: z [options] <directory query>
    # Options:
    #   -l, --list      : List all matching directories with scores.
    #   -r, --rank      : Use ranking mode only.
    #   -t, --recent    : Use recent mode only.
    #   -c, --current   : Restrict matches to subdirectories of the current directory.
    #   -e, --echo      : Echo the best match without changing the directory.
    #   -x, --remove    : Remove the current directory from tracking.
    #   --add           : Add a directory to the tracking database.
    #   --complete      : (Not implemented) For tab completion.
    
    if ($args.Count -eq 0) {
        Write-Host "Usage: z [options] <directory query>"
        Write-Host ""
        Write-Host "Options:"
        Write-Host "  -l, --list      List all matching directories with their scores"
        Write-Host "  -r, --rank      Use ranking mode only"
        Write-Host "  -t, --recent    Use recent mode only"
        Write-Host "  -c, --current   Restrict matches to subdirectories of current directory"
        Write-Host "  -e, --echo      Echo the best match without changing directory"
        Write-Host "  -x, --remove    Remove current directory from tracking"
        Write-Host "  --add           Add a directory to the database"
        return
    }

    # Initialize flags for mode and filtering.
    $mode = "frecent"
    $restrictCurrent = $false
    $echo = $false
    $remove = $false
    $searchTerms = @()

    # Parse provided arguments to set modes or flags.
    foreach ($arg in $args) {
        if ($arg.StartsWith("-")) {
            switch ($arg) {
                '-l' { } # Listing is handled later.
                '--list' { }
                '-r' { $mode = "rank"; continue }
                '--rank' { $mode = "rank"; continue }
                '-t' { $mode = "recent"; continue }
                '--recent' { $mode = "recent"; continue }
                '-c' { $restrictCurrent = $true; continue }
                '--current' { $restrictCurrent = $true; continue }
                '-e' { $echo = $true; continue }
                '--echo' { $echo = $true; continue }
                '-x' { $remove = $true; continue }
                '--remove' { $remove = $true; continue }
                '-h' {
                    Write-Host "Usage: z [options] <directory query>"
                    Write-Host ""
                    Write-Host "Options:"
                    Write-Host "  -l, --list      List all matching directories with their scores"
                    Write-Host "  -r, --rank      Use ranking mode only"
                    Write-Host "  -t, --recent    Use recent mode only"
                    Write-Host "  -c, --current   Restrict matches to subdirectories of current directory"
                    Write-Host "  -e, --echo      Echo the best match without changing directory"
                    Write-Host "  -x, --remove    Remove current directory from tracking"
                    Write-Host "  --add           Add a directory to the database"
                    Write-Host "  --complete      (Not implemented) Tab completion"
                    return
                }
                default {
                    # Handle combined single-dash flags (e.g. -rte)
                    if ($arg.Length -gt 2) {
                        $chars = $arg.Substring(1).ToCharArray()
                        foreach ($char in $chars) {
                            switch ("-$char") {
                                '-r' { $mode = "rank" }
                                '-t' { $mode = "recent" }
                                '-c' { $restrictCurrent = $true }
                                '-e' { $echo = $true }
                                '-x' { $remove = $true }
                                default { $searchTerms += "-$char" }
                            }
                        }
                        continue
                    }
                }
            }
        }
        else {
            # Append non-flag arguments as part of the search query.
            $searchTerms += $arg
        }
    }

    # If the list option is specified, display all matching directories.
    if ($args[0] -eq '-l' -or $args[0] -eq '--list') {
        $results = Get-ZList -Query $searchTerms -RestrictCurrent:($restrictCurrent)
        if ($results.Count -eq 0) {
            Write-Host "No matching directories found."
            return
        }
        Write-Host "Score    Rank     Path"
        Write-Host "--------------------------------"
        foreach ($entry in $results) {
            $score = "{0:N2}" -f $entry.Score
            $rank = "{0:N2}" -f $entry.Rank
            Write-Host ("{0,-8} {1,-8} {2}" -f $score, $rank, $entry.Path)
        }
        return
    }

    # If the remove flag is set, remove the current directory from tracking.
    if ($remove) {
        Remove-ZDirectory -Directory (Get-Location).Path
        return
    }

    # If the add flag is specified, add the given directory.
    if ($args[0] -eq '--add') {
        if ($args.Count -gt 1) {
            Add-ZDirectory $args[1]
        }
        return
    }
    if ($args[0] -eq '--complete') {
        Write-Host "Tab completion not implemented in this port."
        return
    }
    
    # Compute the best match using the provided query and mode.
    $jumpDir = Get-ZJump -Query $searchTerms -Mode $mode -RestrictCurrent:($restrictCurrent)
    if ($jumpDir) {
        if ($echo) {
            Write-Host $jumpDir
        }
        else {
            Set-Location $jumpDir
        }
    }
    else {
        Write-Host "No matching directory found."
    }
}

# Remove a directory from the tracking datafile.
function Remove-ZDirectory {
    param(
        [string]$Directory
    )
    # Remove-ZDirectory: Removes an entry for a directory from the tracking data file.
    $dataFile = $env:Z_DATA
    if (-not $dataFile) { $dataFile = Join-Path $HOME ".z" }
    if (-not (Test-Path $dataFile)) { return }
    # Retrieve existing entries.
    $lines = Get-Content $dataFile -ErrorAction SilentlyContinue
    # Create a regex pattern to match the directory entry.
    $escapedDir = [regex]::Escape($Directory) + "\|"
    # Filter out the entry corresponding to the directory.
    $filtered = $lines | Where-Object { $_ -notmatch $escapedDir }
    # Use file locking to update the file atomically.
    $lockFile = Lock-File -FilePath $dataFile
    try {
        $tempFile = "$dataFile.$(Get-Random)"
        Set-Content -Path $tempFile -Value $filtered -Force
        try {
            Move-Item -Path $tempFile -Destination $dataFile -Force -ErrorAction Stop
        }
        catch {
            Remove-Item $tempFile -Force
        }
    }
    finally {
        Unlock-File -LockFile $lockFile
    }
    Write-Host "Removed $Directory from tracking."
}

function Complete-ZDirectory {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    # Complete-ZDirectory: Provides tab-completion for the z command.
    # It retrieves all tracked directories and filters those that match the current input.
    $allDirs = Get-ZList -Query @()
    $results = $allDirs | Where-Object { $_.Path -like "$wordToComplete*" }
    $results | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Path, $_.Path, 'ParameterValue', $_.Path)
    }
}

function Lock-File {
    param(
        [string]$FilePath,
        [int]$TimeoutSeconds = 5
    )
    # Lock-File: Attempts to create a lock file to secure exclusive access to a resource.
    # If the lock file exists, the function waits (with a timeout) until it is removed.
    $lockFile = "$FilePath.lock"
    $start = Get-Date
    while (Test-Path $lockFile) {
        Start-Sleep -Milliseconds 100
        if (((Get-Date) - $start).TotalSeconds -gt $TimeoutSeconds) {
            throw "Timeout waiting for lock on $FilePath"
        }
    }
    # Create the lock file.
    New-Item -Path $lockFile -ItemType File -Force | Out-Null
    return $lockFile
}

function Unlock-File {
    param(
        [string]$LockFile
    )
    # Unlock-File: Releases the file lock by removing the lock file.
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}

function Update-Aging {
    param(
        [string[]]$Lines,
        [double]$MaxScore = 9000
    )

    # Update-Aging: Applies aging to the tracked directory scores.
    # When the total accumulated score exceeds the maximum threshold (MaxScore),
    # reduce each directory's rank by 1% to prevent runaway growth over time.
    $total = 0.0
    $newLines = @()
    foreach ($line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split '\|'
        if ($parts.Count -ne 3) { continue }
        $total += [double]$parts[1]
    }

    if ($total -gt $MaxScore) {
        foreach ($line in $Lines) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $parts = $line -split '\|'
            if ($parts.Count -ne 3) { continue }
            $agedRank = [double]$parts[1] * 0.99
            $newLines += "{0}|{1}|{2}" -f $parts[0], $agedRank, $parts[2]
        }
        return $newLines
    }
    else {
        return $Lines
    }
}

try {
    # Register an argument completer for the 'z' command to enable inline tab completion.
    Register-ArgumentCompleter -CommandName z -ParameterName args -ScriptBlock ${function:Complete-ZDirectory} -ErrorAction SilentlyContinue
}
catch {
    Write-Debug "Failed to register argument completer for z: $_"
} 