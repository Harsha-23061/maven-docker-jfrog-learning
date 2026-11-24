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
