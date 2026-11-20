# Maven + Docker + JFrog Artifactory — Hands-on Learning

A two-exercise repository documenting Maven builds, Docker packaging, JFrog artifact publication, and user-level authorization.

| Folder | Exercise | Status |
|---|---|---|
| [01-maven-docker-artifactory](./01-maven-docker-artifactory) | Java 17, Maven, multi-stage Docker build, BuildKit secrets, PowerShell/Bash release automation | Previously demonstrated; recreated example source and POM |
| [02-jfrog-user-permissions](./02-jfrog-user-permissions) | JFrog non-admin deployment user, repository permission target, access token, positive/negative access tests | In progress |

## Important

The original Windows IntelliJ files are not automatically accessible to this GitHub integration. The first exercise contains the previously prepared Docker/release files and reconstructed sample source/POM. Compare them with your **actual local** `C:\Users\USER\IdeaProjects\maven-docker-artifactory` before treating this as the exact final project.

### Security

**Never commit real tokens, passwords, `.mvn/settings.xml`, or private shell output.** The tracked `.mvn/settings.xml.example` holds only environment-variable references. This repository is currently public.

### Next step

Finish the restricted `maven-deployer` permissions for `libs-release-local`, generate an access token, and validate deployments using a new release version.
