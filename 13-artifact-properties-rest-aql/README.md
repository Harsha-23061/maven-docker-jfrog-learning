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

## Step 3 result — REST verification successful
User supplied actual Storage API JSON containing all five expected properties: application=[enterprise-demo], environment=[dev], release.status=[pending], release.version=[1.0.0], team=[platform-engineering]. URI matched generic-dev-local/releases/1.0.0/release-notes.txt. Existing deployment credentials worked for property retrieval. No permission changes required. Arrays support multi-valued properties.

## Step 4 — Introduction to AQL
Artifactory Query Language searches items by repository, filename, path, metadata and other attributes. Unlike a Storage API lookup of a known path, AQL discovers matching items. Create a local query file using `notepad search-artifacts.aql` and save:
```aql
items.find({
    "repo": "generic-dev-local",
    "name": "release-notes.txt",
    "@environment": "dev",
    "@release.status": "pending"
}).include("repo", "path", "name", "property")
```
All conditions must match. items.find(), @ property prefix and include() are standard AQL syntax; repository, filename and metadata are existing project values; query filename is chosen locally. Official reference: https://docs.jfrog.com/artifactory/docs/artifactory-query-language. Enterprise use: discover pending DEV artifacts before independent approval and security checks. Query creation and execution remain pending. Metadata is not security approval; Phase 12 enforcement limitation remains unresolved.

Interview question: When would you choose AQL over the Storage API? Use AQL to discover items matching multiple conditions, and Storage API to retrieve metadata for a known item path.

## Step 5 — Execute AQL through JFrog CLI
User confirmed saving the query file. From the directory containing search-artifacts.aql, run:
```powershell
jf rt curl -XPOST "/api/search/aql" -H "Content-Type: text/plain" --data-binary "@search-artifacts.aql" --server-id=jfrog-trial
```
POST submits a read-only AQL search. /api/search/aql is the Artifactory endpoint, text/plain is the query content type, and --data-binary @filename reads the local query file. Existing CLI credentials are reused. Expected result includes generic-dev-local/releases/1.0.0/release-notes.txt and requested properties, plus range information. Additional matches are possible. Actual execution pending. Enterprise use: discover release candidates automatically before independent approval and security checks. No repository or permission changes planned.

## Step 5 result — AQL verified
Actual response returned one item (range start_pos=0, end_pos=1, total=1, limit=500000): generic-dev-local/releases/1.0.0/release-notes.txt, with all five expected properties. AQL property results use key/value objects, unlike the Storage API properties map. Existing deployment credentials successfully performed the read-only search.

## Step 6 — Automate property updates with JFrog CLI
```powershell
jf rt sp "generic-dev-local/releases/1.0.0/release-notes.txt" "release.status=testing" --server-id=jfrog-trial
```
The standard CLI sp (set-properties) command targets the existing artifact and attempts to change release.status from pending to testing. Other properties should remain intact; verify actual state after execution. Annotate permission is required; current deployment-user permission is not assumed. If forbidden, inspect the relevant permission target rather than grant broad access. Custom lifecycle example: pending > testing > validated > approved > released. These labels do not execute tests, establish approval or physically promote artifacts. Phase 12 security enforcement remains unresolved. Execution pending.

Interview question: What permission is needed to modify artifact properties? Annotate permission on the target artifact, scoped to the appropriate repository/path.

## Step 6 result — Property mutation rejected
Actual jf rt sp command returned HTTP 403 Forbidden while setting release.status=testing on generic-dev-local/releases/1.0.0/release-notes.txt. Trace ID e6d374917e656a74. Earlier Storage API and AQL reads succeeded. Missing Annotate permission is the likely cause, not yet verified by a successful retry.

## Step 7 — Repository-scoped Annotate permission
Administration > User Management > Permissions > generic-artifact-deploy. Verify scope is generic-dev-local and inspect maven-deployer permissions. Enable Annotate, retain Read and Deploy/Cache, leave Delete/Overwrite and Manage disabled, and save. Reuse existing permission target and token; no administrator elevation. Annotate authorizes property mutation independently of binary overwrite. This illustrates least privilege and RBAC. Permission change and retry pending. Interview question: Why can a user read properties but receive 403 when updating them? Read and Annotate are separate permissions; verify effective authorization on the target repository/path.

## Step 8 — Retry property mutation after permission change
User confirmed enabling Annotate on the existing permission target. Retry `jf rt sp "generic-dev-local/releases/1.0.0/release-notes.txt" "release.status=testing" --server-id=jfrog-trial`. Expected one successful item and zero failures. Same artifact, command, user and token; only intended change is repository-scoped Annotate permission. Actual result pending. Verify stored property values after success; do not infer release approval from metadata.
