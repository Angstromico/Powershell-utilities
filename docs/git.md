# Git Utilities Documentation

Documentation for functions located in `scripts/git.ps1`.

---

## Commands

> **Note:** Common aliases for these commands are also defined in the `alias/` folder for easier session management.

### `New-GitFirstCommit`

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

---

### `Invoke-GitCommitPush`

Automates the commit and push workflow with a colorful interface:
- Stages all changes
- Creates a commit with conventional commit format (`type: message`)
- Pulls latest changes with rebase to prevent conflicts
- Pushes to the current branch

**Usage:**
> **Note:** You must dot-source the script first (the `.` at the beginning is required):

```powershell
. ./scripts/git.ps1
Invoke-GitCommitPush -Type "feat" -Message "Add user authentication"
```

**Parameters:**
- `-Type` (required): Commit type following conventional commits. Valid values: `feat`, `bugfix`, `chore`, `docs`, `refactor`
- `-Message` (required): The commit message describing the change

**Examples:**
```powershell
Invoke-GitCommitPush -Type "feat" -Message "Add user authentication"
Invoke-GitCommitPush -Type "bugfix" -Message "Fix login redirect issue"
Invoke-GitCommitPush -Type "docs" -Message "Update README installation steps"
```

---

### `Invoke-GitHardReset`

Forces the local repository to match the state of a remote branch:
- Fetches the latest updates from the remote
- Performs a hard reset to the specified remote branch
- **Warning:** This will discard all uncommitted local changes

**Usage:**
```powershell
. ./scripts/git.ps1
Invoke-GitHardReset -Branch "main"
```

**Parameters:**
- `-Branch` (optional): The remote branch to reset to (default: `"main"`)
- `-Remote` (optional): The remote name (default: `"origin"`)

**Examples:**
```powershell
Invoke-GitHardReset                       # Resets current branch to origin/main
Invoke-GitHardReset -Branch "develop"     # Resets current branch to origin/develop
Invoke-GitHardReset -Branch "feat-ui" -Remote "upstream"
```

---

### `Invoke-GitRebase`

Rebases a base branch (usually `main`) into the current branch:
- Fetches the latest updates from the remote
- Rebases the specified remote base branch into the current branch
- Useful for keeping your feature branch up to date with the main branch

**Usage:**
```powershell
. ./scripts/git.ps1
Invoke-GitRebase -BaseBranch "main"
```

**Parameters:**
- `-BaseBranch` (optional): The remote branch to rebase onto (default: `"main"`)
- `-Remote` (optional): The remote name (default: `"origin"`)

**Examples:**
```powershell
Invoke-GitRebase                       # Rebases current branch onto origin/main
Invoke-GitRebase -BaseBranch "develop" # Rebases current branch onto origin/develop
Invoke-GitRebase -BaseBranch "main" -Remote "upstream"
```

---

### `Invoke-GitCheckoutRemote` (Alias: `gco`)

Safely checkouts a remote branch, creating it locally if it doesn't exist or pulling updates if it does:
- Fetches the latest branches from the remote
- Verifies if the branch exists on the remote
- If local branch exists: switches to it and pulls updates
- If local branch doesn't exist: creates it and tracks the remote counterpart

**Usage:**
```powershell
. ./scripts/git.ps1
Invoke-GitCheckoutRemote -Branch "feature-abc"
# Or using the alias:
gco -Branch "feature-abc"
```

**Parameters:**
- `-Branch` (required): The name of the branch to checkout
- `-Remote` (optional): The remote name (default: `"origin"`)

**Examples:**
```powershell
Invoke-GitCheckoutRemote -Branch "main"
gco -Branch "develop"
gco -Branch "feat-ui" -Remote "upstream"
```

