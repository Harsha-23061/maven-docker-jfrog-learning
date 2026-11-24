# Phase 11 — JFrog Xray and DevSecOps

Xray analyzes software components for known vulnerabilities, license risks, dependency relationships and impact. Policies define conditions; watches apply policies to resources; configured blocking gates can prevent noncompliant releases. Target flow: GitHub -> CI/CD Maven and Docker -> Artifactory -> Xray analysis -> policy evaluation -> authorized promotion or blocked release. Automated gates are not implemented yet.

## Step 1 — Availability check (pending)
Open Administration > Xray > Indexed Resources (navigation may vary; Security & Compliance may expose Xray features). Verify trial entitlement and indexing configuration availability before proceeding. Reuse libs-release-local, maven-central-remote, docker-trial and docker-hub-remote. No new repositories or application needed. No scan or indexing result has been verified yet.

## Step 1 verification
User confirmed access to Indexed Resources. Actual scan entitlement and results still require verification.

## Step 2 — Repository indexing (pending)
On Indexed Resources > Repositories, use Add Repositories or Manage Repositories (UI wording may vary). Select libs-release-local, maven-central-remote, docker-trial and docker-hub-remote, then save. These cover internal Maven artifacts, cached external Maven dependencies, internal Docker images and cached external Docker images. Indexing enables Xray analysis of supported components and dependency relationships for vulnerabilities and licenses. Processing is asynchronous; enabling indexing does not prove historical artifacts have been scanned. No scan results claimed yet.

Interview question: What is the difference between Artifactory and Xray indexing? Artifactory stores and serves artifacts; Xray identifies supported components and analyzes their security and license risks.
