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
