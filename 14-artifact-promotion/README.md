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
