# Flutter Utilities Documentation

Documentation for Flutter-related aliases and functions located in `alias/flutter.ps1` and `scripts/flutter-run.ps1`.

---

## Overview

This repository provides two Flutter helpers:

| Command | Kind | File |
|---|---|---|
| `flutter-run` | Alias | `alias/flutter.ps1` |
| `flutter-refresh` | Function | `scripts/flutter-run.ps1` |

---

## Commands

### `flutter-run`

Defines a PowerShell alias that maps `flutter-run` directly to the locally installed Flutter CLI executable.

**When to use it:**

- When you want a consistent `flutter` command from PowerShell without relying on a global PATH entry.
- When your Flutter SDK is installed at a custom location (e.g., `C:\dev\flutter`).

**Configuration:**

The alias is defined in `alias/flutter.ps1`:

```powershell
Set-Alias flutter-run C:\dev\flutter\bin\flutter.bat
```

If your Flutter SDK resides elsewhere, update the path in that file.

**Usage:**

```powershell
. ./alias/flutter.ps1
flutter-run <flutter-arguments>
```

**Examples:**

```powershell
# Launch the app
flutter-run run

# Analyze the project
flutter-run analyze

# Run tests
flutter-run test
```

---

### `flutter-refresh`

Performs a full Flutter project refresh: cleans the build cache, restores dependencies, and runs the application with verbose logging.

**When to use it:**

- When your Flutter project has stale build artifacts or dependency issues.
- When you want a single command to clean, restore, and relaunch your app.
- When you need verbose output to diagnose build or runtime problems.

**Source (`scripts/flutter-run.ps1`):**

```powershell
function flutter-refresh {
    # Clean project
    flutter clean

    # Restore dependencies
    flutter pub get

    # Run app with verbose logs
    flutter-run run --verbose
}
```

**What it does:**

1. **`flutter clean`** — Removes the `build/` directory and other generated artifacts.
2. **`flutter pub get`** — Downloads and caches the project's Dart dependencies.
3. **`flutter-run run --verbose`** — Builds and launches the app with detailed logging to help diagnose issues.

**Usage:**

```powershell
. ./scripts/flutter-run.ps1
flutter-refresh
```

> **Note:** Because `flutter-refresh` internally uses the `flutter-run` alias, make sure the alias from `alias/flutter.ps1` is loaded in your session or that `flutter` is available on your PATH.

**Example workflow:**

```powershell
# Source both the alias and the function
. ./alias/flutter.ps1
. ./scripts/flutter-run.ps1

# Refresh the project
flutter-refresh
```

---

## Interactive Manual

The repository also includes [scripts/manual.ps1](../scripts/manual.ps1), which automatically discovers and documents both the `flutter-run` alias and the `flutter-refresh` function:

```powershell
. ./scripts/manual.ps1
help
man flutter-run
man flutter-refresh
```

---

## Installation

### Quick Use (One-Time)

```powershell
. ./alias/flutter.ps1
. ./scripts/flutter-run.ps1
flutter-refresh
```

### Permanent Setup

Add the following lines to your PowerShell profile (`notepad $PROFILE`):

```powershell
. "C:\Users\Manuel Morales\Repos\PowerShell\alias\flutter.ps1"
. "C:\Users\Manuel Morales\Repos\PowerShell\scripts\flutter-run.ps1"
```

Save and restart PowerShell.
