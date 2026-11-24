# Phase 13 — Artifact Properties, REST APIs and AQL

## Objectives
Learn custom artifact metadata, REST API operations, AQL searches and metadata-driven DEV/QA/PROD promotion preparation. Reuse Phase 08 generic-dev-local repository and release-notes.txt artifact rather than duplicating setup.

## Concepts and enterprise use
Artifact properties are key-value metadata associated with Artifactory items. They support ownership, release tracking, automation, compliance evidence and promotion workflows. Example proposed custom values (not yet applied): application=enterprise-demo, environment=dev, release.version=1.0.0, release.status=pending, team=platform-engineering. Metadata labels alone do not prove security approval or move artifacts between repositories. AQL enables metadata-based searches; REST APIs support automation of repository operations. Read and Annotate permissions are relevant for property access and mutation respectively; verify current permissions before changing them.

## Step 1 — Locate existing artifact
Artifactory > Artifacts > generic-dev-local > releases > 1.0.0 > release-notes.txt > Properties. Inspect only; do not add properties yet. Artifact was previously uploaded and verified in Phase 08. Current inspection pending.

## Interview question
What is the difference between artifact properties and artifact content? Properties describe and classify stored items; content is the actual stored binary or file. Changing a property is not equivalent to rebuilding or promoting the binary.

## Security prerequisite
Phase 12 build-level policy enforcement remains unresolved. Do not use a metadata label or successful scan alone as production security approval.

## Step 2 — Add custom artifact properties
User confirmed opening the Properties tab in Step 1. Add properties to generic-dev-local/releases/1.0.0/release-notes.txt using Add Property or + and save.

| Key | Value | Enterprise purpose |
|---|---|---|
| application | enterprise-demo | Application identification |
| environment | dev | Environment classification |
| release.version | 1.0.0 | Release traceability |
| release.status | pending | Release readiness tracking |
| team | platform-engineering | Ownership |

These are project-defined naming conventions, not mandatory JFrog keys. Workflow: upload artifact, attach metadata, search with AQL, validate approvals and security, promote DEV to QA to PROD. Metadata does not move binaries or establish approval. Phase 12 enforcement limitation remains outstanding. Property creation pending confirmation. If editing is unavailable, inspect Annotate permissions before changing access.

## Step 3 — Retrieve properties using REST API
Step 2: screenshot verified environment=dev; user subsequently confirmed adding all five properties. Keep Add Recursively unchecked for individual file. Verify programmatically using PowerShell:
```powershell
jf rt curl -XGET "/api/storage/generic-dev-local/releases/1.0.0/release-notes.txt?properties" --server-id=jfrog-trial
```
GET is read-only; /api/storage/ and ?properties are standard Artifactory API syntax; repository, path and server ID are existing project configuration. Expected properties object contains application=[enterprise-demo], environment=[dev], release.version=[1.0.0], release.status=[pending], team=[platform-engineering]. Values are arrays because properties may be multi-valued. Additional response fields may appear. Actual API response pending. Existing deployment profile is reused; no new credentials or permission changes planned. Official reference: https://docs.jfrog.com/artifactory/reference. Enterprise use: Jenkins/GitHub Actions retrieve metadata for automated release eligibility checks; metadata is not independent security approval.

Interview question: Why use REST APIs rather than UI? APIs provide repeatable, authenticated machine-to-machine operations suitable for CI/CD automation.
