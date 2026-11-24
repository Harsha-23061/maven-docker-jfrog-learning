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
