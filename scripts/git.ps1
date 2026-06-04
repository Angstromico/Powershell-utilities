
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

