function Copy-WithExclude {
    <#
    .SYNOPSIS
        Copies files and directories while excluding items matching specific keywords.

    .DESCRIPTION
        Recursively copies the contents of a source directory to a destination.
        Items (files or folders) whose names match any of the provided exclusion keywords will be skipped.
        If a folder is excluded, all its contents are also skipped.

    .PARAMETER SourcePath
        The path to the directory to copy from. Defaults to the current directory.

    .PARAMETER DestinationPath
        The path to the directory to copy to.

    .PARAMETER Exclude
        An array of strings (keywords) to exclude. If an item's name contains any of these keywords, it and its children will be skipped.

    .EXAMPLE
        Copy-WithExclude -DestinationPath "C:\Backup" -Exclude "node_modules", "bin"
        Copies the current directory to C:\Backup, skipping any "node_modules" or "bin" folders/files.

    .EXAMPLE
        Copy-WithExclude -SourcePath ".\src" -DestinationPath ".\dist" -Exclude "test"
        Copies the src directory to dist, skipping any items with "test" in their name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$SourcePath = ".",

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $true)]
        [string[]]$Exclude
    )

    process {
        $resolvedSource = Resolve-Path $SourcePath
        $sourceFullPath = $resolvedSource.Path
        
        if (-not (Test-Path $DestinationPath)) {
            Write-Verbose "Creating destination directory: $DestinationPath"
            New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
        }
        $destinationFullPath = (Resolve-Path $DestinationPath).Path

        Write-Verbose "Copying from $sourceFullPath to $destinationFullPath"
        Write-Verbose "Excluding keywords: $($Exclude -join ', ')"

        $items = Get-ChildItem -Path $sourceFullPath -Recurse

        foreach ($item in $items) {
            $relativePath = $item.FullName.Substring($sourceFullPath.Length).TrimStart('\')
            
            if ([string]::IsNullOrWhiteSpace($relativePath)) { continue }

            $shouldExclude = $false
            $pathSegments = $relativePath -split '\\'
            
            foreach ($segment in $pathSegments) {
                foreach ($keyword in $Exclude) {
                    if ($segment -like "*$keyword*") {
                        $shouldExclude = $true
                        break
                    }
                }
                if ($shouldExclude) { break }
            }

            if ($shouldExclude) {
                Write-Verbose "Excluding: $relativePath"
                continue
            }

            $targetPath = Join-Path $destinationFullPath $relativePath
            
            if ($item.PSIsContainer) {
                if (-not (Test-Path $targetPath)) {
                    Write-Verbose "Creating directory: $targetPath"
                    New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
                }
            } else {
                $parentDir = Split-Path $targetPath
                if (-not (Test-Path $parentDir)) {
                    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
                }
                Write-Verbose "Copying file: $relativePath"
                Copy-Item -Path $item.FullName -Destination $targetPath -Force
            }
        }
        
        Write-Host "Copy complete (with exclusions) to: $destinationFullPath" -ForegroundColor Green
    }
}
