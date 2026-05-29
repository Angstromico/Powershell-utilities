# PowerShell Utilities

A collection of PowerShell scripts to simplify CLI workflows and automate common development tasks.

## Repository Structure

```text
C:\Users\Manuel Morales\Repos\PowerShell\
├── scripts/
│   ├── git.ps1
│   └── windows.ps1
├── README.md
└── .vscode/
    └── settings.json
```

## Current Commands

### Git

**File:** `scripts/git.ps1`

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
. ./scripts/git.ps1
New-GitFirstCommit -RepoUrl "https://github.com/username/repo.git"
```

**Parameters:**
- `-RepoUrl` (required): The remote repository URL
- `-CommitMessage` (optional): Custom commit message (default: `"first commit"`)

**Example:**
```powershell
New-GitFirstCommit -RepoUrl "https://github.com/john/myproject.git" -CommitMessage "Initial setup"
```

### Windows

**File:** `scripts/windows.ps1`

#### `Reset-IconCache`

Resets the Windows icon cache when icons are appearing incorrectly, broken, or not updating. This process involves:
- Stopping the Windows Explorer process
- Deleting the `IconCache.db` and Explorer icon cache databases
- Restarting Windows Explorer

**When to use it:**
- Desktop icons are blank or showing generic icons
- Custom folder icons aren't updating
- File association icons are incorrect

**Usage:**
```powershell
. ./scripts/windows.ps1
Reset-IconCache
```

**Parameters:**
- `-Verbose` (optional): Show detailed steps of the operation

**Example:**
```powershell
Reset-IconCache -Verbose
```

#### `Get-HardwareSummary`

Provides a concise summary of the computer's hardware, including OS version, CPU model, total RAM, GPU, and C: drive space.

**Usage:**
```powershell
. ./scripts/windows.ps1
Get-HardwareSummary
```

**Output Example:**
```text
OS     : Microsoft Windows 11 Pro
CPU    : 13th Gen Intel(R) Core(TM) i9-13900K
RAM    : 64 GB
GPU    : NVIDIA GeForce RTX 4090
Disk_C : 450.23 GB free of 953.12 GB
```

#### `Clear-SystemJunk`

Safely removes temporary files and Windows Update installer caches to free up disk space. 

**Directories Cleaned:**
- User Temporary files (`$env:TEMP`)
- Windows System Temporary files (`C:\Windows\Temp`)
- Windows Prefetch data (`C:\Windows\Prefetch`)
- Windows Update Download cache (`C:\Windows\SoftwareDistribution\Download`)

> **Note:** This function requires **Administrative privileges** to access system directories.

**Usage:**
```powershell
. ./scripts/windows.ps1
Clear-SystemJunk
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
   . ./scripts/git.ps1
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
   . "C:\Users\Manuel Morales\Repos\PowerShell\scripts\git.ps1"
   . "C:\Users\Manuel Morales\Repos\PowerShell\scripts\windows.ps1"
   ```

3. Save and **restart PowerShell**

Now all functions from both `git.ps1` and `windows.ps1` will work from any folder without sourcing.

## Requirements

- PowerShell 5.1 or later
- Git (for git.ps1 functions)
