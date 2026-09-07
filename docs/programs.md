# Programs Utilities Documentation

Documentation for functions located in `scripts/programs.ps1`.

---

## Commands

### `vim`

Launches the Vim editor from the Git-for-Windows installation path.

**When to use it:**

- When you want a quick `vim` shortcut from PowerShell without modifying PATH.
- When you need a consistent editor command across Windows environments with Git installed.

**Usage:**

```powershell
. ./scripts/programs.ps1
vim <filename>
```

**Notes:**

- Update the executable path in `scripts/programs.ps1` if your Git installation is in a different location.
- This function forwards any arguments you pass to the Vim executable.

---

### `claude`

Launches the Claude CLI from its local installation path.

**When to use it:**

- When you want to start Claude from PowerShell without adding its installation directory to `PATH`.
- When Claude is installed at `C:\Users\Manuel Morales\.local\bin\claude.exe`.

**Usage:**

```powershell
. ./scripts/programs.ps1
claude
```

**Notes:**

- Update the executable path in `scripts/programs.ps1` if Claude is installed in a different location.
- The function currently launches Claude without forwarding command-line arguments.
