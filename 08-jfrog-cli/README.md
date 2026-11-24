# Phase 08 — JFrog CLI

## What and why
JFrog CLI provides a scriptable interface to the JFrog Platform, complementing the UI and native Maven/Docker clients. Enterprises use it on developer laptops and CI agents (GitHub Actions, Jenkins) to automate artifact transfers, searches, build information, scanning, promotion and API operations. Permissions and licensing still apply.

## Command overview
| Operation | Command |
|---|---|
| Configure connection | `jf config add` |
| Connectivity | `jf rt ping` |
| Upload | `jf rt upload` |
| Download | `jf rt download` |
| Search | `jf rt search` |
| Publish build info | `jf rt build-publish` |
| Scan build | `jf rt build-scan` |
| Promote build | `jf rt build-promote` |
| REST API | `jf rt curl` |

## Step 1 — Check installation (pending)
Run `jf --version` in existing PowerShell session. If installed, reuse it; otherwise install CLI. No new project, repository or token is required at this stage.

## Interview note
Why use JFrog CLI instead of the UI? Repeatable, scriptable operations for CI/CD and administration, including bulk artifact transfers and build traceability. Native package clients remain useful for package-specific operations.

## Step 2 — Windows installation (pending)
The user ran `jf --version` and received CommandNotFoundException: jf is not recognized. CLI is either absent or not on PATH. Try `winget install --id JFrog.CLI --exact`, reopen PowerShell and verify `jf --version`. If the package is unavailable, consult official installation documentation at https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli. New PowerShell sessions may require restoring session-specific JFROG_USER and JFROG_TOKEN variables. Reuse existing valid credentials. Git manages source code, Maven builds Java, Docker manages containers, JFrog CLI automates artifact operations, and kubectl manages Kubernetes.

## Installation fallback — official binary
Winget returned `No package found matching input criteria`; jf remained unrecognized. Use the official Windows AMD64 executable, pinned for reproducibility (installation not yet verified).
```powershell
$jfrogDir = "$env:USERPROFILE\jfrog-cli"
New-Item -ItemType Directory -Force -Path $jfrogDir
Invoke-WebRequest -Uri "https://releases.jfrog.io/artifactory/jfrog-cli/v2-jf/2.77.0/jfrog-cli-windows-amd64/jf.exe" -OutFile "$jfrogDir\jf.exe"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$userPath;$jfrogDir", "User")
$env:Path += ";$jfrogDir"
jf --version
```
The directory stores the executable; user PATH persists across sessions, while env:Path updates the current process. No administrator privileges normally required. Verify download integrity against official release checksums where available. Installation verification pending.
