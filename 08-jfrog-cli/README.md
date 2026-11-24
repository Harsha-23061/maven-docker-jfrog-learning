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

## Installation verification
User confirmed completion of manual CLI installation; exact version output was not supplied.

## Step 3 — Configure server connection (pending)
Run `jf config add jfrog-trial` interactively. Use platform URL `https://trialgccoro.jfrog.io` and existing maven-deployer access token; accept default service URLs if prompted. Server ID is a local alias for connection configuration, allowing scripts to select instances without repeating connection details. Enterprises may use separate aliases for dev, QA and production instances where applicable. CLI configuration normally resides under the user's `.jfrog` directory; never commit it or credentials. No new token or repository required. Connectivity verification follows configuration.

## Server ID clarification
`jfrog-trial` is a user-chosen local configuration alias, not a value retrieved from Artifactory. In `jf config add jfrog-trial`, jf is the executable, config is the configuration command, add creates a configuration, and jfrog-trial names it. Alternatives include my-artifactory and company-jfrog. Platform URL comes from the existing instance; username and token come from previously configured authentication. Use `jf rt ping --server-id=jfrog-trial` to select the connection explicitly. Separate instances may have aliases such as jfrog-dev, jfrog-qa and jfrog-prod; aliases do not create remote resources. User output confirms CLI 2.77.0 is running and reports a newer 2.133.0 version available. Configuration is still in progress.

## Interactive service URL discovery
After entering the platform URL, CLI 2.77.0 displayed automatically derived URLs for Artifactory (/artifactory/), Distribution (/distribution/), Xray (/xray/), Mission Control (/mc/) and Pipelines (/pipelines/). These correspond respectively to artifact management, release distribution, security scanning, centralized instance management and CI/CD automation. Select Save and continue to accept defaults. Derived URLs do not establish service availability or license entitlement. Authentication and connectivity verification remain pending.

## Reference token warning
CLI reported that it could not extract the access token payload, suggesting a reference token rather than a JWT. This warning alone does not establish authentication failure. JWTs contain encoded claims; reference tokens are opaque and cannot be decoded locally to infer a username. At the optional username prompt enter the existing `maven-deployer` username, useful for package managers requiring basic authentication. Reuse the existing token; verify connectivity after saving. Never record token values in Git.

## Step 4 — Connectivity verification (pending)
User entered the existing username and returned to PowerShell without a reported configuration error. Run `jf rt ping --server-id=jfrog-trial`. The rt group targets Artifactory, ping checks connectivity using the saved configuration, and server-id selects our custom alias. The underlying Artifactory endpoint is GET /artifactory/api/system/ping; expected response OK. CI/CD can use this as a connectivity preflight. A successful ping does not establish repository authorization or prove token validity where anonymous ping is allowed; verify repository access separately. Actual ping result pending.

## Connectivity troubleshooting — HTTP 401
Actual CLI ping returned HTTP 401, `Props Authentication Token not found`. Server responded but authentication failed; repository authorization remains untested. Possible causes include incorrect or expired token or saved configuration issues. Check existing PowerShell username and token presence without printing token. Independently test the existing credentials against `/artifactory/api/storage/libs-release-local` using Basic authentication; compare HTTP status with CLI ping. Avoid rotating credentials or changing permissions before isolating the issue. Resolution pending.

## Authentication diagnostic result
User reported HTTP 200 from the independent Basic authentication test. This supports validity of the existing credentials and repository read access, narrowing the issue to CLI configuration or authentication method. Reconfigure the existing alias using `jf config edit jfrog-trial --url="https://trialgccoro.jfrog.io" --user="$env:JFROG_USER" --access-token="$env:JFROG_TOKEN" --interactive=false` and retry `jf rt ping --server-id=jfrog-trial`. This eliminates manual token entry errors; if 401 persists, investigate reference-token authentication method compatibility. Avoid logging credentials; command-line arguments can be visible to local process inspection. CLI resolution pending.

## CLI authentication resolution
User confirmed completion after editing the existing configuration with verified environment credentials and retrying ping. Exact ping output was not supplied. No new token or permission changes reported.

## Step 6 — Artifact search (pending)
```powershell
jf rt search "libs-release-local/**/*.jar" --server-id=jfrog-trial
```
Search is read-only. `jf rt search` is standard CLI syntax, libs-release-local is our existing Maven repository, the wildcard pattern selects nested JAR files, and jfrog-trial is our local alias. Expected JSON includes matching paths and artifact metadata such as size, timestamps and checksums. Enterprise use cases include release discovery, deployment validation, inventory and retention reviews. Search output can be consumed by scripts and CI/CD. Actual result pending.

## Step 6 verification
User confirmed artifact search completion; exact JSON output not supplied.

## Step 7 — Download existing artifact (pending)
```powershell
jf rt download "libs-release-local/com/example/maven-docker-artifactory/1.0.7/maven-docker-artifactory-1.0.7.jar" "./jfrog-downloads/" --flat=true --server-id=jfrog-trial
Get-ChildItem .\jfrog-downloads\
```
Source path is derived from existing Maven coordinates and repository. Destination is a chosen local folder. Flat mode avoids recreating the repository hierarchy; server-id selects our saved alias. Expected JAR is maven-docker-artifactory-1.0.7.jar. Enterprise principle: build once, deploy many; promote the same verified artifact across DEV, QA and PROD rather than rebuilding per environment, preserving checksums. Download verification pending.

## Alternative — download via Artifactory UI
Navigate to Application > Artifactory > Artifacts > libs-release-local > com > example > maven-docker-artifactory > 1.0.7. Select maven-docker-artifactory-1.0.7.jar and use Download in the details panel or actions menu, depending on UI version. Browser download destination follows browser settings. UI is useful for manual inspection and occasional downloads; CLI supports repeatable, wildcard-based and automated transfers in Jenkins and GitHub Actions. Both retrieve the same stored artifact. User asked for the UI alternative; actual download verification remains pending.

## Step 7 verification
User confirmed artifact download completion; exact output and method were not supplied.

## Step 8 — Generic artifact upload preparation (pending)
Create a local Generic repository named `generic-dev-local` in Administration > Repositories > Local. The repository key is chosen by us: package type, environment, repository type. Generic repositories store arbitrary files such as ZIP archives, binaries, deployment scripts, reports and non-secret configuration templates without Maven-specific coordinates or metadata. Maven deploy remains appropriate for Maven packages; CLI upload is useful for generic files. Use a separate repository to avoid mixing package types. Next grant least-privilege read/deploy access to the existing deployment user before uploading a test file. Repository creation and upload not yet verified.

## Step 8 verification
User confirmed creation of generic-dev-local.

## Step 9 — Generic repository permissions (pending)
Create permission target generic-artifact-deploy (chosen name) for generic-dev-local and existing maven-deployer user. Grant Read and Deploy/Cache only; leave Delete/Overwrite, Annotate and Manage disabled. Reuse existing CLI configuration and token subject to token scope. Production may use separate service identities to isolate pipelines. Permission creation and upload verification pending.

## Step 9 verification
User confirmed Generic repository permission configuration; effective access will be tested by upload.

## Step 10 — Generic artifact upload (pending)
```powershell
"Application release version 1.0.0" | Set-Content -Path release-notes.txt
jf rt upload "release-notes.txt" "generic-dev-local/releases/1.0.0/" --flat=true --server-id=jfrog-trial
```
The source file and target subpath are chosen by us; generic-dev-local is the existing repository and jfrog-trial is the saved CLI alias. Flat mode avoids preserving source directory hierarchy. Expected summary: success 1, failure 0. Verify in Application > Artifactory > Artifacts > generic-dev-local > releases > 1.0.0 > release-notes.txt. Artifactory creates the necessary path during upload. Enterprise pipelines publish release notes, deployment packages and test reports; later Build Info can associate artifacts with builds and source metadata. Actual upload and UI verification pending.

## Phase completion
User confirmed generic artifact upload and UI verification. Phase 08 complete based on user confirmations; exact upload output not supplied. Continue to Build Info.

## Actual upload evidence
On 2026-11-24 at 15:27, user supplied CLI output confirming upload to `generic-dev-local/releases/1.0.0/release-notes.txt`: status success, success 1, failure 0. The command did not include build-name or build-number, so this verifies Phase 08 only. Phase 09 artifact association remains pending.

## Phase completion
User confirmed generic artifact upload and UI verification. Phase 08 complete based on user confirmation; exact upload output not supplied.
