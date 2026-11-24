# Phase 07 — Docker Hub proxy and caching

## Objective and enterprise use
Reuse docker-trial for internal images. Proxy Docker Hub through a remote repository and later combine both using a virtual repository. This centralizes access, reduces repeated upstream downloads and exposure to upstream rate limits, and enables security policy integration where licensed. Caching does not guarantee offline availability or image trust.

```mermaid
flowchart TD
 A[Docker and CI] --> V[docker-virtual]
 V --> L[docker-trial]
 V --> R[docker-hub-remote]
 R --> H[Docker Hub]
```

## Step 1 — Create remote repository (pending)
Administration > Repositories > Create a Repository > Remote > Docker. Key: docker-hub-remote. Upstream URL: https://registry-1.docker.io/ (use Docker Hub preset if offered). Leave other defaults; anonymous upstream access for public images initially, subject to rate limits. Check for an equivalent existing repository first. Do not enter JFrog credentials as upstream Docker Hub credentials. Test and save. Next configure scoped permissions and verify a pull through JFrog.
