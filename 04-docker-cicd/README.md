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

## Next steps

1. Verify Dockerfile contents.
2. Confirm JFrog's Docker registry login/hostname and repository access method before authoring a push workflow.
3. Add a manually triggered GitHub Actions Docker build and push workflow with unique image tags and GitHub Secrets.
4. Verify image in JFrog, then pull and run it.

**Security:** Never commit credentials or include tokens in logs or screenshots. Existing Maven permission and Docker permission targets remain separate.
