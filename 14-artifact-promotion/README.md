# Phase 14 — Enterprise Artifact Promotion

## Objectives and architecture
Build once, deploy many: promote the same versioned binary through DEV, QA and PROD without rebuilding. Promotion can copy or move an existing artifact subject to permissions and approval. Verify integrity using checksums. Repository metadata is not independent approval. Architecture: GitHub source > CI build > DEV repository > validation/security checks > QA repository > release approval > PROD repository.

| Repository | Purpose | Status |
|---|---|---|
| generic-dev-local | Development artifacts | Existing |
| generic-qa-local | QA artifacts | Planned |
| generic-prod-local | Production artifacts | Planned |

Names are project-defined. Reuse generic-dev-local/releases/1.0.0/release-notes.txt for the initial learning exercise; later apply concepts to Maven and Docker. Phase 12 native build-level security enforcement remains unresolved; this exercise is not production release approval.

## Step 1 — Create QA repository
Administration > Repositories > Local > Create Repository. Select Generic, repository key generic-qa-local, optional description QA artifacts validated for release testing. Leave remaining settings at defaults and create. Creation pending user confirmation. No new token or permission changes yet.

## Interview question
Why build once and promote rather than rebuild per environment? Reusing the same binary reduces variation between tested and released artifacts, supports traceability, and enables checksum-based integrity verification. Environment-specific configuration should be supplied separately where appropriate.

## Step 1 correction — Reuse existing repositories
User screenshot confirms existing local DEV and QA repositories and a truncated generic-prod-l... local repository consistent with the planned PROD name. Skip creation; these were provisioned earlier. No duplicate repositories needed.

## Step 2 — Inspect existing permissions
Administration > User Management > Permissions > generic-artifact-deploy. Inspect repository scope and existing maven-deployer permissions before any change. QA destination access must be verified for the planned copy operation. Do not modify permissions yet. Result pending.

## Step 2 result — Existing permission scope verified
User screenshot confirms generic-artifact-deploy selects only generic-dev-local. Preserve this target unchanged. Other permission targets were not audited, so effective QA/PROD access is not established.

## Step 3 — Create separate QA promotion permission
Create generic-qa-promote scoped only to generic-qa-local, assign maven-deployer Read, Deploy/Cache and Annotate; leave Delete/Overwrite and Manage disabled. Read supports verification, Deploy/Cache supports copying into QA, Annotate supports lifecycle metadata updates. Do not grant PROD access at this step. Separate targets permit independent environment control; reuse the deployment identity for this lab only, with separate promotion identities and approvals preferable in production. Creation pending confirmation.

## Step 3 result
User confirmed creation of generic-qa-promote as instructed. Effective access will be tested by the copy operation.

## Step 4 — Copy DEV artifact to QA
```powershell
jf rt cp "generic-dev-local/releases/1.0.0/release-notes.txt" "generic-qa-local/releases/1.0.0/" --flat=true --server-id=jfrog-trial
```
Standard CLI cp performs server-side copy, preserving DEV source. Explicit destination folder and flat=true avoid recreating source hierarchy. Reuse configured deployment identity and server alias. Source Read and destination Deploy/Cache are required. Expected success=1, failure=0; actual result pending. Verify destination and checksums subsequently. Copy rather than move preserves source for traceability and independent testing. This is simulated promotion, not QA validation or security approval.

## Step 4 result
User confirmed completion of DEV-to-QA copy; raw CLI output not supplied. Destination and integrity verification pending.

## Step 5 — SHA-256 integrity verification
```powershell
$dev = jf rt curl -XGET "/api/storage/generic-dev-local/releases/1.0.0/release-notes.txt" --server-id=jfrog-trial | ConvertFrom-Json
$qa = jf rt curl -XGET "/api/storage/generic-qa-local/releases/1.0.0/release-notes.txt" --server-id=jfrog-trial | ConvertFrom-Json
Write-Host "DEV SHA256: $($dev.checksums.sha256)"
Write-Host "QA  SHA256: $($qa.checksums.sha256)"
if ($dev.checksums.sha256 -and $qa.checksums.sha256 -and ($dev.checksums.sha256 -eq $qa.checksums.sha256)) {
    Write-Host "PASS: Artifact integrity verified" -ForegroundColor Green
} else {
    throw "FAIL: Artifact checksum missing or mismatched"
}
```
Storage API returns file metadata including checksums. SHA-256 produces a 256-bit digest represented by 64 hexadecimal characters. Compare both nonempty digests to avoid passing on missing values. Expected matching checksums; actual result pending. Production automation should additionally validate API status and response schema. Matching checksums support build-once-deploy-many and content integrity but do not establish security clearance or release approval.

## Step 5 result — Verified DEV-to-QA integrity
User supplied Storage API results for both repositories. Both SHA-256 values were `78fd4f447e2f32dad67eda0986145d0f9165836decd3e6ecf482428cf8c887d1`. Script printed PASS: Artifact integrity verified. Both source and destination exist and content hashes match; no rebuild was performed. This verifies repository-level promotion integrity, not QA or security approval.

## Step 6 — Verify copied metadata
```powershell
jf rt curl -XGET "/api/storage/generic-qa-local/releases/1.0.0/release-notes.txt?properties" --server-id=jfrog-trial
```
Inspect whether the five source properties were preserved: application=enterprise-demo, environment=dev, release.status=testing, release.version=1.0.0, team=platform-engineering. These are expected values, not yet verified for QA. Repository location and custom lifecycle metadata are independent; verify before updating. Actual result pending.

## Step 6 result — Metadata preservation verified
User supplied QA Storage API JSON confirming all five properties copied unchanged: application=enterprise-demo, environment=dev, release.status=testing, release.version=1.0.0, team=platform-engineering. Repository location does not automatically change custom lifecycle metadata.

## Step 7 — Update QA lifecycle metadata
```powershell
jf rt sp "generic-qa-local/releases/1.0.0/release-notes.txt" "environment=qa;release.status=qa-pending" --server-id=jfrog-trial
```
Semicolon separates property assignments in the CLI argument. Update only QA metadata; DEV should retain environment=dev and release.status=testing. Other three properties should remain unchanged. The custom status qa-pending is chosen for this lab to represent awaiting QA validation, not a built-in JFrog state. Planned lifecycle: DEV testing > QA qa-pending > QA validated after tests > PROD released after required approvals and promotion. Actual mutation and isolation verification pending. Phase 12 security enforcement limitation remains unresolved.

## Step 7 result
User supplied successful CLI output: success=1, failure=0 for QA metadata update. Persisted values and DEV isolation still require verification.

## Step 8 — Verify environment isolation
```powershell
$devProps = jf rt curl -sS -XGET "/api/storage/generic-dev-local/releases/1.0.0/release-notes.txt?properties" --server-id=jfrog-trial | ConvertFrom-Json
$qaProps = jf rt curl -sS -XGET "/api/storage/generic-qa-local/releases/1.0.0/release-notes.txt?properties" --server-id=jfrog-trial | ConvertFrom-Json
Write-Host "DEV Environment: $($devProps.properties.environment)"
Write-Host "DEV Status: $($devProps.properties.'release.status')"
Write-Host "QA Environment: $($qaProps.properties.environment)"
Write-Host "QA Status: $($qaProps.properties.'release.status')"
```
Expected DEV dev/testing and QA qa/qa-pending. Actual result pending. Curl -sS suppresses progress while retaining error messages. Quote dotted property names in PowerShell member access. Artifactory checksum-based binary storage supports independent repository entries and lifecycle metadata. This verifies metadata isolation, not QA validation or security approval. Interview question: Can identical binaries have different release metadata in separate repositories? Yes, repository entries and their properties are independent of the binary content.

## Step 8 result — Environment isolation verified
Actual user output: DEV Environment: dev; DEV Status: testing; QA Environment: qa; QA Status: qa-pending. Independent lifecycle metadata confirmed for the previously checksum-verified identical artifacts.

## Step 9 — QA content validation
```powershell
jf rt dl "generic-qa-local/releases/1.0.0/release-notes.txt" "./qa-validation/" --flat=true --server-id=jfrog-trial
if ($LASTEXITCODE -ne 0) {
    throw "QA artifact download failed"
}
$content = Get-Content "./qa-validation/release-notes.txt" -Raw
if ($content.Trim() -ceq "Application release version 1.0.0") {
    Write-Host "PASS: QA content validation successful" -ForegroundColor Green
} else {
    throw "FAIL: Unexpected artifact content"
}
```
Expected content comes from the Phase 08 release notes creation exercise. CLI dl downloads from QA, Get-Content -Raw reads the file, Trim removes surrounding whitespace, -ceq compares case-sensitively, throw stops on failure. Expected PASS; actual execution pending. This is a simplified content test, not comprehensive QA or security approval. Production automation should use a fresh isolated download directory and verify download counts and errors. Phase 12 Xray enforcement remains unresolved.

## Step 9 result — QA content validation passed
Actual CLI download returned status success, success=1, failure=0. Exit-code check did not throw. PowerShell content comparison printed PASS: QA content validation successful. The defined text-file test passed; this is not comprehensive application QA or security approval.

## Step 10 — Record QA validation status
```powershell
jf rt sp "generic-qa-local/releases/1.0.0/release-notes.txt" "release.status=validated" --server-id=jfrog-trial
```
Record the successful defined content test on the QA repository entry only. Expected success=1, failure=0; execution pending. Validated means defined tests passed, whereas approved means release authorization was granted. Both are project-defined metadata values, not native approval controls. Production approval requires independent governance and security checks. Phase 12 enforcement limitation remains unresolved; subsequent PROD repository promotion is a lab simulation only.

## Step 10 result
User confirmed validated metadata update; raw CLI output and persisted status not independently verified.

## Step 11.1 — Inspect GitHub deployment environments
Open repository Settings > Environments and check whether production already exists. Reuse existing configuration where possible. GitHub Actions environments can enforce deployment approval via required reviewers and branch restrictions where supported, and scope deployment secrets. Editable Artifactory properties alone are not approval enforcement. GitHub approval controls workflow execution, not direct Artifactory access; production credentials must be appropriately restricted. Environment configuration and reviewer availability remain unverified. Phase 12 security enforcement limitation remains unresolved, so this is a lab promotion, not actual production authorization.

## Step 11.1 result
User screenshot confirms no GitHub environments exist in this repository.

## Step 11.2 — Create production environment
Settings > Environments > New environment > name production > Configure environment. Name is project-defined. GitHub environment controls deployment workflow execution, whereas generic-prod-local stores artifacts. Creation alone does not enforce approval; protection rules must be configured and tested. Creation pending confirmation. Phase 12 security limitation remains unresolved.

## Step 11.2 result
Screenshot confirms production environment created and Required reviewers option available. No protection rules configured yet.

## Step 11.3 — Configure manual approval
Enable Required reviewers, select Harsha-23061, leave Prevent self-review unchecked for single-user lab, leave Wait timer disabled, uncheck Allow administrators to bypass configured protection rules, and save. Configuration pending confirmation. Required reviewers gate environment-referencing deployment jobs; disabling bypass does not prevent administrators from editing settings. Single-user self-approval demonstrates workflow mechanics but not independent separation of duties. Enterprise practice is independent reviewers and prevention of self-review. Approval enforcement must be tested with a workflow. Phase 12 security limitation remains unresolved.
