# Phase 16 — JFrog OIDC authentication

Provider github-oidc, GitHub issuer https://token.actions.githubusercontent.com, organization Harsha-23061, audience jfrog-github, permissive configuration disabled. UI initially created an administrator-scoped mapping; user removed it. Temporary administrator token used locally to POST and GET https://trialgccoro.jfrog.io/access/api/v1/oidc/github-oidc/identity_mappings. User supplied successful response verifying:

```json
{"name":"github-dev-ci","priority":1,"claims":{"aud":"jfrog-github","repository":"Harsha-23061/maven-docker-jfrog-learning","repository_owner":"Harsha-23061","ref":"refs/heads/main","workflow_ref":"Harsha-23061/maven-docker-jfrog-learning/.github/workflows/jfrog-oidc-test.yml@refs/heads/main","event_name":"workflow_dispatch"},"token_spec":{"username":"maven-deployer","scope":"applied-permissions/user","audience":"jfrt@*","expires_in":3600,"self_revocable":false}}
```

User confirmed temporary admin token revocation. Existing deployment secrets unchanged.

## Step 16.7
Dedicated manual main-only workflow jfrog-oidc-test.yml uses id-token: write and setup-jfrog-cli OIDC provider/audience inputs. No stored JFrog secrets. Checks returned username, DEV Maven/Docker reads and unique Maven POM writes (DEV 201, QA/PROD 403). Execution pending. Probe remains in DEV; Docker write boundaries and negative claim exchange not tested by this workflow. Token lifetime configured but actual issued expiry not independently inspected. No migration of existing pipelines.
