# Prompt, window title, and the once-a-day startup banner.
#
# The prompt itself is installed by Initialize-HyperShellPrompt, which the
# profile calls. Starship owns the rendering when it is installed; HyperShell
# only wraps it to keep the terminal title in sync.

<#
.SYNOPSIS
    Tests whether this session is an interactive terminal.
.DESCRIPTION
    Redirected input or output means a script or a pipeline, and the banner
    stays out of those.
#>
function Test-HyperShellInteractiveSession {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    return (-not [Console]::IsOutputRedirected) -and (-not [Console]::IsInputRedirected)
}

<#
.SYNOPSIS
    Returns the directory HyperShell keeps its session state in.
.DESCRIPTION
    LOCALAPPDATA on Windows, XDG_CACHE_HOME when it is set, ~/.cache otherwise.
#>
function Get-HyperShellStateDirectory {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($env:LOCALAPPDATA) {
        return Join-Path $env:LOCALAPPDATA 'HyperShell'
    }

    if ($env:XDG_CACHE_HOME) {
        return Join-Path $env:XDG_CACHE_HOME 'hypershell'
    }

    return Join-Path -Path $HOME -ChildPath '.cache' -AdditionalChildPath 'hypershell'
}

<#
.SYNOPSIS
    Returns the path of the file recording the last banner date.
#>
function Get-HyperShellStartupStampPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return Join-Path (Get-HyperShellStateDirectory) 'startup-banner.date'
}

<#
.SYNOPSIS
    Tests whether the startup banner is due today.
#>
function Test-HyperShellStartupDue {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Test-HyperShellInteractiveSession)) {
        return $false
    }

    $stampPath = Get-HyperShellStartupStampPath
    $today = Get-Date -Format 'yyyy-MM-dd'
    $lastShown = Get-Content -Path $stampPath -TotalCount 1 -ErrorAction SilentlyContinue

    return $lastShown -ne $today
}

<#
.SYNOPSIS
    Records that the banner has been shown today.
.DESCRIPTION
    Failure is not fatal. A read-only or missing cache directory means the
    banner shows more often than it should, which beats a broken startup.
#>
function Set-HyperShellStartupShown {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $stateDir = Get-HyperShellStateDirectory
    $stampPath = Get-HyperShellStartupStampPath

    if (-not $PSCmdlet.ShouldProcess($stampPath, 'Record banner date')) {
        return
    }

    try {
        New-Item -Path $stateDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Set-Content -Path $stampPath -Value (Get-Date -Format 'yyyy-MM-dd') -Encoding ASCII -ErrorAction Stop
    }
    catch {
        Write-Debug "HyperShell could not write $stampPath : $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Prints the HyperShell banner, once per day.
.PARAMETER Force
    Print it regardless of the daily cadence.
.PARAMETER PassThru
    Return $true when the banner was printed, $false when it was skipped.
.EXAMPLE
    Show-HyperShellStartup -Force
#>
function Show-HyperShellStartup {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
        Justification = 'The banner is terminal decoration, not pipeline output.')]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [switch]$Force,
        [switch]$PassThru
    )

    if (-not $Force -and -not (Test-HyperShellStartupDue)) {
        if ($PassThru) {
            return $false
        }

        return
    }

    $esc = [char]27
    $version = $script:HyperShellVersion

    Set-HyperShellStartupShown
    Write-Host "$esc[38;5;213m⟨$esc[38;5;207m⟨$esc[38;5;201m⟨ $esc[1m$esc[38;5;219m☆ $esc[38;5;159mHYPER$esc[38;5;213mSHELL$esc[38;5;219m::$esc[38;5;123m$version $esc[22m$esc[38;5;201m⟩$esc[38;5;207m⟩$esc[38;5;213m⟩$esc[0m"

    if ($PassThru) {
        return $true
    }
}

<#
.SYNOPSIS
    Runs the dotfiles inspiration script.
.DESCRIPTION
    Looks for inspiration/inspiration.py under $env:DOTFILES, then under
    ~/dev/dotfiles. Silently does nothing when neither the checkout nor python
    is around.
#>
function Show-HyperShellInspiration {
    [CmdletBinding()]
    param()

    $root = Get-HyperShellDotfilesRoot
    if (-not $root) {
        return
    }

    $inspirationScript = Join-Path -Path $root -ChildPath 'inspiration' -AdditionalChildPath 'inspiration.py'
    if (-not (Test-Path -LiteralPath $inspirationScript)) {
        return
    }

    $python = @('python3', 'python') | Where-Object { Test-HyperShellCommand -Name $_ } | Select-Object -First 1
    if (-not $python) {
        return
    }

    try {
        & $python $inspirationScript
    }
    catch {
        Write-Warning "HyperShell could not run the inspiration script: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Replaces the home directory in a path with a tilde.
.EXAMPLE
    Get-HyperShellNormalizedPath -Path "$HOME/dev/dotfiles"   # ~/dev/dotfiles
#>
function Get-HyperShellNormalizedPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Path
    )

    if ([string]::IsNullOrEmpty($Path)) {
        return $Path
    }

    if ($Path.StartsWith($HOME)) {
        return '~' + $Path.Substring($HOME.Length)
    }

    return $Path
}

<#
.SYNOPSIS
    Returns the leaf name of the current directory, home-normalized.
#>
function Get-HyperShellCurrentDirectoryName {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return Split-Path -Leaf (Get-HyperShellNormalizedPath -Path $PWD.Path)
}

<#
.SYNOPSIS
    Sets the terminal window title.
#>
function Set-HyperShellWindowTitle {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Title
    )

    if (-not $PSCmdlet.ShouldProcess($Title, 'Set window title')) {
        return
    }

    try {
        $Host.UI.RawUI.WindowTitle = $Title
    }
    catch {
        Write-Debug "HyperShell could not set the window title: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Returns starship's PowerShell init script.
.DESCRIPTION
    Returns $null when starship is not installed. The script declares
    `function global:prompt`, so dot-sourcing it from anywhere still installs
    the prompt globally.
#>
function Get-HyperShellStarshipInitScript {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (-not (Test-HyperShellCommand -Name 'starship')) {
        return $null
    }

    try {
        return (& starship init powershell --print-full-init | Out-String)
    }
    catch {
        Write-Warning "HyperShell could not read the starship init script: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Installs the HyperShell prompt.
.DESCRIPTION
    Runs starship's init when starship is installed and falls back to a plain
    HyperShell prompt when it is not. Either way the prompt is wrapped so the
    terminal title follows the current directory.
.PARAMETER NoStarship
    Skip starship and install the fallback prompt.
.EXAMPLE
    Initialize-HyperShellPrompt
#>
function Initialize-HyperShellPrompt {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$NoStarship
    )

    if (-not $PSCmdlet.ShouldProcess('prompt', 'Install the HyperShell prompt')) {
        return
    }

    $starshipInstalled = $false
    if (-not $NoStarship) {
        $init = Get-HyperShellStarshipInitScript
        if ($init) {
            # Dot-sourced rather than passed to Invoke-Expression so the init
            # runs as a script block; it declares its own global functions.
            . ([scriptblock]::Create($init))
            $starshipInstalled = $true
        }
    }

    if ($starshipInstalled) {
        # function:global:prompt is not a valid provider path (it silently
        # resolves to nothing), so the current prompt comes from Get-Command.
        $script:HyperShellBasePrompt = (Get-Command -Name prompt -CommandType Function -ErrorAction SilentlyContinue).ScriptBlock
    }
    else {
        $script:HyperShellBasePrompt = {
            $esc = [char]27
            "$esc[38;5;213mHyperShell$esc[0m $esc[38;5;159m$(Get-HyperShellNormalizedPath -Path $PWD.Path)$esc[0m$esc[38;5;201m>$esc[0m "
        }
    }

    $script:HyperShellLastPromptPath = $null

    # The global prompt is a one-line shim on purpose. A function defined with
    # the global: modifier from inside a module runs against the global
    # session state, so $script: inside it would resolve to the global scope
    # and find nothing. Invoke-HyperShellPrompt is a module function, so it
    # keeps its own state.
    function global:prompt { Invoke-HyperShellPrompt }
}

<#
.SYNOPSIS
    Renders the HyperShell prompt.
.DESCRIPTION
    Keeps the window title in sync with the current directory, then calls
    through to whatever prompt Initialize-HyperShellPrompt captured, which is
    starship's when starship is installed. The title is only rewritten when
    the directory actually changed.
#>
function Invoke-HyperShellPrompt {
    [CmdletBinding()]
    param()

    if (-not $script:HyperShellBasePrompt) {
        return "HyperShell> "
    }

    if ($script:HyperShellLastPromptPath -ne $PWD.Path) {
        $script:HyperShellLastPromptPath = $PWD.Path
        Set-HyperShellWindowTitle -Title "HyperShell - $(Get-HyperShellNormalizedPath -Path $PWD.Path)"
    }

    & $script:HyperShellBasePrompt
}
