# Windows Utilities Documentation

Documentation for functions located in `scripts/windows.ps1`.

---

## Commands

### `Reset-IconCache`

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

---

### `Get-HardwareSummary`

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

---

### `Clear-SystemJunk`

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

---

### `Stop-LocalServer`

Terminates the process listening on a specified local port. Useful when a development server is already running and you need to free up the port.

**When to use it:**
- Port already in use errors when starting a local server
- Need to quickly kill a running development server
- Freeing up a port without manually searching for the process

**Usage:**
```powershell
. ./scripts/windows.ps1
Stop-LocalServer -Port <port_number>
```

**Parameters:**
- `-Port` (required): The port number to check (1-65535)

**Examples:**
```powershell
# Kill process on port 5000
Stop-LocalServer -Port 5000

# Kill process on port 3000 (short form)
Stop-LocalServer 3000
```

**Output:**
```text
Found 'node' (PID: 12345) listening on port 5000
Successfully terminated process on port 5000.
```
