# Phase 09 — Build Info and Artifact Traceability

Build Info associates published artifacts with build metadata, including build identity, checksums, dependencies, source revision and environment information when collected. CI systems can publish artifacts and metadata to JFrog for traceability, security scanning and promotion. Metadata collection and publication are separate operations. Do not collect or publish secrets.

## Step 1 — Associate artifact with build (pending)
```powershell
jf rt upload "release-notes.txt" "generic-dev-local/releases/1.0.1/" --flat=true --build-name="enterprise-demo-build" --build-number="1" --server-id=jfrog-trial
```
Reuse the existing sample file, repository, user and CLI alias. Build name and number are chosen for this exercise; production CI normally generates unique build numbers. New destination avoids overwriting the earlier upload. The directory version is a demonstration path, not evidence of a new application build. CLI collects associated artifact metadata locally; publication follows separately. Upload result pending.

## Interview question
What is the difference between an artifact and Build Info? An artifact is a stored file or package; Build Info describes its associated build and collected metadata, supporting traceability and release governance. Uploading a file alone does not automatically capture full source or dependency history.

## Step 1 verification — actual evidence
On 2026-11-24 at 15:29:44, CLI reported successful upload of `generic-dev-local/releases/1.0.1/release-notes.txt` with build name enterprise-demo-build and build number 1; success 1, failure 0. The subsequent standalone execution of `--build-name` and `--build-number` caused PowerShell MissingExpressionAfterOperator. These are flags, not independent commands. This parser error does not undo the successful upload. No repeat upload needed.

## Step 2 — Publish Build Info (pending)
```powershell
jf rt build-publish "enterprise-demo-build" "1" --server-id=jfrog-trial
```
Publish locally collected metadata using the same build identity and server alias. Enterprise pipelines may collect metadata across multiple artifact operations before publishing a common build record. Publication supports traceability and subsequent scanning and promotion. Build publication may require separate build permissions; investigate any authorization failure before changing permissions. Actual publication pending.

## Step 2 result — Build Info authorization failure
On 2026-11-24 at 15:30:34, build-publish for enterprise-demo-build/1 returned HTTP 403: User is not authorized to access build info. Artifact upload succeeded earlier; build authorization is separate. Standalone flags again caused a PowerShell parser error and are not commands.

## Step 3 — Build permissions (pending)
As administrator, create permission target build-info-deploy (chosen name), select Builds and scope to enterprise-demo-build, using an exact include pattern if supported. Grant existing maven-deployer Read and Deploy build permissions; leave Delete, Annotate and Manage disabled. UI labels may vary. Do not grant administrator access or rotate tokens merely for this error. Retry the existing build-publish command after permission configuration; no repeat upload needed unless local metadata is missing. HTTP 401 generally indicates authentication failure; 403 indicates access forbidden. This exercise demonstrates separation of artifact and build permissions and least privilege. Resolution pending.

## Current exercise — collect Build Info
Upload a new generic release file with build metadata:
```powershell
"Application release version 1.0.1" | Set-Content release-notes-1.0.1.txt
jf rt upload "release-notes-1.0.1.txt" "generic-dev-local/releases/1.0.1/" --flat=true --build-name="enterprise-demo-build" --build-number="1" --server-id=jfrog-trial
```
Build name and number are chosen identifiers; CI normally generates unique numbers. Upload collects metadata locally; publication is separate and requires build permissions. Build Info supports traceability, auditing, security scanning and promotion. Avoid collecting secrets. Upload verification pending.

## Step 1 — Actual upload verification (2026-11-24)
User supplied CLI output at 17:35:49 showing `generic-dev-local/releases/1.0.1/release-notes-1.0.1.txt` uploaded with status success, success count 1, failure count 0. Command included build name enterprise-demo-build and number 1, collecting artifact metadata locally. Publication is not yet verified.

## Step 2 — Publish Build Info (pending)
```powershell
jf rt build-publish "enterprise-demo-build" "1" --server-id=jfrog-trial
```
Reuse the exact build name and number from upload. Artifact upload stores the file; build-publish sends collected build metadata to Artifactory. Build-specific permissions are distinct from repository deploy permissions. If HTTP 403 occurs, investigate build permission targets for the existing user before modifying access. Actual publication result pending.

## Step 2 actual result — Build Info authorization failure
On 2026-11-24 at 17:37:07, build-publish for enterprise-demo-build/1 returned HTTP 403, `User is not authorized to access build info` (trace ID 51f42efec94f3aaf). Artifact upload had already succeeded. Repository permissions and build permissions are separate.

## Step 3 — Build permission remediation (pending)
As administrator, navigate to Administration > User Management > Permissions and create enterprise-build-deploy (chosen name). Under Builds, scope access to enterprise-demo-build using the build selection or include pattern, and grant existing maven-deployer Read and Deploy permissions. Leave Delete/Overwrite, Annotate and Manage disabled where applicable. UI labels may vary. If the unpublished build cannot be selected, use a build include pattern where supported rather than broadening access unnecessarily. Reuse existing credentials subject to token scope. Retry build-publish after permission configuration; do not re-upload unless local build metadata is unavailable. Enterprise rationale: least privilege and separation of artifact publishing, build publishing, release management and administration. Remediation not yet verified.

### Build permission UI verification
User screenshot shows Add Builds > By Pattern, include patterns enterprise-demo-build and **, and preview zero builds. Remove ** to avoid granting access to all builds; keep only enterprise-demo-build, leave Include All Builds unchecked and exclusions empty. Zero preview is consistent with the failed initial publication; pattern-based permissions can cover future builds. Click OK, assign existing maven-deployer Read and Deploy build permissions and save. Effective permission verification pending.

## Step 3 verification and Step 4 retry
User confirmed saving the scoped build permission target. Effective authorization remains to be verified. Retry `jf rt build-publish "enterprise-demo-build" "1" --server-id=jfrog-trial` using the existing locally collected metadata and credentials. No artifact re-upload is needed unless local metadata is missing. HTTP 401 generally indicates authentication problems; HTTP 403 generally indicates authorization problems. Publication result pending.

## Step 4 actual result — authorization remains unresolved
On 2026-11-24 at 17:40:43, retry returned HTTP 403 `User is not authorized to access build info` (trace ID 08434c9a2ce30406). The scoped permission change did not resolve the error. Inspect saved enterprise-build-deploy Users settings for effective Build Read/Deploy assignment, then verify pattern matching and token scope if necessary. Do not broaden permissions or rotate credentials before isolating the cause. Publication remains pending.

## Build permission diagnostic — user assignment verified
Screenshot confirms maven-deployer has Build Read and Deploy enabled, with other build privileges disabled. Next diagnostic: test scoped include pattern `enterprise-demo-build/**` instead of the exact name to check underlying build path matching. Keep unrestricted wildcard access disabled. Retry publication. Pattern hypothesis is not yet verified; token scope remains another possible cause.

## Build publication — verified resolution (2026-11-24)
After retaining `enterprise-demo-build` and adding `enterprise-demo-build/**` as scoped include patterns, the user retried publication. At 17:49:16 CLI reported `Build info successfully deployed.` The pattern change resolved the observed 403 without broad wildcard permissions, token rotation, administrator credentials in CLI or artifact re-upload. The exact internal matching mechanism was not independently inspected. Build: enterprise-demo-build/1. Returned UI URL: https://trialgccoro.jfrog.io/ui/builds/enterprise-demo-build/1/1795522753581/published?buildRepo=artifactory-build-info

## Step 5 — Dashboard verification (pending)
Open the returned UI URL or navigate to Platform > Artifactory > Builds > enterprise-demo-build > 1. Inspect published modules and release-notes-1.0.1.txt artifact association. Dependencies, environment and Git information may be empty because this generic upload did not explicitly collect them. The URL identifies artifactory-build-info, the default Build Info repository; actual release content resides separately in generic-dev-local. Dashboard inspection pending.
