# Phase 17 — Kubernetes deployment from JFrog

Goal: run the previously promoted production Docker image by immutable digest in a local Kubernetes Job, using a dedicated read-only registry identity. This Java console application exits, so a Job is appropriate rather than a long-running Deployment.

## Steps 17.1–17.2 — Local cluster preparation
Windows PowerShell, kubectl v1.36.1, Kustomize v5.8.1, Minikube v1.39.0, Docker driver. Existing minikube profile referenced a missing Docker container. Recovery recreated the container with Kubernetes v1.37.0 but API server stopped, storage addons failed with localhost:8443 connection refused, and crictl listed no containers. Underlying startup cause not established. User elected to recreate the lab cluster; minikube stop and minikube delete succeeded. This deletes local cluster workloads and data, not JFrog or GitHub artifacts.

Attempt with 4096 MB rejected because Docker Desktop reported 3918 MB available. Corrected command: `minikube start --driver=docker --cpus=2 --memory=3072 --kubernetes-version=v1.36.1`. User output verified host, kubelet and API server running, kubeconfig configured, node initially NotReady during startup. User subsequently reported completion of `kubectl wait --for=condition=Ready node/minikube --timeout=180s`; final readiness output not independently supplied.

## Step 17.3 — Namespace (pending user confirmation)
`kubectl create namespace enterprise-prod` followed by `kubectl get namespace enterprise-prod`. Custom namespace for local production-style workload isolation; namespace alone is not a security boundary. Next: dedicated registry read-only authentication, then digest-pinned Job. No new application build or artifact publication required.

## Steps 17.3–17.4 — Runtime identity and namespace
User confirmed namespace creation and verification, creation of non-admin `kubernetes-puller` with no groups, and permission `kubernetes-prod-pull` granting Read only on `docker-prod-local` with include `**`. No deploy/cache, annotate, delete/overwrite or manage permissions requested. Effective access boundaries still pending independent verification. Step 17.4.3: generate user-scoped token `minikube-prod-registry-pull` for this identity, seven-day expiration and Artifactory service if selectable. Never commit or print token. Token generation pending user confirmation. Kubernetes registry credentials will be stored in a namespace-specific image pull secret.

## Step 17.4.4 — Runtime repository read boundaries (PASS)
User confirmed token generation and ran authenticated storage API GET requests with kubernetes-puller. Actual HTTP statuses: docker-prod-local 200, docker-qa-local 403, docker-trial 403, maven-prod-local 403. All four matched expectations. Token lifetime and write denial not independently tested; actual registry pull pending.

## Step 17.5 — Registry secret (pending)
Create `jfrog-registry-secret` using `kubectl create secret docker-registry` in `enterprise-prod`, registry hostname `trialgccoro.jfrog.io`, credentials from session environment variables K8S_JFROG_USER and K8S_JFROG_TOKEN. Verify type kubernetes.io/dockerconfigjson using kubectl get secret without exposing contents. Never commit secret data. Lab CLI passes token as process argument; production should use stronger secret management, restricted RBAC and encryption at rest. Base64 is not encryption.

## Steps 17.5–17.8 — Deployment lab conclusion
Actual output confirmed registry secret created with type kubernetes.io/dockerconfigjson and one data entry. Job enterprise-demo created from job.yaml commit ac4f13696a01de01d792e112e59d9f71f8d9e4ee; pod enterprise-demo-g6w29 initially ContainerCreating. Approved image pinned to sha256:085b09ef0029ef23062f729c0b262af5ff40e5a340ac904e91a4a8d41b892ccf. User subsequently confirmed completion of wait, logs and image ID checks without supplying final output; execution and runtime digest are user-reported, not independently verified. Local Minikube lab, not live production. Job chosen because console application exits; CPU/memory limits are lab defaults, not benchmarked. Runtime platform manifest digest can differ from index digest. Clear temporary PowerShell credentials after secret creation. Phase 17 lab steps concluded with evidence limitation.

## Final runtime evidence — PASS
Subsequent actual PowerShell output supersedes the earlier runtime evidence limitation: pod enterprise-demo-g6w29 phase Succeeded; both requested image and runtime imageID equal trialgccoro.jfrog.io/docker-prod-local/enterprise-demo@sha256:085b09ef0029ef23062f729c0b262af5ff40e5a340ac904e91a4a8d41b892ccf. Last application log line i = 5 supplied; full six-line output not independently supplied. Both temporary environment variables removed without reported errors. Local Kubernetes deployment verified; not live production.

## Final documentation audit

Local digest-pinned Job runtime verified; cluster has since been removed. For current reusable manifests and automation see [Phase 19](../19-automated-enterprise-release). Recreate prerequisites before running commands; never commit registry credentials.
