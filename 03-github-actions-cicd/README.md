# Exercise 03 — GitHub Actions Maven CI/CD

## Milestone 1: Maven CI — verified

The [Maven CI workflow](../.github/workflows/maven-ci.yml) runs on changes to the Exercise 01 Maven project and can also be started manually. The user verified a successful GitHub Actions build job on 20 November 2026 (workflow run #1, approximately 25 seconds).

## Milestone 2: Manual JFrog deployment

The [JFrog Deploy workflow](../.github/workflows/jfrog-deploy.yml) is manually triggered through GitHub Actions. It:
1. Checks out the GitHub repository.
2. Sets up Java 17 and Maven dependency caching.
3. Sets a unique Maven version `1.0.7-ci-<run-id>-<attempt>` to avoid overwriting previously published releases.
4. Runs `mvn clean verify` without deployment credentials.
5. Supplies `JFROG_USER` and `JFROG_TOKEN` from GitHub Actions repository secrets only to the deployment step.
6. Uses the existing Maven settings template to deploy the JAR and POM to `libs-release-local`.

### Repository secrets

In **Settings → Secrets and variables → Actions**, configure:
- `JFROG_USER`: `maven-deployer`
- `JFROG_TOKEN`: user-scoped JFrog access token (never record its value)

Never place tokens in commits, screenshots, log output or documentation. GitHub Actions secrets are available to workflows with appropriate repository privileges; review who can modify workflows and who can run them.

### Run the deployment

Go to **Actions → Exercise 03 - JFrog Deploy → Run workflow → main → Run workflow**. Inspect the deployment job logs for `BUILD SUCCESS` and the uploaded artifact version. Verify the version in JFrog Artifactory.

### Security / limitations

- Deployment is **manual only**; ordinary pushes run CI but do not publish.
- The token is scoped to the deployment step, and the workflow does not print its value.
- This is a learning exercise, not a production release pipeline. Consider GitHub environments with required reviewers, pinned action commit SHAs, token rotation, and artifact provenance before production use.
- The committed Exercise 01 Java source and POM were reconstructed samples and may differ from the original local IntelliJ project.
- The Maven sample currently has no automated tests; successful `verify` does not establish functional test coverage.
- Earlier CI screenshots showed warnings about the v4 checkout/setup-java actions. Updating these dependencies is separate follow-up work.

## Verified CD execution — 20 November 2026

User-provided GitHub Actions screenshot shows the `deploy` job succeeded in approximately 28 seconds, and the `Deploy to JFrog Artifactory` step reported `[INFO] BUILD SUCCESS`. The Maven version shown in the log was `1.0.7-ci-44785991685-1`.

This confirms successful execution of the configured deployment workflow. **Independent confirmation in the JFrog artifact browser is complete.** The user-provided Artifactory screenshot shows repository path `libs-release-local/com/example/maven-docker-artifactory/1.0.7-ci-44785991685-1/`, with `Deployed By: maven-deployer`, and visible version contents. The screenshot establishes the version folder and artifacts are present; it does not independently verify artifact checksums. No token or password values were included in the screenshot or this documentation.

## Evidence to capture

1. CI workflow success summary.
2. CI build job success.
3. Repository secret **names only**.
4. Deployment workflow success showing uploaded Maven version.
5. Artifactory artifact listing for the published version — verified by screenshot (20 November 2026).
