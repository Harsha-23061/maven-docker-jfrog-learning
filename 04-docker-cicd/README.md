# Exercise 04 — Docker CI/CD to JFrog Artifactory

## Goal

Build a Java 17 Maven application as a Docker image in GitHub Actions and publish the image to the existing JFrog Docker local repository `docker-trial`.

## Completed setup

- Confirmed `docker-trial` is an existing local Docker repository.
- Created permission target `docker-image-deploy`, scoped to `docker-trial`.
- Assigned `maven-deployer` the intended **Read** and **Deploy/Cache** permissions, without Annotate, Delete/Overwrite or Manage (user-reported configuration).
- GitHub Actions repository secrets `JFROG_USER` and `JFROG_TOKEN` were configured during Exercise 03; values are not committed.

## Dockerfile

[`Dockerfile`](Dockerfile) builds the Maven project using a multi-stage Docker build, but **does not** run `mvn deploy` or use credentials during the build.

Build context must be the Maven project directory:

```bash
docker build -f 04-docker-cicd/Dockerfile -t maven-docker-demo:local 01-maven-docker-artifactory
```

Run:

```bash
docker run --rm maven-docker-demo:local
```

The GitHub source is a reconstructed sample of the original IntelliJ project, not necessarily a byte-for-byte copy.

## Docker registry and GitHub Actions publishing

JFrog's Docker setup instructions specify:
- Registry hostname: `trialgccoro.jfrog.io`
- Docker local repository: `docker-trial`
- Image path: `trialgccoro.jfrog.io/docker-trial/<IMAGE>:<TAG>`

The [manual Docker push workflow](../.github/workflows/docker-jfrog-push.yml) builds from `01-maven-docker-artifactory` using the Dockerfile in this exercise, then logs into JFrog using GitHub repository secrets and pushes an image tagged `ci-<run-id>-<attempt>`. The workflow does not use secrets during the image build.

To run: **GitHub → Actions → Exercise 04 - Docker JFrog Push → Run workflow** on `main`. After a successful run, verify the image and tag in JFrog Artifactory.

**Status (20 November 2026):** User-provided GitHub Actions screenshot confirms `docker-build-push` succeeded in 36 seconds after updating the JFrog token. The earlier runs failed at Docker registry login with `invalid header field value for Authorization`; the successful run indicates the workflow completed, but image presence in JFrog Artifactory has not yet been independently verified. No token values were recorded.

## Next steps

1. Verify Dockerfile contents.
2. Confirm JFrog's Docker registry login/hostname and repository access method before authoring a push workflow.
3. Add a manually triggered GitHub Actions Docker build and push workflow with unique image tags and GitHub Secrets.
4. Verify image in JFrog, then pull and run it.

**Security:** Never commit credentials or include tokens in logs or screenshots. Existing Maven permission and Docker permission targets remain separate.

## Verified image in JFrog — 20 November 2026

User-provided Artifactory screenshot confirms the Docker repository `docker-trial` contains image `maven-docker-demo` and tag `ci-44788136694-4`, with associated manifest/digest entries visible. This corresponds to the successful GitHub Actions workflow. Local Docker pull and runtime validation are the remaining steps.

To pull:

```powershell
docker pull trialgccoro.jfrog.io/docker-trial/maven-docker-demo:ci-44788136694-4
```

Do not share access tokens in logs or screenshots.
