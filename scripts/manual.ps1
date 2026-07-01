function Get-RepositoryManualIndex {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    )

    $commandIndex = [System.Collections.Generic.List[object]]::new()
    $filesToScan = @()

    $aliasDir = Join-Path $RepositoryRoot 'alias'
    $scriptsDir = Join-Path $RepositoryRoot 'scripts'

    if (Test-Path $aliasDir) {
        $filesToScan += Get-ChildItem -Path $aliasDir -Filter '*.ps1' -File -ErrorAction SilentlyContinue
    }

    if (Test-Path $scriptsDir) {
        $filesToScan += Get-ChildItem -Path $scriptsDir -Filter '*.ps1' -File -ErrorAction SilentlyContinue
    }

    foreach ($file in ($filesToScan | Sort-Object FullName)) {
        $content = Get-Content -Path $file.FullName -Raw
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)

        if ($null -ne $errors) {
            foreach ($errorMessage in $errors) {
                Write-Verbose "Parse issue in $($file.FullName): $($errorMessage.Message)"
            }
        }

        $functionNodes = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true))
        foreach ($functionNode in $functionNodes) {
            $entry = [ordered]@{
                Name        = $functionNode.Name
                Kind        = 'Function'
                Group       = Get-ManualGroupName -Path $file.FullName
                Summary     = Get-CommandSummary -Name $functionNode.Name -SourceText $content -FunctionAst $functionNode
                Description = Get-CommandDescription -Name $functionNode.Name -SourceText $content -FunctionAst $functionNode
                Parameters  = Get-CommandParameters -FunctionAst $functionNode
                Examples    = Get-CommandExamples -SourceText $content -FunctionAst $functionNode
                SourceFile  = $file.FullName
                Aliases     = @()
                Target      = $null
            }

            $commandIndex.Add([pscustomobject]$entry)
        }

        $aliasMatches = [regex]::Matches($content, '(?m)^\s*Set-Alias\s+(?<alias>\S+)\s+(?<target>\S+)')
        foreach ($match in $aliasMatches) {
            $aliasName = $match.Groups['alias'].Value
            $targetName = $match.Groups['target'].Value

            if ($aliasName -match '^(help|man)$') {
                continue
            }

            $entry = [ordered]@{
                Name        = $aliasName
                Kind        = 'Alias'
                Group       = 'Repository aliases'
                Summary     = "Alias for $targetName"
                Description = "Shortcut for $targetName."
                Parameters  = @()
                Examples    = @()
                SourceFile  = $file.FullName
                Aliases     = @()
                Target      = $targetName
            }

            $commandIndex.Add([pscustomobject]$entry)
        }
    }

    $functionEntries = @($commandIndex | Where-Object Kind -eq 'Function')
    foreach ($aliasEntry in @($commandIndex | Where-Object Kind -eq 'Alias')) {
        $targetEntry = $functionEntries | Where-Object Name -eq $aliasEntry.Target | Select-Object -First 1
        if ($targetEntry) {
            if ($targetEntry.Aliases -notcontains $aliasEntry.Name) {
                $targetEntry.Aliases += $aliasEntry.Name
            }

            if ($aliasEntry.Examples.Count -eq 0 -and $targetEntry.Examples.Count -gt 0) {
                $aliasEntry.Examples = @($targetEntry.Examples | ForEach-Object { $_ -replace [regex]::Escape($targetEntry.Name), $aliasEntry.Name })
            }
        }

        if ($aliasEntry.Examples.Count -eq 0) {
            $aliasEntry.Examples = @("$($aliasEntry.Name)")
        }
    }

    return @($commandIndex | Sort-Object Kind, Name)
}

function Get-ManualGroupName {
    [CmdletBinding()]
    param([string]$Path)

    $relativePath = $Path -replace [regex]::Escape((Resolve-Path (Join-Path $PSScriptRoot '..')).Path), ''
    switch -Regex ($relativePath) {
        '[/\\]alias[/\\]' { 'Repository aliases' }
        '[/\\]scripts[/\\]git\.ps1$' { 'Git utilities' }
        '[/\\]scripts[/\\]files\.ps1$' { 'File utilities' }
        '[/\\]scripts[/\\]programs\.ps1$' { 'Program utilities' }
        '[/\\]scripts[/\\]windows\.ps1$' { 'Windows utilities' }
        default { 'Repository utilities' }
    }
}

function Get-CommandSummary {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$SourceText,
        [System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst
    )

    $helpText = Get-CommentHelp -SourceText $SourceText -FunctionAst $FunctionAst
    if ($helpText.Synopsis) {
        return $helpText.Synopsis
    }

    switch -Regex ($Name) {
        '^New-GitFirstCommit$' { return 'Initializes a new Git repository, stages files, creates an initial commit, and pushes it to a remote.' }
        '^Invoke-GitCommitPush$' { return 'Stages all changes, creates a conventional commit, rebases against the current branch, and pushes the result.' }
        '^Invoke-GitHardReset$' { return 'Resets the current branch to a remote branch and updates it from the remote.' }
        '^Invoke-GitRebase$' { return 'Rebases the current branch onto a chosen base branch from a remote.' }
        '^Invoke-GitCheckoutRemote$' { return 'Fetches a remote branch and checks it out locally, creating a tracking branch when needed.' }
        '^Copy-WithExclude$' { return 'Copies files and directories while skipping items that match exclusion keywords.' }
        '^Reset-IconCache$' { return 'Resets the Windows icon cache by restarting Explorer and removing cached icon databases.' }
        '^Get-HardwareSummary$' { return 'Collects a compact hardware summary for the current Windows machine.' }
        '^Clear-SystemJunk$' { return 'Cleans temporary and update-cache files from common Windows locations when run as Administrator.' }
        '^vim$' { return 'Launches Vim from the Git-for-Windows installation path.' }
        '^newps$' { return 'Starts a new PowerShell session.' }
        '^gpr$' { return 'Pulls the current branch with rebase and autostash enabled.' }
        '^gps$' { return 'Pushes the current branch with force-with-lease.' }
        default { return "Repository helper named $Name." }
    }
}

function Get-CommandDescription {
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$SourceText,
        [System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst
    )

    $helpText = Get-CommentHelp -SourceText $SourceText -FunctionAst $FunctionAst
    if ($helpText.Description) {
        return $helpText.Description
    }

    switch -Regex ($Name) {
        '^New-GitFirstCommit$' { return 'Creates a brand-new Git repository, commits the current tree, links it to a remote, and pushes the initial branch.' }
        '^Invoke-GitCommitPush$' { return 'Promotes local work into a documented commit, updates the branch from its remote, and publishes the result.' }
        '^Invoke-GitHardReset$' { return 'Forces the current branch to mirror a specific remote branch state.' }
        '^Invoke-GitRebase$' { return 'Replays the current branch changes on top of a selected base branch from a remote.' }
        '^Invoke-GitCheckoutRemote$' { return 'Makes a remote branch available locally and tracks it automatically.' }
        '^Copy-WithExclude$' { return 'Copies a directory tree to a target location while skipping files or folders that match user-defined exclusion keywords.' }
        '^Reset-IconCache$' { return 'Clears stale icon metadata and refreshes Explorer so Windows displays the desktop correctly.' }
        '^Get-HardwareSummary$' { return 'Returns a concise view of the operating system, processor, memory, and disk information.' }
        '^Clear-SystemJunk$' { return 'Removes temporary files and update caches that can accumulate over time, with administrative requirements enforced.' }
        '^vim$' { return 'Invokes the bundled Vim binary from the Git installation directory.' }
        '^newps$' { return 'Opens an additional PowerShell window for parallel work.' }
        '^gpr$' { return 'Performs a rebasing pull that keeps a branch up to date without losing local work.' }
        '^gps$' { return 'Pushes a branch using force-with-lease to prevent accidental overwrites.' }
        default { return "This repository helper is defined in the repository scripts and can be used directly in PowerShell." }
    }
}

function Get-CommentHelp {
    [CmdletBinding()]
    param(
        [string]$SourceText,
        [System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst
    )

    $prefix = $SourceText.Substring(0, $FunctionAst.Extent.StartOffset)
    $commentMatch = [regex]::Match($prefix, '(?s)(?<block><#.*?#>)\s*$')
    if (-not $commentMatch.Success) {
        return [pscustomobject]@{ Synopsis = ''; Description = '' }
    }

    $block = $commentMatch.Groups['block'].Value
    $block = $block -replace '^\s*<#\s*', '' -replace '\s*#>\s*$', ''
    $lines = $block -split "`r?`n"

    $synopsis = ''
    $description = ''
    $capturingDescription = $false

    foreach ($line in $lines) {
        $cleanLine = $line.Trim()
        if ($cleanLine -match '^#') {
            $cleanLine = $cleanLine -replace '^#\s?', ''
        }

        if ($cleanLine -match '^\.SYNOPSIS\s*(.*)$') {
            $synopsis = $Matches[1].Trim()
            $capturingDescription = $false
            continue
        }

        if ($cleanLine -match '^\.DESCRIPTION\s*(.*)$') {
            $description = $Matches[1].Trim()
            $capturingDescription = $true
            continue
        }

        if ($cleanLine -match '^\.(PARAMETER|EXAMPLE|EXAMPLES|NOTES|SEE)\b') {
            $capturingDescription = $false
            continue
        }

        if ($capturingDescription -and $cleanLine) {
            if ($description) {
                $description = "$description $cleanLine"
            }
            else {
                $description = $cleanLine
            }
        }
    }

    return [pscustomobject]@{ Synopsis = $synopsis; Description = $description }
}

function Get-CommandParameters {
    [CmdletBinding()]
    param([System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst)

    $params = @()
    if (-not $FunctionAst.Body.ParamBlock) {
        return $params
    }

    foreach ($parameter in $FunctionAst.Body.ParamBlock.Parameters) {
        $name = $parameter.Name.VariablePath.UserPath
        $required = $false
        foreach ($attribute in $parameter.Attributes) {
            if ($attribute.TypeName.Name -eq 'Parameter' -and $attribute.NamedArguments.NamedArguments) {
                foreach ($argument in $attribute.NamedArguments.NamedArguments) {
                    if ($argument.ArgumentName -eq 'Mandatory' -and $argument.Argument -is [System.Management.Automation.Language.ConstantExpressionAst] -and $argument.Argument.Value) {
                        $required = $true
                    }
                }
            }
        }

        $defaultValue = $null
        if ($parameter.DefaultValue) {
            $defaultValue = $parameter.DefaultValue.Extent.Text
        }

        $params += [pscustomobject]@{
            Name         = $name
            Required     = $required
            DefaultValue = $defaultValue
        }
    }

    return $params
}

function Get-CommandExamples {
    [CmdletBinding()]
    param(
        [string]$SourceText,
        [System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst
    )

    $helpText = Get-CommentHelp -SourceText $SourceText -FunctionAst $FunctionAst
    $examples = @()

    if ($helpText.Description -and $helpText.Synopsis) {
        $examples = @($examples)
    }

    $simpleExamples = switch -Regex ($FunctionAst.Name) {
        '^New-GitFirstCommit$' { @('New-GitFirstCommit -RepoUrl "https://github.com/example/repo.git" -CommitMessage "initial import"') }
        '^Invoke-GitCommitPush$' { @('Invoke-GitCommitPush -Type feat -Message "add docs"') }
        '^Invoke-GitHardReset$' { @('Invoke-GitHardReset -Branch main -Remote origin') }
        '^Invoke-GitRebase$' { @('Invoke-GitRebase -BaseBranch main -Remote origin') }
        '^Invoke-GitCheckoutRemote$' { @('Invoke-GitCheckoutRemote -Branch feature/example') }
        '^Copy-WithExclude$' { @('Copy-WithExclude -DestinationPath "C:\Backup" -Exclude "node_modules", "bin"') }
        '^Reset-IconCache$' { @('Reset-IconCache') }
        '^Get-HardwareSummary$' { @('Get-HardwareSummary') }
        '^Clear-SystemJunk$' { @('Clear-SystemJunk') }
        '^vim$' { @('vim README.md') }
        '^newps$' { @('newps') }
        '^gpr$' { @('gpr') }
        '^gps$' { @('gps') }
        default { @("{0}" -f $FunctionAst.Name) }
    }

    return $simpleExamples
}

function Format-ManualPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Entry,
        [Parameter(Mandatory)]
        [object[]]$Index
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('')
    $lines.Add(('=' * 78))
    $lines.Add('NAME')
    if ($Entry.Kind -eq 'Alias') {
        $lines.Add("    $($Entry.Name) - $($Entry.Summary)")
    }
    else {
        $lines.Add("    $($Entry.Name) - $($Entry.Summary)")
    }
    $lines.Add('')
    $lines.Add('SYNOPSIS')
    if ($Entry.Kind -eq 'Alias') {
        $lines.Add("    $($Entry.Name) -> $($Entry.Target)")
    }
    else {
        $syntax = $Entry.Name
        if ($Entry.Parameters.Count -gt 0) {
            $syntax += ' '
            $parameterText = foreach ($parameter in $Entry.Parameters) {
                $prefix = if ($parameter.Required) { '-' } else { '[-' }
                $suffix = if ($parameter.Required) { '' } else { ']' }
                "$prefix$($parameter.Name)$suffix"
            }
            $syntax += ($parameterText -join ' ')
        }
        $lines.Add("    $syntax")
    }
    $lines.Add('')
    $lines.Add('DESCRIPTION')
    $lines.Add("    $($Entry.Description)")
    $lines.Add('')

    if ($Entry.Kind -eq 'Alias') {
        $lines.Add('ALIASES')
        $lines.Add("    This alias resolves to $($Entry.Target).")
        $lines.Add('')
    }
    else {
        $lines.Add('ALIASES')
        if ($Entry.Aliases.Count -gt 0) {
            $lines.Add("    $($Entry.Aliases -join ', ')")
        }
        else {
            $lines.Add('    None.')
        }
        $lines.Add('')
    }

    $relatedCommands = @($Index | Where-Object { $_.Group -eq $Entry.Group -and $_.Name -ne $Entry.Name } | Select-Object -First 6)
    $lines.Add('FUNCTIONS')
    if ($Entry.Kind -eq 'Function') {
        $lines.Add("    $($Entry.Group)")
    }
    else {
        $lines.Add("    Alias for $($Entry.Target)")
    }
    $lines.Add('')

    $lines.Add('PARAMETERS')
    if ($Entry.Parameters.Count -gt 0) {
        foreach ($parameter in $Entry.Parameters) {
            $requiredText = if ($parameter.Required) { 'Required.' } else { 'Optional.' }
            $defaultText = if ($parameter.DefaultValue) { " Default: $($parameter.DefaultValue)." } else { '' }
            $lines.Add("    -$($parameter.Name)  $requiredText$defaultText")
        }
    }
    else {
        $lines.Add('    None.')
    }
    $lines.Add('')

    $lines.Add('EXAMPLES')
    if ($Entry.Examples.Count -gt 0) {
        foreach ($example in $Entry.Examples) {
            $lines.Add("    $example")
        }
    }
    else {
        $lines.Add('    No examples are provided in the source comments.')
    }
    $lines.Add('')

    $lines.Add('NOTES')
    $lines.Add("    This command is defined in $([System.IO.Path]::GetFileName($Entry.SourceFile)).")
    if ($Entry.Aliases.Count -gt 0 -or ($Entry.Kind -eq 'Alias' -and $Entry.Target)) {
        $lines.Add('    Alias and function relationships are resolved automatically from the repository files.')
    }
    $lines.Add('')

    $lines.Add('SEE ALSO')
    if ($relatedCommands.Count -gt 0) {
        foreach ($related in $relatedCommands) {
            $lines.Add("    $($related.Name)")
        }
    }
    else {
        $lines.Add('    help')
    }
    $lines.Add(('=' * 78))
    $lines.Add('')

    return ($lines -join [Environment]::NewLine)
}

function Format-OverviewPage {
    [CmdletBinding()]
    param([object[]]$Index)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('')
    $lines.Add(('=' * 78))
    $lines.Add('NAME')
    $lines.Add('    PowerShell Repository Manual - interactive documentation for custom aliases and functions')
    $lines.Add('')
    $lines.Add('SYNOPSIS')
    $lines.Add('    help')
    $lines.Add('    man')
    $lines.Add('    man <command-name>')
    $lines.Add('')
    $lines.Add('DESCRIPTION')
    $lines.Add('    This manual indexes the repository''s custom PowerShell functions and aliases and renders them in a man-page-inspired layout.')
    $lines.Add('    Use help or man with no arguments to view the complete overview. Use man <name> to inspect one specific alias or function.')
    $lines.Add('')
    $lines.Add('COMMANDS')

    $groups = $Index | Group-Object Group | Sort-Object Name
    foreach ($group in $groups) {
        $lines.Add("    $($group.Name)")
        foreach ($entry in ($group.Group | Sort-Object Name)) {
            $detail = if ($entry.Kind -eq 'Alias') { "$($entry.Name) -> $($entry.Target)" } else { $entry.Name }
            $lines.Add("        - $detail  $($entry.Summary)")
        }
        $lines.Add('')
    }

    $lines.Add('NOTES')
    $lines.Add('    The index is rebuilt from the repository scripts every time you run the manual, so new aliases or functions appear automatically.')
    $lines.Add('')
    $lines.Add('SEE ALSO')
    $lines.Add('    man <command-name>')
    $lines.Add(('=' * 78))
    $lines.Add('')

    return ($lines -join [Environment]::NewLine)
}

function Show-CommandManual {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name
    )

    $index = Get-RepositoryManualIndex
    if (-not $Name) {
        $page = Format-OverviewPage -Index $index
        Write-Host $page
        return $page
    }

    $record = $null

    $exactNameMatch = @($index | Where-Object { $_.Name -eq $Name } | Select-Object -First 1)
    if ($exactNameMatch) {
        $record = $exactNameMatch
    }
    else {
        $exactTargetMatch = @($index | Where-Object { $_.Kind -eq 'Function' -and $_.Name -eq $Name } | Select-Object -First 1)
        if ($exactTargetMatch) {
            $record = $exactTargetMatch
        }
        else {
            foreach ($entry in $index) {
                if ($entry.Target -eq $Name -or $entry.Aliases -contains $Name) {
                    $record = $entry
                    break
                }
            }
        }
    }

    if (-not $record) {
        $candidates = @($index | Where-Object { $_.Name -like "*$Name*" -or $_.Target -like "*$Name*" } | Select-Object -First 10)
        if ($candidates.Count -gt 0) {
            $page = "No exact command named '$Name' was found. Did you mean:`n`n"
            foreach ($candidate in $candidates) {
                $page += "    $($candidate.Name)`n"
            }
            Write-Host $page
            return $page
        }

        $page = "No manual entry was found for '$Name'."
        Write-Host $page
        return $page
    }

    $page = Format-ManualPage -Entry $record -Index $index
    Write-Host $page
    return $page
}

function help {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name
    )

    Show-CommandManual -Name $Name
}

function global:man {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Name
    )

    Show-CommandManual -Name $Name
}
