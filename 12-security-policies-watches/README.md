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
