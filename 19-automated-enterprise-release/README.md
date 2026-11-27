# Phase 19 - Automated Enterprise Release Management

## Project Overview

End-to-end enterprise DevSecOps learning project using Maven,
Docker, JFrog Artifactory, Xray, GitHub Actions and Kubernetes.

## Technology Stack

- Java 17
- Maven
- Docker
- JFrog Artifactory
- JFrog Xray
- JFrog Release Bundle v2
- JFrog CLI
- GitHub Actions
- OpenID Connect (OIDC)
- Kubernetes
- Minikube
- PowerShell
- Bash

## Release Architecture

Developer
  -> GitHub Actions CI
  -> Maven Build and Tests
  -> Docker Build
  -> JFrog Artifactory
  -> Xray Security Gate
  -> Release Bundle
  -> DEV Promotion
  -> QA Promotion
  -> Production Approval
  -> PROD Promotion
  -> Artifact Integrity Verification
  -> Kubernetes Deployment
  -> Runtime Validation
  -> Controlled Rollback
  -> Audit Evidence

## Release Information

- Release Bundle: enterprise-demo-release
- Release Version: 1.0.8
- Build Name: enterprise-release-ci
- Build Number: 45636994469-1
- Artifact Version: 1.0.7-ci-45636994469-1
- Kubernetes Namespace: enterprise-prod

## GitHub Actions Execution Evidence

| Workflow | Run ID | Result |
|---|---|---|
| Source CI | 45636994469 | PASSED |
| Release Authentication | 45821908854 | PASSED |
| Release Bundle Creation | 45823508305 | PASSED |
| DEV Promotion | 45823906662 | PASSED |
| QA Promotion | 45824284048 | PASSED |
| Production Promotion | 45826565840 | PASSED |
| Integrity Verification | 45929475846 | PASSED |

## Artifact Integrity Verification

- Original build artifacts: 15
- Maven artifacts: 2
- Docker artifacts: 13
- Environments verified: 3
- Artifact checks: 45
- Additional OCI digest checks: 3
- Failed integrity checks: 0
- Production runtime validation: PASSED

Maven artifacts were independently downloaded and hashed.
Docker artifact inventory checks used repository metadata.

## Security Controls

- OIDC authentication
- Environment-specific JFrog credentials
- Production approval gate
- Xray vulnerability scanning
- Immutable digest-pinned container references
- Non-root container execution
- Read-only root filesystem
- Dropped Linux capabilities
- Restricted Kubernetes ServiceAccounts
- Least-privilege Kubernetes RBAC
- ValidatingAdmissionPolicy
- Restricted Pod Security Admission
- ResourceQuota
- LimitRange
- Default-deny NetworkPolicy configuration
- Short-lived deployment credentials
- Duplicate deployment prevention

## Production Xray Results

- Critical: 0
- High: 0
- Medium: 54
- Low: 4
- Security Gate: PASSED

## Rollback Xray Results

- Critical: 0
- High: 0
- Medium: 55
- Low: 4
- Security Gate: PASSED

## Production Deployment

Job: enterprise-demo-release-1-0-8

Result: PASSED

Deployment uses a restricted ServiceAccount and an
approved immutable production image digest.

## Automated Rollback

Job: enterprise-demo-rollback-1-0-8

Result: PASSED

Rollback workflow:

1. Verify historical image and security evidence.
2. Verify image digest.
3. Obtain short-lived deployment credentials.
4. Temporarily authorize the exact rollback image and Job.
5. Retry admission validation during policy propagation.
6. Create rollback Job.
7. Restore original admission expression.
8. Verify application runtime.
9. Remove temporary credentials.
10. Generate audit evidence.

## Failure Recovery Testing

- Unauthorized rollback rejection: PASSED
- Automatic policy recovery after admission failure: PASSED
- Admission propagation retry: PASSED
- Successful rollback runtime: PASSED
- Original admission expression restoration: PASSED
- Post-rollback unauthorized image rejection: PASSED
- Duplicate rollback prevention: PASSED

## Repository Structure

- config/ - Release and rollback baselines
- scripts/ - Deployment, rollback and integrity automation
- kubernetes/rbac/ - ServiceAccounts and RBAC
- kubernetes/policies/ - Admission policies
- kubernetes/hardening/ - Namespace security controls
- kubernetes/deployment/ - Production Job template
- evidence/ - Local execution and audit evidence

## Deployment Commands

Preflight:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/deploy-production.ps1

Execute:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/deploy-production.ps1 -Execute

## Rollback Commands

Preflight:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/rollback-production.ps1

Execute:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/rollback-production.ps1 -Execute

Existing completed Jobs are preserved.
Duplicate execution is intentionally rejected.

## Known Limitations

- This is an enterprise DevSecOps learning environment.
- Kubernetes runs locally using Minikube.
- NetworkPolicy enforcement has not been verified.
- Production deployment is local PowerShell automation,
  not a fully unattended GitHub Actions deployment.
- Production approval uses a solo-lab reviewer.
- Release 1.0.8 reused an existing CI build.
- Fresh artifact transfer was not independently demonstrated.
- Docker inventory checks do not independently hash every blob.
- Medium and Low vulnerability findings remain.
- Rollback reruns a previous batch image and does not
  reverse application side effects.
- Rollback uses previously generated security evidence.
- Forced termination or API failure may prevent policy restoration.
- Audit evidence is not digitally signed.
- Workflows contain release-specific configuration.
- Local evidence is excluded from the public Git repository.

## Final Status

Enterprise DevSecOps learning objectives demonstrated,
including automated release promotion, integrity verification,
secure deployment, rollback and failure recovery.

Production readiness requires additional validation.

## Final documentation audit

Local cleanup completed November 27, 2026. Docker archives, Maven artifacts and Build Info passed backup checksum checks. Local ignored Kubernetes evidence was deleted; final local audit manifest verification was not confirmed. GitHub evidence retention applies. The native Xray build-policy negative test in Phase 12 remained unresolved; independent severity filtering was used instead. No fresh clean-room reproduction was performed.
