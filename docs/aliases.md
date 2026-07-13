# Alias Configurations Documentation

Documentation for the standalone alias definitions and command overrides located in the `alias/` folder.

---

## Overview

The `alias/` directory contains PowerShell scripts that define custom aliases, shorthand commands, and overrides to replace default Windows PowerShell behaviors with more intuitive or native commands.

To use these aliases in your current session or permanently, see the [Installation and Usage](#installation-and-usage) section.

---

## Interactive Manual

The repository also includes [scripts/manual.ps1](../scripts/manual.ps1), which provides a man-page-style reference for both aliases and functions. It scans the repository automatically, shows a full overview with `help` or `man`, and displays detailed documentation for a specific command such as `help gco` or `man Invoke-GitCheckoutRemote`.

Example usage:

```powershell
. ./scripts/manual.ps1
help
help gco
man Invoke-GitCheckoutRemote
```

This manual is especially useful when you want to browse the repository's commands without reading each script file manually.

---

## Available Aliases

### Native Curl Override (`alias/curl.ps1`)

By default, Windows PowerShell maps the alias `curl` to `Invoke-WebRequest`, which behaves differently from the standard native `curl` utility. This script removes the default alias and re-maps `curl` directly to `curl.exe` (the native executable).

- **Command**: `curl`
- **Maps to**: `curl.exe`
- **Purpose**: Restores standard curl behavior in PowerShell, allowing standard arguments/headers (like `-X`, `-H`, `-d`) to work as they would on Linux/macOS.

---

### Git Shorthands (`alias/git.ps1`)

This script defines shorthand aliases for Git functions defined within the repository's main utility scripts.

#### `gco`

- **Maps to**: `Invoke-GitCheckoutRemote` (defined in `scripts/git.ps1`)
- **Purpose**: Quickly search, select, and check out remote branches interactively.

---

### Lua Alias (`alias/lua.ps1`)

This script creates a `lua` alias that points to `lua55`, which can be useful when the Lua 5.5 executable is installed but you prefer the shorter command name.

- **Command**: `lua`
- **Maps to**: `lua55`
- **Purpose**: Provides a more convenient alias for invoking Lua 5.5 from PowerShell.

---

### Flutter Alias (`alias/flutter.ps1`)

This alias defines `flutter-run` to invoke the locally installed Flutter CLI executable directly from PowerShell.

- **Command**: `flutter-run`
- **Maps to**: `C:\dev\flutter\bin\flutter.bat`
- **Purpose**: Provides a consistent PowerShell alias for running Flutter commands without relying on a global PATH entry.

---

## Installation and Usage

To make these aliases available, dot-source them in your PowerShell profile or current session.

### Sourcing in Current Session

```powershell
. ./alias/curl.ps1
. ./alias/git.ps1
. ./alias/lua.ps1
```

### Adding to your PowerShell Profile (Permanent)

1. Open your PowerShell profile:
   ```powershell
   notepad $PROFILE
   ```
2. Append the following lines pointing to your local repository directory:
   ```powershell
   . "C:\Users\Manuel Morales\Repos\PowerShell\alias\curl.ps1"
   . "C:\Users\Manuel Morales\Repos\PowerShell\alias\git.ps1"
   . "C:\Users\Manuel Morales\Repos\PowerShell\alias\lua.ps1"
   ```
3. Save and restart PowerShell.
