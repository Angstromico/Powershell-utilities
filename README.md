# PowerShell Utilities

A collection of PowerShell scripts to simplify CLI workflows and automate common development tasks.

## Repository Structure

```text
C:\Users\Manuel Morales\Repos\PowerShell\
├── docs/
│   ├── git.md
│   └── windows.md
├── scripts/
│   ├── git.ps1
│   └── windows.ps1
├── README.md
└── .vscode/
    └── settings.json
```

## Documentation

Detailed documentation for each function category can be found in the `docs/` folder:

- [**Git Utilities**](docs/git.md) - Repository initialization, commits, and resets.
- [**Windows Utilities**](docs/windows.md) - System cleanup, icon cache resets, and hardware summaries.

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

## Future Plans

This repository will grow to include:

- **Docker utilities** — Quick stack deployments, container management helpers
- **Dev environment setup** — Automated tool installations and configurations
- **Cloud CLI wrappers** — Simplified commands for AWS, Azure, GCP
- **Build & deploy scripts** — CI/CD automation helpers
- **Any other repetitive tasks** — Converting multi-step CLI operations into single commands

## Requirements

- PowerShell 5.1 or later
- Git (for git.ps1 functions)
