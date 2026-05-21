
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
