# Troubleshooting and recovery

Historical lab errors and safe diagnostic steps. Replace trial-specific values with your own. Do not blindly rerun publishing or promotion workflows.

| Symptom | Diagnostic / recovery |
|---|---|
| Maven or Docker HTTP 401 | Check credential presence, expiration and registry hostname without printing secrets. |
| Artifactory HTTP 403 | Review effective repository/build permissions and token scope. Build Info publication required scoped enterprise-demo-build and enterprise-demo-build/** patterns in this lab. |
| Docker Desktop named pipe unavailable | Start Docker Desktop and wait for docker info to show server details. |
| Xray scan green despite findings | Check structured scan schema and severity counts; native watch rejection was not demonstrated in Phase 12. Fail closed on invalid output. |
| OIDC exchange 403 | Compare issuer, audience, repository, branch, workflow and event claims with the approved mapping. Do not broaden access indiscriminately. |
| Promotion destination exists | Inspect existing artifacts and checksums; do not overwrite or delete to force a rerun. |
| Minikube API unavailable | Inspect minikube status and logs, available Docker memory and Kubernetes version. Deleting a cluster destroys local workloads. |
| Admission policy propagation delay | Use bounded retries only for the expected policy denial; restore original expression after rollback authorization. |
| Duplicate Job | Inspect existing Job and logs; duplicate execution is intentionally rejected. |
| GitHub artifact extraction file exists | Download to a new empty directory; verify contents before replacing any backup. |

## Read-only diagnostics

```powershell
git status --short
docker info
docker system df
minikube status
kubectl config get-contexts
jf c show
```

For a recreated cluster, inspect Job and Pod status and logs in enterprise-prod. Do not display Secret contents. See [Phase 19](../19-automated-enterprise-release) for release-specific automation and limitations.

If rollback restoration fails, stop further deployments and have an authorized administrator inspect the live policy and restore the approved expression from a trusted backup. Do not assume a failed script restored policy.
