# Phase 17 — Kubernetes deployment from JFrog

Goal: run the previously promoted production Docker image by immutable digest in a local Kubernetes Job, using a dedicated read-only registry identity. This Java console application exits, so a Job is appropriate rather than a long-running Deployment.

## Steps 17.1–17.2 — Local cluster preparation
Windows PowerShell, kubectl v1.36.1, Kustomize v5.8.1, Minikube v1.39.0, Docker driver. Existing minikube profile referenced a missing Docker container. Recovery recreated the container with Kubernetes v1.37.0 but API server stopped, storage addons failed with localhost:8443 connection refused, and crictl listed no containers. Underlying startup cause not established. User elected to recreate the lab cluster; minikube stop and minikube delete succeeded. This deletes local cluster workloads and data, not JFrog or GitHub artifacts.

Attempt with 4096 MB rejected because Docker Desktop reported 3918 MB available. Corrected command: `minikube start --driver=docker --cpus=2 --memory=3072 --kubernetes-version=v1.36.1`. User output verified host, kubelet and API server running, kubeconfig configured, node initially NotReady during startup. User subsequently reported completion of `kubectl wait --for=condition=Ready node/minikube --timeout=180s`; final readiness output not independently supplied.

## Step 17.3 — Namespace (pending user confirmation)
`kubectl create namespace enterprise-prod` followed by `kubectl get namespace enterprise-prod`. Custom namespace for local production-style workload isolation; namespace alone is not a security boundary. Next: dedicated registry read-only authentication, then digest-pinned Job. No new application build or artifact publication required.

## Steps 17.3–17.4 — Runtime identity and namespace
User confirmed namespace creation and verification, creation of non-admin `kubernetes-puller` with no groups, and permission `kubernetes-prod-pull` granting Read only on `docker-prod-local` with include `**`. No deploy/cache, annotate, delete/overwrite or manage permissions requested. Effective access boundaries still pending independent verification. Step 17.4.3: generate user-scoped token `minikube-prod-registry-pull` for this identity, seven-day expiration and Artifactory service if selectable. Never commit or print token. Token generation pending user confirmation. Kubernetes registry credentials will be stored in a namespace-specific image pull secret.
