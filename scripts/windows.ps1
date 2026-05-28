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
