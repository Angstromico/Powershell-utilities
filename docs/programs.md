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
