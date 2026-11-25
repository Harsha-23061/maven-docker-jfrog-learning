# Phase 16 — JFrog OIDC authentication

Provider github-oidc, GitHub issuer https://token.actions.githubusercontent.com, organization Harsha-23061, audience jfrog-github, permissive configuration disabled. UI initially created an administrator-scoped mapping; user removed it. Temporary administrator token used locally to POST and GET https://trialgccoro.jfrog.io/access/api/v1/oidc/github-oidc/identity_mappings. User supplied successful response verifying:

```json
{"name":"github-dev-ci","priority":1,"claims":{"aud":"jfrog-github","repository":"Harsha-23061/maven-docker-jfrog-learning","repository_owner":"Harsha-23061","ref":"refs/heads/main","workflow_ref":"Harsha-23061/maven-docker-jfrog-learning/.github/workflows/jfrog-oidc-test.yml@refs/heads/main","event_name":"workflow_dispatch"},"token_spec":{"username":"maven-deployer","scope":"applied-permissions/user","audience":"jfrt@*","expires_in":3600,"self_revocable":false}}
```

User confirmed temporary admin token revocation. Existing deployment secrets unchanged.

## Step 16.7
Dedicated manual main-only workflow jfrog-oidc-test.yml uses id-token: write and setup-jfrog-cli OIDC provider/audience inputs. No stored JFrog secrets. Checks returned username, DEV Maven/Docker reads and unique Maven POM writes (DEV 201, QA/PROD 403). Execution pending. Probe remains in DEV; Docker write boundaries and negative claim exchange not tested by this workflow. Token lifetime configured but actual issued expiry not independently inspected. No migration of existing pipelines.

## Step 16.8 — Federated authentication and DEV permissions VERIFIED
GitHub Actions [run 45593494117](https://github.com/Harsha-23061/maven-docker-jfrog-learning/actions/runs/45593494117), job [139133456812](https://github.com/Harsha-23061/maven-docker-jfrog-learning/actions/runs/45593494117/job/139133456812), head SHA `72ce680c76350d6b846ffe6d0310cbcd7b923840`, **success**. JFrog setup-jfrog-cli@v4 with provider `github-oidc`, audience `jfrog-github`, Github `id-token: write`, `JF_URL` configured and no `JFROG_USER` or `JFROG_TOKEN` environment/secrets. Action exchanged OIDC identity for a JFrog token (masked in logs), verified output username equals `maven-deployer`, API returned Maven DEV `libs-release-local` read HTTP 200, Docker DEV `docker-trial` read HTTP 200, unique Maven DEV test POM PUT HTTP 201, QA `maven-qa-local` PUT 403, PROD `maven-prod-local` PUT 403. Last log `PASS: OIDC Maven write boundaries`, postjob JFrog CLI `jf rt ping` returned `OK`. Unique DEV probe `com/example/lab/oidc-probe/1.0.45593494117-1/oidc-probe-1.0.45593494117-1.pom` persists until authorized cleanup.
This verifies the GitHub OIDC identity exchange and tested repository permissions, NOT negative claims for unauthorized branches/workflows, Docker write boundaries, independent expiry check, or QA/PROD OIDC provider/mapping. Existing working pipelines and static secrets left untouched. Setup action logged nonblocking Node.js 20 deprecation warning on Node.js 24 runner and skipped optional evidence auto-collection; not a test failure.
