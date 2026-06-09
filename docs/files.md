# File Utilities Documentation

Documentation for functions located in `scripts/files.ps1`.

---

## Commands

### `Copy-WithExclude`

Recursively copies files and directories from a source to a destination while excluding items that match specific keywords. If a folder is excluded, all of its contents are automatically skipped.

**When to use it:**
- Copying a project repository while skipping `node_modules`, `.git`, or `dist` folders.
- Backing up a directory while excluding specific file types or temporary folders.
- Any scenario where a standard `Copy-Item -Recurse` is too broad.

**Usage:**
```powershell
. ./scripts/files.ps1
Copy-WithExclude -SourcePath <String> -DestinationPath <String> -Exclude <String[]>
```

**Parameters:**
- `-SourcePath` (optional, default: `.`): The directory to copy from.
- `-DestinationPath` (mandatory): The target directory where files will be copied.
- `-Exclude` (mandatory): An array of strings. Any file or folder containing any of these keywords in its name will be excluded.

**Examples:**

**1. Copy a project skipping `node_modules`:**
```powershell
Copy-WithExclude -DestinationPath "C:\Backups\MyProject" -Exclude "node_modules"
```

**2. Copy from a specific source skipping multiple keywords:**
```powershell
Copy-WithExclude -SourcePath "D:\Work" -DestinationPath "E:\Backup" -Exclude "temp", "bin", "obj"
```

**3. Using current directory and a relative destination:**
```powershell
Copy-WithExclude -DestinationPath "..\BackupCopy" -Exclude ".git", "debug"
```
