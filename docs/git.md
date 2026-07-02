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

---

### `gpr`

A shortcut to pull the latest changes with rebase and autostash:

- Pulls latest changes from the current branch
- Uses `--rebase` to keep a linear history
- Uses `--autostash` to automatically stash and pop local changes

**Usage:**

```powershell
gpr
```

**Description:**
This command executes `git pull -r --autostash`. It's particularly useful when you have uncommitted changes and want to sync with the remote without manually stashing.

---

### `gps`

A shortcut to push local changes to the remote repository using `force-with-lease`:

- Pushes the current branch to the remote.
- Uses `--force-with-lease` for a safer force push, ensuring you don't overwrite work you haven't seen yet.

**Usage:**

```powershell
gps
```

**Description:**
This command executes `git push --force-with-lease`. It is recommended over a standard `force` push as it verifies that your local representation of the remote branch matches the actual remote branch before proceeding.

---

### `Set-GitProfile`

Configures your global Git identity and updates the local repository remote to use a specific SSH alias if applicable:

- Sets global `git config user.name` and `git config user.email`
- When run inside a repository, rewrites `origin` to use the provided SSH alias for GitHub URLs
- Makes switching between multiple GitHub accounts easier

**Usage:**

```powershell
. ./scripts/git.ps1
Set-GitProfile -UserName "Jane Doe" -Email "jane@work.com" -SshAlias "github-work"
```

**Parameters:**

- `-UserName` (required): Global Git username
- `-Email` (required): Global Git email
- `-SshAlias` (required): SSH host alias to use for the repository origin URL

**Example:**

```powershell
Set-GitProfile -UserName "Angstromico" -Email "manuesteban1990@gmail.com" -SshAlias "github-personal"
```

---

### `Use-GitPersonal`

A convenience wrapper that configures Git for the personal account:

- Sets global Git name to `Angstromico`
- Sets global Git email to `manuesteban1990@gmail.com`
- Sets SSH alias to `github-personal`

**Usage:**

```powershell
. ./scripts/git.ps1
Use-GitPersonal
```

**Description:**
This function calls `Set-GitProfile` with your personal account values.

---

### `Use-GitWork`

A convenience wrapper that configures Git for the work account:

- Sets global Git name to `MMoralesZuarez`
- Sets global Git email to `mmorales@grupoconex.net`
- Sets SSH alias to `github-work`

**Usage:**

```powershell
. ./scripts/git.ps1
Use-GitWork
```

**Description:**
This function calls `Set-GitProfile` with your work account values.

---

### `Get-GitIdentity`

Retrieves the current global Git identity from your local configuration:

- Returns `UserName` and `Email` as a PowerShell object

**Usage:**

```powershell
. ./scripts/git.ps1
Get-GitIdentity
```

**Example:**

```powershell
Get-GitIdentity | Format-List
```

---

### `New-GitHubSSHKey`

Creates a new SSH key for GitHub authentication and loads it into the SSH agent:

- Creates an `ed25519` SSH key pair in the user's `.ssh` folder
- Starts `ssh-agent` if it is not already running
- Adds the private key so GitHub operations can use it immediately
- Prints the public key content so it can be copied to GitHub

**Usage:**

```powershell
. ./scripts/git.ps1
New-GitHubSSHKey -Email "your-email@example.com"
```

**Parameters:**

- `-Email` (required): The email address associated with the key
- `-KeyName` (optional): The filename to use for the key (default: `id_ed25519_github`)

**Examples:**

```powershell
New-GitHubSSHKey -Email "developer@example.com"
New-GitHubSSHKey -Email "developer@example.com" -KeyName "github_work"
```

**Notes:**

- The key is stored in `$HOME/.ssh`
- If a key with the same name already exists, the function will stop and warn you instead of overwriting it
- The public key content is displayed after creation so you can add it to your GitHub account
