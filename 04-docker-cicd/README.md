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

## Local Docker authentication — verified 20 November 2026

The first local `docker pull` returned `Authentication is required`. The user verified `JFROG_USER=maven-deployer` and that `JFROG_TOKEN` was configured in PowerShell (without revealing the token). The following command returned `Login Succeeded`:

```powershell
$env:JFROG_TOKEN | docker login trialgccoro.jfrog.io --username $env:JFROG_USER --password-stdin
```

The registry login is a separate credential context from GitHub Actions secrets. For a new PowerShell session, set credentials securely before login. Never paste access tokens into documentation, screenshots, or GitHub commits.

**Troubleshooting captured:** An unauthenticated Docker pull failed with `Authentication is required`; registry login succeeded. Local pull and run remain to be verified.

## Local pull verification — user reported complete

After successful local Docker login, the user reported that the pull step was done for `trialgccoro.jfrog.io/docker-trial/maven-docker-demo:ci-44788136694-4`. Full pull command output was not supplied. The next verification is to run the image:

```powershell
docker run --rm trialgccoro.jfrog.io/docker-trial/maven-docker-demo:ci-44788136694-4
```

Record the application output and exit status before declaring Exercise 04 fully complete.

## Final runtime verification — 20 November 2026

The user executed the published image locally:

```powershell
docker run --rm trialgccoro.jfrog.io/docker-trial/maven-docker-demo:ci-44788136694-4
```

The command returned to the PowerShell prompt after printing:

```text
Hello and welcome!
i = 1
i = 2
i = 3
i = 4
i = 5
```

This verifies that the Java application in the Docker image executes as expected. Exercise 04's manual CI/CD build, registry push, pull, and local runtime checks are complete. GitHub Actions workflow is manually triggered, not automatically published on every push.
