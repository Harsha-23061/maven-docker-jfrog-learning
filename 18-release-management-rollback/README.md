# Phase 18 — Release Management and Rollback

## Steps 18.1–18.6 — Release Bundle v2
Release Lifecycle menu verified in trial UI. The Release Lifecycle creation wizard offered existing bundles as sources; instead opened Artifactory > Builds > enterprise-release-ci > 45564602972-1 > Create Release Bundle. Planned name enterprise-demo-release, version 1.0.0 (lab-chosen values). Content screen verified four modules: maven-docker-artifactory generic 2/2, enterprise-demo docker 1/1, linux/amd64/enterprise-demo docker 9/9, attestations/enterprise-demo docker 3/3. Total 15 artifact entries, zero recorded build dependencies. Include Build Dependencies unchecked. User confirmed creation and visibility; final bundle contents, signing key/status and lifecycle history not independently verified. No rebuild required. Existing QA/PROD artifacts already present from Phase 15; do not blindly promote into existing destinations.

## Step 18.7 — Promotion discovery
Inspect available Promote action and target environments before executing any promotion. Release Bundle promotion is distinct from earlier individual artifact copies. Rollback requires a previously approved version and a deployment action; bundle creation alone does not deploy or roll back Kubernetes.

## Release verification and product lifecycle notice
UI screenshot confirms enterprise-demo-release version 1.0.0 exists; stage and status blank in list. Bundle-level Actions offers Create Version From Release Bundles and Create Version From Builds. JFrog UI banner states RLM deprecation July 31, 2026, anticipated end-of-life January 31, 2028, and recommends AppTrust. Dates recorded from displayed notice, not independently checked. Prioritize understanding existing RLM and exploring AppTrust rather than investing heavily in deprecated workflows. Version-level promotion and signing status remain unverified.
