# Phase 12 — Security policies, watches and build gates

Policies define security rules; watches apply them to selected resources; violations are findings that breach applicable rules. Build gates stop pipeline progression when configured blocking conditions are met. Target: detect High and Critical vulnerabilities in docker-trial, evaluate with a watch, and later configure and verify blocking behavior.

## Step 1 (pending)
Navigate Platform > Security & Compliance > Policies > New Policy. Name: enterprise-security-policy. Type: Security. Description: Detect high and critical vulnerabilities in enterprise artifacts. Name and description are project choices. Rule and blocking actions will be configured next. No policy enforcement verified yet.

## Steps 1–2 — Policy and rule configuration
User screenshots verified the New Policy wizard under Xray > Watches & Policies. Earlier Platform > Security & Compliance navigation did not match this UI. The Watch Violations page offered Set up a Watch, but an empty watch cannot be created and is not needed first. User proceeded to the New Policy wizard and confirmed saving the rule block-high-critical. Screenshot verified CVEs, Minimal Severity, High, and unchecked exceptions for unavailable fixes, base image and CISA KEV-only matching. User confirmed enabling Fail Build and saving the rule. Generate violation is enabled by default; other blocking actions and notifications were instructed to remain disabled. Block download is deliberately disabled to avoid disrupting existing dependency resolution. Fail Build requires an applicable build watch and scan integration; existing GitHub Actions workflows are not automatically gated.

## Step 3 — Save policy (pending)
Verify enterprise-security-policy (Security) and block-high-critical in the wizard. Leave Apply on Scope empty for now, advance if needed and Save Policy. Create a dedicated watch separately for docker-trial. Policy persistence and enforcement remain unverified.

## Step 3 verification
User confirmed saving enterprise-security-policy. Policy enforcement is not yet verified.

## Step 4 — Create dedicated watch (pending)
Navigate Platform > Xray > Watch Violations > Set up a Watch (observed UI route https://trialgccoro.jfrog.io/ui/watches). Name enterprise-docker-watch; description Monitor Docker images for high and critical security vulnerabilities; Enabled checked; recipients and Jira profile left empty. Manage Resources > By Resource > Add Repositories > docker-trial. Scope limited to internal Docker repository as a deliberate learning choice. Do not save until the policy is assigned. Repository watch supports violation evaluation; Fail Build enforcement requires applicable build coverage and CI scan integration, to be configured and tested separately. Watch creation pending.

## Step 4 verification
User confirmed adding docker-trial to the watch configuration.

## Step 5 — Assign policy and create watch (pending)
Under Assigned Policies select Manage Policies, choose enterprise-security-policy and confirm. Verify enterprise-docker-watch is enabled, scoped to docker-trial and assigned the security policy containing block-high-critical (minimum severity High, Generate violation and Fail Build enabled, Block download disabled). Click Create. Actual watch persistence, historical artifact evaluation, violations and CI/CD build failure are not yet verified. Repository coverage alone does not establish build gating; applicable build coverage and CI scan integration will be tested separately.

## Step 5 verification
Screenshot showed one repository selected, enterprise-security-policy assigned (Security), and Create available. User subsequently confirmed creation. Repository name was collapsed in screenshot; docker-trial selection is based on earlier user confirmation.

## Step 6 — Evaluate existing content (pending)
Locate enterprise-docker-watch in Xray > Watches & Policies > Watches. Use Apply on Existing Content (action placement may vary). If prompted for dates, include November 20, 2026, the existing Docker image creation date shown in Artifactory. Existing findings: 52 security issues including one Critical; previously no reported violations. Expect applicable High/Critical findings to generate violations after asynchronous evaluation. Actual counts and build failure remain unverified. No rebuild or re-upload required for this evaluation.

## Watch persistence verification
Screenshot confirms enterprise-docker-watch exists in Watches & Policies > Watches, one resource, one assigned enterprise-security-policy, Project Name All, and Enabled checked. Violations column shows Calculate, not a verified violation count. Repository name is not expanded. Next inspect the three-dot action menu for Apply on Existing Content; historical evaluation and build gate remain pending.

## Step 6 diagnostic
Latest screenshot shows enabled watch and calculated violation count 0. Historical evaluation initiation/completion is not established by the screenshot. Earlier scan showed 52 security issues including one Critical. Inspect watch action menu for Apply on Existing Content before changing configuration. Zero violations does not establish absence of vulnerabilities. Build gate remains unverified.

## Step 6 — Historical evaluation verified (2026-11-24)
User applied enterprise-docker-watch to existing content using Last 7 Days (18/11/2026–25/11/2026), including the Docker image uploaded November 20. Subsequent screenshot shows 263 violations, up from 0, with watch enabled and enterprise-security-policy assigned. Historical policy evaluation verified. Earlier 52 security issues were from an individual image index; 263 violations are watch-level results and do not establish 263 unique CVEs. Exact breakdown remains unverified. No rebuild required. CI/CD Fail Build enforcement remains untested.

## Step 7 — Inspect violations (pending)
Navigate Platform > Xray > Watch Violations (visible in expanded sidebar). Inspect enterprise-docker-watch results, severity, affected artifacts and triggering policy rule. Record actual evidence before implementing the automated build gate.

## Step 7 — Detailed violations verified
Screenshot confirms 263 displayed violations for enterprise-docker-watch, with visible Critical Security rows affecting maven-docker-demo and exposures:latest. Visible component prefixes include github.com/golang, Thymeleaf, Jackson, Apache Logging, PyYAML 5.2 and libssl1.1. CVE IDs and several component versions are truncated; exact identifiers and remediation are unverified. Contextual Analysis is Locked. Repository-level scope explains inclusion of other images. Basic policy evaluation verified; CI gate not yet tested.

## Step 8 — Automated build gate (pending)
Target flow: GitHub Actions Docker build/push with Build Info collection and publication, applicable build watch coverage, Xray build scan, and pipeline failure on blocking violations. Earlier Docker workflow did not publish associated Build Info. First locate Add Builds by editing enterprise-docker-watch under Watches & Policies > Watches; retain repository and policy. Choose a narrowly scoped CI build name and matching permissions in subsequent configuration. Do not claim build blocking until actual test evidence is available.

## Step 8 — Policy verification and navigation correction
Screenshots of the existing policy editor verify block-high-critical, CVEs, minimum severity High, Generate violation and Fail Build actions, and enterprise-docker-watch under Apply on Scope. The policy editor explicitly states the watch list cannot be edited there. No policy changes required. Cancel, select Watches, edit enterprise-docker-watch via its action menu, and locate Manage Resources > Add Builds. Build coverage and pipeline enforcement remain pending.

## Step 8 — Build selection
Screenshot verifies Configure Selected Builds offers Any Build, By Name and By Pattern; By Name displays zero available builds. Cause not established; indexing and permissions may require configuration. Choose By Pattern with planned exact CI build name enterprise-docker-ci, rather than all builds. This is a new custom name to be reused in CI Build Info publication. Pattern acceptance, indexing, permissions and actual gate enforcement remain pending. Preserve existing repository and policy coverage.

## Step 8 — Build pattern entered
Screenshot confirms By Pattern selected, enterprise-docker-ci added to Build Name Include Pattern, and no exclude patterns. Save By Pattern is visible; a red indicator is also visible near Select By, with cause unknown. Save By Pattern then Save the parent watch; inspect validation message if blocked. Persistence and actual build matching remain unverified. Retain docker-trial and enterprise-security-policy.

## Step 8 — Watch save confirmed
User confirmed Save By Pattern and parent watch Save. Actual matching of future builds remains untested.

## Step 9 — Build publishing permissions (pending)
Reuse enterprise-build-deploy under Administration > User Management > Permissions. Retain existing enterprise-demo-build/** include pattern and add enterprise-docker-ci/** under Build Resources. Keep Include All Builds unchecked and exclusions empty. Retain maven-deployer Builds Read and Deploy only. This follows the successful Phase 09 pattern strategy; new build publishing remains unverified. Watch build-name pattern and permission resource pattern serve different purposes. Reuse existing CI credentials without exposing tokens or granting unrelated permissions.

## Step 9 — Permissions saved
User confirmed adding enterprise-docker-ci/** to existing build permissions. Actual authorization remains to be tested.

## Step 10 — CI security gate implementation
Created .github/workflows/docker-xray-gate.yml as a separate manually triggered workflow to preserve the working Phase 04 baseline. Reuses existing JFROG_USER and JFROG_TOKEN secrets, explicit CLI user/token configuration, Docker login via stdin, existing Dockerfile and repository. Uses enterprise-docker-ci and unique run ID/attempt for build number, gate- prefixed image tag, jf docker push to collect Build Info, jf rt build-publish, and jf build-scan --fail=true to gate subsequent steps. No deployment is performed. Workflow is committed but not yet executed; CLI compatibility, authentication, indexing, scan permissions and policy-triggered failure require runtime verification. A failed scan command alone is not proof of policy enforcement; inspect logs for actual blocking violations.

## Step 11 — First CI execution and HTTP 403 diagnostic
Screenshot shows workflow failed after 38 seconds. Publish Build Info succeeded for enterprise-docker-ci/45403921117-1; Xray build security gate returned HTTP 403 Forbidden, exit code 1, at 13:29:55. Security gate passed step skipped; logout succeeded. This is not verified policy-triggered rejection. Official JFrog docs require Manage Xray Metadata for CI build scan: https://docs.jfrog.com/security/reference/scan-build-v2 and https://docs.jfrog.com/administration/docs/permissions. Earlier permission target enterprise-build-deploy granted Read and Deploy only. Proposed correction: enable Manage Xray Metadata under Builds for maven-deployer on existing target, retaining both existing patterns and leaving Manage, Delete and Annotate disabled. This permission applies to both builds covered by that target and includes supported metadata management, not only scan triggering. No workflow or token change required at this point. Retest pending; actual root cause and policy enforcement remain unverified.

## Step 12 — Retest after permission correction
User confirmed saving Manage Xray Metadata permission changes. Rerun all jobs on the previously failed Phase 12 Docker Xray Security Gate workflow. Existing workflow generates a distinct build number and image tag using run ID and attempt. No code or credential changes needed for this diagnostic. Verify scan authorization and distinguish policy-triggered failure from HTTP 403 or other operational errors. Actual correction and enforcement remain pending runtime evidence.

## Step 13 — Build indexing diagnostic
Second CI attempt completed in 23 seconds. Image gate-45403921117-2 pushed successfully and Publish Build Info succeeded. Xray scan at 13:34:49 returned `Build enterprise-docker-ci is not selected for indexing`, exit code 1. Previous HTTP 403 no longer reported, suggesting Manage Xray Metadata correction resolved that blocker. Security gate passed step skipped. Next locate Administration > Xray Settings > Indexed Resources > Builds (UI placement may vary), and enable indexing specifically for enterprise-docker-ci. Watch coverage and indexing are separate configuration requirements. No workflow or credential changes planned. Indexing and policy-triggered rejection remain unverified.

## Step 14 — Third CI attempt: scan results returned but CLI still running
Screenshot for enterprise-docker-ci/45403921117-3 shows scan started at 13:38:50 and results returned at 13:38:56. Neither HTTP 403 nor indexing error appears. CLI reports no security, license compliance or operational risk violations and `Couldn't determine a package manager or build tool used by this project` under Vulnerable Dependencies. At screenshot time the job was still running after 9m34s (scan step 9m7s); final exit status unknown. Refresh Actions, allow another 2–3 minutes, cancel if still stuck. Existing job timeout is 30 minutes. Do not rerun or change permissions until investigated. Verify Docker artifact association, watch matching and scan results before claiming policy enforcement. Zero violations is not proof of zero vulnerabilities; prior image findings are not necessarily identical to this new build.

## Step 15 — Successful workflow completion
User confirmed third CI attempt finished successfully. Previous authorization and indexing errors no longer prevent completion. Exact final duration not supplied. Earlier scan output reported zero violations and package-manager detection warning. Successful workflow is not proof of policy-based rejection or absence of vulnerabilities.

## Step 16 — Verify Docker Build Info coverage
Navigate Platform > Artifactory > Builds > enterprise-docker-ci > 45403921117-3 > Published Modules (or Modules). Inspect Docker image and associated artifacts. Verify artifact association and policy scope before testing a blocking violation. No additional workflow run or permission change required yet. Phase 12 enforcement validation remains pending.

## Steps 17–18 — Xray UI verification
Scans List > Builds screenshot shows enterprise-docker-ci in artifactory-build-info with one indexed version, latest 45403921117-3. Build Overview subsequently displays All clear! No vulnerabilities found, consistent with successful CI execution. This is a reported result, not proof of complete Docker component coverage. Next select Build Versions and open 45403921117-3 to inspect components/dependencies. No configuration changes or reruns required. Policy-based rejection remains unverified.

## Step 19 — Build version scan summary
Screenshot of Xray Build Versions confirms 45403921117-3 reports 0 violations, 0 vulnerabilities and malicious packages Not Found. Open the version number to inspect detailed component coverage. No new configuration or workflow run required. Complete Docker scan coverage and policy-triggered rejection remain unverified.

## Step 20 — Detailed Xray overview
Screenshot of build 45403921117-3 confirms no reported malicious packages, vulnerabilities or policy violations. Exposures panel advertises Advanced Security features rather than displaying exposure findings. Component coverage is not established. Hover over puzzle-piece icon in inner navigation and inspect tooltip; open Components if identified. No configuration changes needed. Policy-triggered rejection remains unverified.

## Step 21 — Empty SBOM diagnostic
Screenshot for enterprise-docker-ci/45403921117-3 shows SBOM > Components List, empty search and No results were found. Zero reported vulnerabilities cannot establish image safety or effective gate coverage. Root cause is not established: incomplete artifact association or component indexing are hypotheses. Retrieve raw Build Info using PowerShell: `jf rt curl -XGET "/api/build/enterprise-docker-ci/45403921117-3" --server-id=jfrog-trial`. Inspect modules, artifacts and dependencies; redact any sensitive metadata before sharing. No configuration changes or reruns until evidence is inspected. Policy-triggered rejection remains pending.

## Step 22 — Confirmed incomplete Build Info and fail-closed correction
REST response for enterprise-docker-ci/45403921117-3 contains basic metadata, GENERIC agent 2.91.0, setup action 4.10.1, durationMillis 0, no modules, artifacts or dependencies. This explains the empty SBOM; precise cause of missing collection remains unknown. Existing workflow already used supported build-name and build-number flags. Updated workflow to explicitly disable automatic publication, provide module name maven-docker-demo, and retrieve published JSON before scanning. jq requires a Docker module with nonempty artifacts; otherwise pipeline stops. This is a minimum metadata check, not proof of full scan coverage. References: https://docs.jfrog.com/artifactory/docs/jf-docker and https://github.com/jfrog/setup-jfrog-cli. New run from main required to pick up commit (not rerun old revision). Correction remains untested; if validation fails inspect push collection logs and consider explicit build-docker-create association. Policy-based rejection remains pending.

## Step 23 — Fail-closed validation verified
New workflow execution failed in 35 seconds. Publish Build Info succeeded, but jq returned false and the validation emitted `Published Build Info has no Docker module with artifacts. Refusing security pass.` Xray and security approval steps were skipped. This verifies the metadata guard, not vulnerability-based rejection. The explicit module and disabled automatic publishing did not resolve the validation failure. Next inspect the full Push image and collect Build Info step logs for collection warnings and command behavior before changing configuration. Keep validation enabled. No new JFrog permissions or repositories required at this stage.

## Step 24 — Docker layer collection warning and vendor workaround
Run 45409749499-1 push logs report failed build-info collection: no layers found for image. Publish logs confirm zero artifact paths. JFrog documents this exact warning as a possible BuildKit attestation manifest/index compatibility issue: https://jfrog.com/help/r/artifactory-fixing-failed-to-collect-build-info-no-layer-s-was-found-for-image-warning . Updated docker build command with --provenance=false --sbom=false to suppress BuildKit-generated attestations for this compatibility test; Xray SBOM scanning is separate and remains enabled. Fresh hosted runner and unique image tag avoid deleting existing artifacts or pruning shared caches. Keep fail-closed validation. Start new workflow from main; confirm collection, published Docker module, Xray component coverage and policy enforcement. Underlying manifest cause and fix remain pending runtime verification. Production should retain provenance/SBOM through a compatible integration rather than permanently omit attestations without review.

## Step 25 — Explicit Docker artifact association
Attestation workaround run failed in 36 seconds at published Docker Build Info validation; Xray skipped. Replaced implicit jf docker push collection with native docker push, capture and validate the manifest digest from its output, write IMAGE@sha256:digest to a file, and invoke jf rt build-docker-create with explicit target docker-trial and existing build identifiers. Retained single-image build flags for controlled test and existing fail-closed guard. Reference: https://docs.jfrog.com/artifactory/docs/docker-advanced-operations . New run from main required; this alternative is not yet runtime verified. If it fails, inspect explicit association error and manifest format rather than changing permissions blindly.

## Step 26 — Explicit association validation failure
Latest screenshot shows workflow failed in 35 seconds: publication succeeded, validation returned false, Xray and approval skipped. The screenshot does not show build-docker-create output or raw module contents; do not infer the precise cause. Inspect the final lines of Push image and collect Build Info, especially the explicit association command output and warnings. Retain fail-closed guard; no further configuration changes or reruns until evidence is available.

## Step 27 — Resolve Docker Build Info association HTTP 403
Explicit association subsequently failed with HTTP 403 Forbidden, trace ID 51992a4de710896c, before publication. Navigate Administration > User Management > Permissions > docker-image-deploy > Users > maven-deployer. For docker-trial retain Read and Deploy/Cache, enable Annotate, leave Delete/Overwrite and Manage disabled. Annotate permits artifact metadata/property association. Save and rerun all jobs of the failed workflow without other changes. User confirmed saving and then reported the workflow green. This supports the permission correction; exact final run logs and component coverage have not been independently inspected. The fail-closed Docker module validation and Xray gate should now be checked against the successful run. A green run does not establish policy-triggered rejection or complete SBOM coverage. Next inspect the successful Xray build security gate log, including build number and scan findings, before testing rejection.

## Step 28 — Actual Docker vulnerability detection verified
Successful job screenshot confirms 46 seconds total and Xray build security gate completed in 8 seconds. Visible findings for maven-docker-demo:gate-45411263512-2 include Low CVE-2026-105712 in gpgsm, dirmngr, gpg, gnupg and gpgv (2.4.8-4ubuntu3.1), and Low CVE-2025-5278 in coreutils. These are observed scan results, not independent CVE validation. Unlike the earlier empty Build Info run, actual OS component detection is now evidenced. Existing High minimum severity Fail Build rule does not block Low findings. Full severity breakdown and policy-triggered rejection remain unverified. Next controlled negative test: temporarily lower minimum severity to Low on the training policy, run the same workflow, verify explicit blocking policy violation rather than operational failure, then restore High. This affects the existing watch scope; do not use on shared production policies.

## Step 29 — Negative gate test did not reject build
User confirmed temporarily changing minimum severity to Low, then reran workflow. Screenshot shows gate-45411263512-3, successful job in 43 seconds, Xray step in 18 seconds, visible Low findings including CVE-2026-105712 and CVE-2025-5278, and Security gate passed. Expected policy rejection did not occur. Policy persistence, build watch matching and blocking violation evaluation remain unverified. Inspect the beginning of the Xray step (Security Violations and scan command) before further changes. Restore High after controlled testing; temporary Low threshold is still in place per user report. Do not mark Phase 12 enforcement complete.

## Scan evidence: policy enforcement still pending

Build `enterprise-docker-ci/45411263512-3` completed `jf build-scan` with `--fail=true`. The supplied log reports no security, license or operational risk violations, yet lists one Critical and ten High CVEs affecting github.com/golang/go 1.27.3 in image `maven-docker-demo:gate-45411263512-3`, plus Medium and Low findings. This proves component detection, not policy enforcement. Do not promote this build on the basis of the green job. Next inspect the saved enabled watch's build resource scope and assigned policy, including rule conditions, Fail Build action and applicable ignore rules. Root cause remains unconfirmed; a policy-triggered rejection is required before closing this phase.

## Step 30 — Policy rule verification
Screenshot shows enterprise-security-policy, block-high-critical CVE rule, minimum Low, Generate violation and Fail Build actions, and one assigned watch enterprise-docker-watch. Low is a temporary negative-test threshold, not the intended production baseline. Click Save Policy to ensure persistence. Do not recreate resources. Root cause of missing blocking violations remains unresolved; inspect saved watch scope and evaluation before further workflow changes. Restore High after testing. Phase 12 enforcement remains pending.

## Step 31 — Watch build scope inspection
User confirmed saving the policy. Watch screenshot shows By Resource, one repository, two included build patterns (enterprise-security-policy and enterprise-docker-ci), and assigned enterprise-security-policy. The first build pattern is unnecessary because it is a policy name. Edit Builds, remove only enterprise-security-policy from included build patterns, retain enterprise-docker-ci, verify exclusions are empty, Save By Pattern, then Save Watch. Retain assigned policy and repository. Extra inclusion is not established as the cause of missing violations. Correction pending user confirmation; negative gate test remains unresolved.

## Step 32 — Inspect ignore rules
User confirmed saving the corrected watch scope. Navigate Platform > Xray > Watches & Policies > Ignore Rules and inspect existing entries for applicable vulnerability exceptions. Do not create or delete rules. Ignore rules can suppress policy violations within their applicable scope. No evidence yet that an ignore rule caused the green build. Negative gate test remains pending; restore High after controlled testing.

## Step 33 — Re-evaluate existing content
User reports no Ignore Rules. Navigate Platform > Xray > Watches & Policies > Watches > enterprise-docker-watch > three-dot menu > Apply on Existing Content > Last 7 Days > OK. Re-evaluate existing content after policy threshold and watch scope changes. This is a diagnostic, not a confirmed fix. Verify build-specific violations rather than relying on repository-wide counts. Negative gate test remains pending; restore High after controlled testing.

## Step 34 — Verify build-specific violations after reevaluation
User confirmed applying the watch to existing content. Navigate Platform > Xray > Scans List > Builds > enterprise-docker-ci > Build Versions > 45411263512-3 > Policy Violations. Inspect whether violations now appear for this specific build. Reevaluation completion and blocking enforcement are not yet verified. Do not rerun or change configuration until the result is inspected. Restore High after controlled testing.

## Step 35 — Persistent zero build violations and REST diagnostic
Build Versions screenshot shows 45417467925-2, 45417467925-1, 45411263512-3 and 45411263512-2 each with 45 vulnerabilities and zero violations after user reported applying the watch to existing content. Reevaluation completion is not independently established. Component detection works; policy enforcement remains unresolved. Inspect saved watch configuration using read-only `jf xr curl -XGET "/api/v2/watches/enterprise-docker-watch" --server-id=jfrog-trial`. Access depends on Xray permissions; a 403 is a diagnostic result, not justification for broadening permissions blindly. Redact personal contact details before sharing. No new pipeline run or configuration change requested. Restore High after controlled testing.

## Step 36 — REST Watch verification and policy inspection
Successful GET /api/v2/watches/enterprise-docker-watch confirms active=true, all-builds resource with ant-patterns IncludePatterns=[enterprise-docker-ci], ExcludePatterns=[], bin_mgr_id=default, local docker-trial repository, and assigned enterprise-security-policy of type security. CLI 2.77.0 upgrade warning did not prevent retrieval. No watch changes required based on this evidence. Next run `jf xr curl -XGET "/api/v2/policies/enterprise-security-policy" --server-id=jfrog-trial` to inspect persisted severity, fail_build action and any restrictive criteria. Read-only diagnostic; no rerun required. Root cause remains unresolved and High threshold must be restored after controlled testing.

## Step 37 — Empty policy API response
User ran GET /api/v2/policies/enterprise-security-policy and received no visible output. This does not establish policy absence or permission failure. Repeat with `jf xr curl -i -XGET "/api/v2/policies/enterprise-security-policy" --server-id=jfrog-trial` to inspect HTTP status and headers. Redact sensitive headers before sharing. Endpoint compatibility and policy enforcement remain unverified. No configuration changes or reruns requested.

## Step 38 — Policy API access denied
GET /api/v2/policies/enterprise-security-policy with response headers returned HTTP 403 Forbidden, Content-Length 0, 24 Nov 2026 14:56:35 GMT. Watch GET previously succeeded. This confirms denial of the policy API request, not the cause of missing build violations. Inspect existing Xray-related permission target under Administration > User Management > Permissions and its maven-deployer user permissions without modifying them. Do not grant administrator or policy management access merely to troubleshoot a scan. Separate security administration from CI deployment identities. Policy enforcement remains unresolved; temporary Low threshold must be restored after testing.

## Step 36 — Saved Watch verified through REST API
GET /api/v2/watches/enterprise-docker-watch returned active=true, all-builds resource with ant-patterns IncludePatterns=[enterprise-docker-ci], ExcludePatterns=[], local repository docker-trial, and assigned security policy enterprise-security-policy. This confirms saved scope and assignment, not successful violation evaluation. No further Watch changes needed. Next read policy using `jf xr curl -i -XGET "/api/v2/policies/enterprise-security-policy" --server-id=jfrog-trial` to inspect persisted CVE criteria and Fail Build action. The -i flag includes response headers to distinguish authorization failures. If forbidden, do not grant broad permissions solely for this diagnostic. Restore High after controlled testing. Negative enforcement remains unresolved.

## Step 37 — Policy REST authorization blocker
GET /api/v2/policies/enterprise-security-policy with headers returned HTTP 403 Forbidden and empty body. Watch GET succeeded previously. This establishes refusal of this request, not the precise missing permission or cause of zero violations. Do not elevate maven-deployer to administrator. Inspect existing CLI profiles using `jf config show`; share only server IDs and usernames, not credentials or tokens. Consider separate administrator credentials for read-only policy diagnostics. Negative enforcement remains pending; restore High after controlled testing.

## Step 38 — Separate administrative diagnostic credentials
`jf config show` confirms only jfrog-trial, default=true, user maven-deployer. Preserve existing deployment profile and GitHub secrets. Open Administration > User Management > Access Tokens > Generate Token (or equivalent UI label). Stop at configuration form. Plan a separate short-lived administrator token for read-only policy diagnostics, revoke after use, and never store it in GitHub Actions or documentation. No token created yet. Policy API authorization and vulnerability-based rejection remain unresolved; restore High after controlled testing.
