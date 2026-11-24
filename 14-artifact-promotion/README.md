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
