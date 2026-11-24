# Phase 15 — Automated Enterprise CI/CD

## Step 1 — Existing pipeline assessment
Directly reviewed `.github/workflows/maven-ci.yml`, `jfrog-deploy.yml`, `docker-jfrog-push.yml`, `qa-prod-promotion.yml` and Phase 12 README. Maven CI uses Java 17 and clean verify. Maven deploy sets unique CI version, runs clean verify then deploy with skipTests (reexecutes lifecycle phases). Docker push independently builds using 04-docker-cicd/Dockerfile. Generic promotion uses protected production environment, dedicated credentials, pinned SHA, status and destination checks, copy and read-back. Preserve existing workflows as learning references. Build Info implementation requires further source review. Phase 12 native Xray build-level enforcement remains unresolved; real production release must remain blocked. Existing production identity is scoped to Generic repositories, not verified for Maven/Docker promotion.

## Proposed architecture
Build/test versioned JAR once, publish same JAR and package into Docker image, collect Build Info, enforce security checks, validate QA, require manual approval, then controlled promotion. Reuse existing repositories and credentials where scope permits. Proposed design not implemented or tested yet.

## Next step
Inspect existing Maven project POM, source/tests and Dockerfile before choosing implementation. No user-side changes required.
