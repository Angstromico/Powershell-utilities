
function New-GitFirstCommit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoUrl,

        [string]$CommitMessage = "first commit"
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git is not installed or not in PATH."
    }

    if (Test-Path ".git") {
        throw "This directory is already a Git repository."
    }

    Write-Host "Initializing git repository..."
    git init

    Write-Host "Adding files..."
    git add .

    Write-Host "Creating commit..."
    git commit -m $CommitMessage

    Write-Host "Setting main branch..."
    git branch -m main

    Write-Host "Adding remote origin..."
    git remote add origin $RepoUrl

    Write-Host "Pushing to remote..."
    git push -u origin main

    Write-Host "✅ Repository initialized and pushed successfully." -ForegroundColor Green
}

function Invoke-GitCommitPush {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("feat", "bugfix", "chore", "docs", "refactor")]
        [string]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git is not installed or not in PATH."
    }

    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ([string]::IsNullOrEmpty($branch)) {
        throw "Not inside a Git repository."
    }

    Write-Host "Let's launch your code to GitHub!" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Branch: " -NoNewline -ForegroundColor Cyan
    Write-Host $branch -ForegroundColor Yellow
    Write-Host "Commit type: " -NoNewline -ForegroundColor Cyan
    Write-Host $Type -ForegroundColor Yellow
    Write-Host "Message: " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Green
    Write-Host ""

    Write-Host "Staging all changes..." -ForegroundColor Blue
    git add .

    Write-Host "Creating commit..." -ForegroundColor Blue
    git commit -m "$Type`: $Message"

    Write-Host "Pulling latest changes from origin/$branch..." -ForegroundColor Blue
    git pull origin $branch --rebase

    Write-Host "Pushing to origin/$branch..." -ForegroundColor Blue
    git push origin $branch

    Write-Host ""
    Write-Host "All done! Your code is now live on GitHub." -ForegroundColor Green
}

function Invoke-GitHardReset {
    [CmdletBinding()]
    param (
        [string]$Branch = "main",
        [string]$Remote = "origin"
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git is not installed or not in PATH."
    }

    $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ([string]::IsNullOrEmpty($currentBranch)) {
        throw "Not inside a Git repository."
    }

    Write-Host "Resetting current branch to $Remote/$Branch..." -ForegroundColor Magenta
    Write-Host ""

    Write-Host "Fetching latest changes from $Remote..." -ForegroundColor Blue
    git fetch $Remote

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch from $Remote."
    }

    Write-Host "Performing hard reset to $Remote/$Branch..." -ForegroundColor Blue
    git reset --hard "$Remote/$Branch"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to reset to $Remote/$Branch. Ensure the branch exists on the remote."
    }

    Write-Host ""
    Write-Host "✅ Successfully reset to $Remote/$Branch." -ForegroundColor Green
}

function Invoke-GitRebase {
    [CmdletBinding()]
    param (
        [string]$BaseBranch = "main",
        [string]$Remote = "origin"
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git is not installed or not in PATH."
    }

    $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ([string]::IsNullOrEmpty($currentBranch)) {
        throw "Not inside a Git repository."
    }

    Write-Host "Rebasing $Remote/$BaseBranch into $currentBranch..." -ForegroundColor Magenta
    Write-Host ""

    Write-Host "Fetching latest changes from $Remote..." -ForegroundColor Blue
    git fetch $Remote

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch from $Remote."
    }

    # ✅ Validate branch exists
    $remoteBranchExists = git ls-remote --heads $Remote $BaseBranch
    if (-not $remoteBranchExists) {
        throw "Remote branch '$Remote/$BaseBranch' does not exist."
    }

    Write-Host "Performing rebase of $Remote/$BaseBranch into $currentBranch..." -ForegroundColor Blue

    git rebase "$Remote/$BaseBranch" 2>&1 | ForEach-Object { Write-Host $_ }

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️ Rebase failed. Resolve conflicts, then run:" -ForegroundColor Red
        Write-Host "   git rebase --continue" -ForegroundColor Yellow
        Write-Host "   (or 'git rebase --abort' to cancel)" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "✅ Successfully rebased onto $Remote/$BaseBranch." -ForegroundColor Green
}

function Invoke-GitCheckoutRemote {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Branch,

        [string]$Remote = "origin"
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git is not installed or not in PATH."
    }

    Write-Host "Fetching latest branches from $Remote..." -ForegroundColor Blue
    git fetch $Remote

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch from $Remote."
    }

    # Check if remote branch exists
    $remoteExists = git ls-remote --heads $Remote $Branch

    if (-not $remoteExists) {
        throw "Branch '$Branch' does not exist on $Remote."
    }

    # Check if local branch already exists
    $localExists = git branch --list $Branch

    if ($localExists) {
        Write-Host "Local branch exists. Switching to $Branch..." -ForegroundColor Yellow
        git checkout $Branch

        Write-Host "Pulling latest changes..." -ForegroundColor Blue
        git pull $Remote $Branch
    }
    else {
        Write-Host "Creating and tracking $Remote/$Branch..." -ForegroundColor Yellow
        git checkout -b $Branch "$Remote/$Branch"
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to checkout branch '$Branch'."
    }

    Write-Host ""
    Write-Host "✅ Now on branch '$Branch' with latest from $Remote." -ForegroundColor Green
}

Set-Alias gco Invoke-GitCheckoutRemote

function gpr {
    git pull -r --autostash
}


function gps {
    git push --force-with-lease
}

<#
.SYNOPSIS
Creates a new GitHub SSH key pair and adds it to the SSH agent.

.DESCRIPTION
Generates an ed25519 SSH key in the user's .ssh folder, starts the SSH agent if needed,
and adds the private key so GitHub authentication can be used in the current session.

.PARAMETER Email
The email address to associate with the new SSH key.

.PARAMETER KeyName
The file name for the generated key. Defaults to id_ed25519_github.

.EXAMPLE
New-GitHubSSHKey -Email "name@example.com"

.EXAMPLE
New-GitHubSSHKey -Email "name@example.com" -KeyName "github_work"
#>
function New-GitHubSSHKey {
    param(
        [Parameter(Mandatory)]
        [string]$Email,

        [string]$KeyName = "id_ed25519_github"
    )

    $SSHPath = Join-Path $HOME ".ssh"
    $KeyFile = Join-Path $SSHPath $KeyName

    if (-not (Test-Path $SSHPath)) {
        New-Item -ItemType Directory -Path $SSHPath | Out-Null
    }

    if (Test-Path $KeyFile) {
        Write-Host "La clave ya existe: $KeyFile" -ForegroundColor Yellow
        return
    }

    ssh-keygen -t ed25519 -C $Email -f $KeyFile

    $Agent = Get-Service ssh-agent -ErrorAction SilentlyContinue

    if ($Agent.Status -ne 'Running') {
        Set-Service ssh-agent -StartupType Automatic
        Start-Service ssh-agent
    }

    ssh-add $KeyFile

    Write-Host "`nClave creada:" -ForegroundColor Green
    Write-Host $KeyFile

    Write-Host "`nContenido de la clave publica:" -ForegroundColor Cyan
    Get-Content "${KeyFile}.pub"
}



<#
.SYNOPSIS
Configures the global Git identity and optionally updates the current repository's origin URL to use a chosen SSH alias.

.DESCRIPTION
Sets `git config --global user.name` and `git config --global user.email` for the current user.
If invoked inside a Git repository, it also rewrites the `origin` remote to use the provided SSH alias when the URL matches a GitHub SSH pattern.
This is useful for switching between personal and work GitHub accounts.

.PARAMETER UserName
The global Git username.

.PARAMETER Email
The global Git email.

.PARAMETER SshAlias
The SSH hostname alias to use for the repository's origin remote.

.EXAMPLE
Set-GitProfile -UserName "Jane Doe" -Email "jane@work.com" -SshAlias "github-work"

.EXAMPLE
Set-GitProfile -UserName "John Doe" -Email "john@personal.com" -SshAlias "github-personal"
#>
function Set-GitProfile {
    param(
        [Parameter(Mandatory)]
        [string]$UserName,

        [Parameter(Mandatory)]
        [string]$Email,

        [Parameter(Mandatory)]
        [string]$SshAlias
    )

    # Update Git identity
    git config --global user.name $UserName
    git config --global user.email $Email

    # Update origin if we are inside a repo
    if (git rev-parse --is-inside-work-tree 2>$null) {

        $url = git remote get-url origin 2>$null

        if ($url) {

            if ($url -match 'github[^:]*:(.+)$') {
                $repoPath = $Matches[1]

                git remote set-url origin "git@$SshAlias`:$repoPath"

                Write-Host "Origin updated:" -ForegroundColor Green
                Write-Host "git@$SshAlias`:$repoPath"
            }
        }
    }

    Write-Host ""
    Write-Host "Git configured:" -ForegroundColor Green
    Write-Host "  UserName : $UserName"
    Write-Host "  Email    : $Email"
    Write-Host "  SSH Host : $SshAlias"
}



function Use-GitPersonal {
    Set-GitProfile `
        -UserName "Angstromico" `
        -Email "manuesteban1990@gmail.com" `
        -SshAlias "github-personal"
}

function Use-GitWork {
    Set-GitProfile `
        -UserName "MMoralesZuarez" `
        -Email "mmorales@grupoconex.net" `
        -SshAlias "github-work"
}


<#
.SYNOPSIS
Retrieves the current global Git identity.

.DESCRIPTION
Returns the global Git `user.name` and `user.email` values as a PSCustomObject.

.EXAMPLE
Get-GitIdentity
#>
function Get-GitIdentity {
    [PSCustomObject]@{
        UserName = git config --global user.name
        Email    = git config --global user.email
    }
}




