# Phase 11 — JFrog Xray and DevSecOps

Xray analyzes software components for known vulnerabilities, license risks, dependency relationships and impact. Policies define conditions; watches apply policies to resources; configured blocking gates can prevent noncompliant releases. Target flow: GitHub -> CI/CD Maven and Docker -> Artifactory -> Xray analysis -> policy evaluation -> authorized promotion or blocked release. Automated gates are not implemented yet.

## Step 1 — Availability check (pending)
Open Administration > Xray > Indexed Resources (navigation may vary; Security & Compliance may expose Xray features). Verify trial entitlement and indexing configuration availability before proceeding. Reuse libs-release-local, maven-central-remote, docker-trial and docker-hub-remote. No new repositories or application needed. No scan or indexing result has been verified yet.
