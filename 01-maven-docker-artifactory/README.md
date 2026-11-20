# Exercise 01 — Maven + Docker + JFrog Artifactory

Java 17 application built with Maven, packaged in a multi-stage Docker image, and published to `libs-release-local` using `mvn deploy` within Docker.

> **Source provenance:** This folder uses the previously prepared release scripts and Dockerfile. The `pom.xml` and `Main.java` are reconstructed examples based on the demonstrated configuration, **not byte-for-byte copies of your IntelliJ project**. Replace them with the original files if needed. Version `1.0.6` is shown to match the earlier successful Docker build, and should not be redeployed if it is already published.

## Local setup

1. Install Java 17, Maven and Docker Desktop.
2. Copy `.mvn/settings.xml.example` to `.mvn/settings.xml` (the latter is Git-ignored).
3. Set environment variables `JFROG_USER` and `JFROG_TOKEN` securely; do not commit their values.
4. Verify `pom.xml` has `artifactory-release` configured under `distributionManagement`.
5. For a **new, unpublished version**, run `mvn -s .mvn/settings.xml clean deploy`.
6. Or automate the **next patch version**: PowerShell `./release.ps1`, Bash `bash release.sh`.
7. Verify the JAR and POM in JFrog and run the Docker image: `docker run --rm maven-demo:VERSION`.

## Security and caveats

- Credentials are resolved from environment variables, passed into Docker via BuildKit secrets, and are not stored in the final image.
- `.mvn/settings.xml`, `target/` and local IDE settings are ignored.
- Both release scripts increment `pom.xml` **before** building. On failure, inspect the version and published artifacts before retrying.
- A Docker cache hit can skip the Maven deploy instruction. For production CI/CD, decouple artifact deployment from image build.
- Scope Artifactory deploy permissions to authorized identities and repositories; see the second exercise.
