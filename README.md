# PowerShell Utilities

A collection of PowerShell scripts to simplify CLI workflows and automate common development tasks.

## Current Commands

### Git

**File:** `git.ps1`

#### `New-GitFirstCommit`

Automates the initial setup of a new Git repository in one command:
- Initializes a new Git repository
- Stages all files
- Creates the first commit
- Renames branch to `main`
- Adds remote origin
- Pushes to remote

**Usage:**
> **Note:** You must dot-source the script first (the `.` at the beginning is required):

```powershell
. ./git.ps1
New-GitFirstCommit -RepoUrl "https://github.com/username/repo.git"
```

**Parameters:**
- `-RepoUrl` (required): The remote repository URL
- `-CommitMessage` (optional): Custom commit message (default: `"first commit"`)

**Example:**
```powershell
New-GitFirstCommit -RepoUrl "https://github.com/john/myproject.git" -CommitMessage "Initial setup"
```

## Future Plans

This repository will grow to include:

- **Docker utilities** — Quick stack deployments, container management helpers
- **Dev environment setup** — Automated tool installations and configurations
- **Cloud CLI wrappers** — Simplified commands for AWS, Azure, GCP
- **Build & deploy scripts** — CI/CD automation helpers
- **Any other repetitive tasks** — Converting multi-step CLI operations into single commands

## Installation

### Quick Use (One-Time)

1. Clone this repository
2. Source the script you need:
   ```powershell
   . ./git.ps1
   ```
3. Run the functions directly in your PowerShell session

### Permanent Setup (Recommended)

To make these functions available in **every PowerShell session** from any directory:

1. Open your PowerShell profile:
   ```powershell
   notepad $PROFILE
   ```
   If the file doesn't exist, create it first:
   ```powershell
   if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }
   ```

2. Add this line to the profile file:
   ```powershell
   . "C:\Users\Manuel Morales\Repos\PowerShell\git.ps1"
   ```

3. Save and **restart PowerShell**

Now `New-GitFirstCommit` will work from any folder without sourcing.

**For future scripts**, just add more lines to your profile:
```powershell
. "C:\Users\Manuel Morales\Repos\PowerShell\docker.ps1"
. "C:\Users\Manuel Morales\Repos\PowerShell\aws.ps1"
```

## Requirements

- PowerShell 5.1 or later
- Git (for git.ps1 functions)
