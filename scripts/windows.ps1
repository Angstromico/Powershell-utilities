function Reset-IconCache {
    <#
    .SYNOPSIS
        Resets the Windows icon cache.

    .DESCRIPTION
        Stops the Windows Explorer process, deletes the icon cache databases, and restarts Explorer.
        This is useful for fixing broken or incorrect icons on the desktop and in file explorer.

    .EXAMPLE
        Reset-IconCache
        Resets the icon cache.

    .EXAMPLE
        Reset-IconCache -Verbose
        Resets the icon cache with detailed output.
    #>
    [CmdletBinding()]
    param()

    process {
        Write-Verbose "Attempting to stop Explorer process..."
        try {
            # Use -ErrorAction SilentlyContinue in case Explorer is already stopped
            $explorerProcesses = Get-Process -Name explorer -ErrorAction SilentlyContinue
            if ($explorerProcesses) {
                Stop-Process -Name explorer -Force -ErrorAction Stop
                # Give it a moment to release file locks
                Start-Sleep -Seconds 1
            } else {
                Write-Verbose "Explorer process not running."
            }
        }
        catch {
            Write-Warning "An error occurred while stopping Explorer: $($_.Exception.Message)"
        }

        $cachePaths = @(
            "$env:LOCALAPPDATA\IconCache.db",
            "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*"
        )

        foreach ($path in $cachePaths) {
            if (Test-Path $path) {
                Write-Verbose "Removing: $path"
                try {
                    Remove-Item -Path $path -Force -ErrorAction Stop
                }
                catch {
                    # If it fails, it's often because a file is still locked.
                    Write-Error "Failed to delete $path. It may be in use by another process. Error: $($_.Exception.Message)"
                }
            }
            else {
                Write-Verbose "Path not found or already deleted: $path"
            }
        }

        Write-Verbose "Restarting Explorer..."
        try {
            Start-Process explorer.exe
            Write-Host "Windows icon cache has been reset successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to restart Explorer. You may need to start it manually via Task Manager (Ctrl+Shift+Esc > File > Run new task > explorer.exe). Error: $($_.Exception.Message)"
        }
    }
}

function newps {
    Start-Process powershell
}

function Get-HardwareSummary {
    <#
    .SYNOPSIS
        Provides a brief summary of the computer's hardware.
    #>
    [CmdletBinding()]
    param()

    process {
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1

        [PSCustomObject]@{
            OS     = $os.Caption
            CPU    = $cpu.Name.Trim()
            RAM    = "$([Math]::Round($memory.Sum / 1GB, 2)) GB"
            GPU    = $gpu.Name
            Disk_C = "$([Math]::Round($disk.FreeSpace / 1GB, 2)) GB free of $([Math]::Round($disk.Size / 1GB, 2)) GB"
        }
    }
}

function Clear-SystemJunk {
    <#
    .SYNOPSIS
        Safely clears temporary files and Windows Update installer cache.
    .DESCRIPTION
        Requires Administrative privileges. Cleans:
        - User Temp folder ($env:TEMP)
        - Windows System Temp folder (C:\Windows\Temp)
        - Windows Prefetch (C:\Windows\Prefetch)
        - Windows Update Download cache (C:\Windows\SoftwareDistribution\Download)
    #>
    [CmdletBinding()]
    param()

    process {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Error "This function requires Administrative privileges. Please restart PowerShell as Administrator."
            return
        }

        $targets = @(
            $env:TEMP,
            "C:\Windows\Temp",
            "C:\Windows\Prefetch",
            "C:\Windows\SoftwareDistribution\Download"
        )

        foreach ($folder in $targets) {
            if (Test-Path $folder) {
                Write-Host "Cleaning: $folder..." -ForegroundColor Cyan
                try {
                    # Get all items inside the folder and attempt to remove them
                    Get-ChildItem -Path $folder -Recurse -ErrorAction SilentlyContinue | 
                        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "  Done." -ForegroundColor Green
                }
                catch {
                    Write-Warning "  Some files in $folder could not be deleted (they may be in use)."
                }
            }
        }
        Write-Host "System cleanup complete!" -ForegroundColor Cyan
    }
}
