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
