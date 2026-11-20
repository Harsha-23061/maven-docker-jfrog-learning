# Exercise 01 — Maven + Docker + JFrog Artifactory

Java 17 and Maven project packaged with a multi-stage Dockerfile. The Docker build invokes `mvn clean deploy`, publishing JAR and POM files to the JFrog repository `libs-release-local`.

## Status

Deployment successfully demonstrated through local Maven and Docker; image `maven-demo:1.0.6` built locally. **The original local `pom.xml` and `src/` have not yet been uploaded here.** Copy those exact files from your IntelliJ project before running these scripts. Do not assume the sample scripts have been re-tested from this repository.

## Safe setup

1. Copy `.mvn/settings.xml.example` to `.mvn/settings.xml`.
2. Set `JFROG_USER` and `JFROG_TOKEN` in your shell. The token should be an access token associated with a JFrog identity authorized to deploy to `libs-release-local`.
3. The `pom.xml` distribution management server ID must be `artifactory-release`, with URL `https://trialgccoro.jfrog.io/artifactory/libs-release-local`.
4. Deploy directly: `mvn -s .mvn/settings.xml clean deploy` (use a new, unpublished version).
5. Deploy using Docker and increment version: `./release.ps1` (PowerShell) or `bash release.sh` (Bash).
6. Verify artifact publication in JFrog and run image with `docker run --rm maven-demo:VERSION`.

**Caution:** Both release scripts change `pom.xml` before the Docker build. If Docker/deploy fails, the version stays incremented; inspect the repository before rerunning. Docker layer caching may skip the Maven deploy layer, so a production pipeline should separate build and publish steps.

## Security

Never commit actual access tokens or hardcode them in XML or Dockerfiles. This repository ignores `.mvn/settings.xml` and uploads only a safe example containing environment-variable placeholders. Do not publish screenshots containing tokens.
