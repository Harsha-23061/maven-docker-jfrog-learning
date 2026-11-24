# Enterprise JFrog Master Project

Hands-on Java, Maven, Docker, Artifactory, Xray and GitHub Actions learning project. Follow the phase guides in order. Progress is based on exercises reported during the learning sessions, not an independent clean-room reproduction.

## Getting started

Use a GitHub repository, JFrog platform with appropriate entitlements, Java 17, Maven, Docker Desktop, PowerShell and JFrog CLI. Replace the training tenant URL with your own. Create your own restricted deployment credentials and GitHub secrets JFROG_USER and JFROG_TOKEN. Never commit real credentials. This repository is public.

## Practical guides

| Guide | Topic |
|---|---|
| [01](./01-maven-docker-artifactory) | Maven and Docker setup |
| [02](./02-jfrog-user-permissions) | Restricted deployment user |
| [03](./03-github-actions-cicd) | Maven CI/CD |
| [04](./04-docker-cicd) | Docker CI/CD |
| [05](./05-remote-virtual-repositories) | Remote and virtual repositories |
| [06](./06-maven-dependency-resolution) | Maven dependency resolution |
| [07](./07-docker-hub-proxy) | Docker proxy and caching |
| [08](./08-jfrog-cli) | CLI setup |
| [09](./09-build-info) | Build Info and traceability |
| [12](./12-security-policies-watches) | Xray policies, watches and CI gate |

Folder numbering reflects the historical exercises and does not always match the master roadmap numbering.

## Master roadmap

Phases 01–11 cover setup, local repositories, permissions, CI/CD, remote/virtual repositories, Maven resolution, Docker proxy, CLI, Build Info, environment strategy and Xray scanning. Core exercises have been performed; individual subtopics (including license scanning) should be audited before claiming complete coverage.

Phase 12 is in progress: security policy and watch verified with 263 violations. CI Build Info publication succeeded; initial scan HTTP 403 no longer appears after permission correction. Latest blocker: enterprise-docker-ci is not selected for indexing. Next enable Xray build indexing and retest. Policy-triggered CI failure is not yet verified.

Remaining planned phases:
13. Artifact properties, REST API and AQL
14. DEV/QA/PROD promotion
15. Automated enterprise CI/CD
16. OIDC authentication
17. Kubernetes deployment
18. Release management and rollback
19. Cleanup, retention and storage
20. Administration, monitoring, backup and HA
21. Final production-style implementation

Training trial expires December 4, 2026 according to the UI. Prioritize licensed features; availability may differ by subscription.

## Reproducibility limitations

Original Windows IntelliJ files are not automatically accessible to this integration. Exercise 01 contains reconstructed sample source/POM; compare against actual local files before assuming exact equivalence. Navigation varies by platform version. The guides record actual evidence and pending tests, but a fresh-user end-to-end documentation audit is still needed. Do not interpret an operational error as a successful security gate.
