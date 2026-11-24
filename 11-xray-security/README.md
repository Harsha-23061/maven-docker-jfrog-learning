# Phase 11 — JFrog Xray and DevSecOps

Xray analyzes software components for known vulnerabilities, license risks, dependency relationships and impact. Policies define conditions; watches apply policies to resources; configured blocking gates can prevent noncompliant releases. Target flow: GitHub -> CI/CD Maven and Docker -> Artifactory -> Xray analysis -> policy evaluation -> authorized promotion or blocked release. Automated gates are not implemented yet.

## Step 1 — Availability check (pending)
Open Administration > Xray > Indexed Resources (navigation may vary; Security & Compliance may expose Xray features). Verify trial entitlement and indexing configuration availability before proceeding. Reuse libs-release-local, maven-central-remote, docker-trial and docker-hub-remote. No new repositories or application needed. No scan or indexing result has been verified yet.

## Step 1 verification
User confirmed access to Indexed Resources. Actual scan entitlement and results still require verification.

## Step 2 — Repository indexing (pending)
On Indexed Resources > Repositories, use Add Repositories or Manage Repositories (UI wording may vary). Select libs-release-local, maven-central-remote, docker-trial and docker-hub-remote, then save. These cover internal Maven artifacts, cached external Maven dependencies, internal Docker images and cached external Docker images. Indexing enables Xray analysis of supported components and dependency relationships for vulnerabilities and licenses. Processing is asynchronous; enabling indexing does not prove historical artifacts have been scanned. No scan results claimed yet.

Interview question: What is the difference between Artifactory and Xray indexing? Artifactory stores and serves artifacts; Xray identifies supported components and analyzes their security and license risks.

## Step 2 verification
User confirmed enabling indexing for the four selected repositories. Actual scan completion is not yet verified.

## Step 3 — Docker vulnerability inspection (pending)
Reuse docker-trial/maven-docker-demo/ci-44788136694-4, previously published by GitHub Actions. Navigate Artifactory > Artifacts > image tag or manifest.json and inspect Xray Data/Security/Vulnerabilities (UI wording may vary). Check scan status and actual severity counts. If not indexed or pending, investigate historical indexing rather than assuming zero vulnerabilities. CVE identifies a disclosed vulnerability; CVSS scores severity (Critical 9.0–10.0, High 7.0–8.9, Medium 4.0–6.9, Low 0.1–3.9). Impacted component identifies the affected package; fixed version identifies a version with a fix when available. Direct dependencies are explicitly used; transitive dependencies are introduced by other dependencies. Remediation addresses the vulnerability. Container OS packages may also be affected. No actual vulnerability counts or CVEs verified yet.

## Step 3 — Actual Xray scan evidence (2026-11-24)
User screenshot confirms Xray results loaded on docker-trial/maven-docker-demo/ci-44788136694-4/list.manifest.json after an initially blank tab. The image index itself displays results; individual manifest inspection is not required at this stage. Observed: 52 Security Issues, 1 Critical, No Malicious Packages were found, No Violations were found. Remaining severity counts, CVEs, affected packages and license details are not visible and are not inferred. No reported violations does not establish safety: security issues are findings, while violations depend on applicable policies and watches. Project-specific policies and watches have not yet been configured. No malicious packages detected does not prove absence of all malicious content.

## Step 4 — Critical vulnerability investigation (pending)
Click View All in the 52 Security Issues section. Inspect the critical finding's CVE, affected component, installed version, fixed version if available and severity score. Record actual evidence before selecting remediation or implementing blocking policies.
