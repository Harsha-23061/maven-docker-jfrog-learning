# Exercise 02 — JFrog User Authentication & Permissions

Goal: Deploy Maven artifacts using a dedicated, non-administrator JFrog identity with repository-scoped authorization.

## Verified progress — 20 November 2026

- [x] Created JFrog user `maven-deployer` (non-admin; observed in `readers` group).
- [x] User reports creating a repository permission target.
- [x] Generated a user-scoped JFrog access token (token itself was not shared or committed).
- [x] Configured `JFROG_USER=maven-deployer` and `JFROG_TOKEN` in the current PowerShell session.
- [x] Updated local Maven project from version `1.0.6` to `1.0.7`.
- [x] Ran `mvn -s .mvn/settings.xml clean deploy`; Maven reported `BUILD SUCCESS` (13.278 seconds).
- [x] Verified via Maven logs: version `1.0.7` POM, JAR and Maven metadata uploaded to `libs-release-local`.
- [ ] Independently review permission target's exact repository scope and effective inherited group permissions.
- [ ] Verify denied deployment to an unauthorized repository using a safe test repository and unique version.
- [ ] Verify existing release overwrite is denied (avoid modifying valuable published artifacts).
- [ ] Review token expiry, rotation and revocation.

## Intended permission target

JFrog Administration → User Management → Permissions → New Permission:

- **Repository scope:** `libs-release-local` only.
- **User:** `maven-deployer`.
- **Allow:** `Read`, `Deploy/Cache`.
- **Do not allow:** `Annotate`, `Delete/Overwrite`, `Manage`, `Manage Xray Metadata`.

**Important:** Successful deployment proves the account can deploy to the target repository; it does not by itself prove other repositories or overwrite operations are denied. Effective access may include permissions from groups such as `readers`.

## Local authentication

Use a JFrog access token associated with `maven-deployer`. Keep token values only in secure local storage or temporary environment variables. The untracked `.mvn/settings.xml` uses:

```xml
<username>${env.JFROG_USER}</username>
<password>${env.JFROG_TOKEN}</password>
```

Example verification commands (do not print the token):

```powershell
Write-Host "JFrog User: $env:JFROG_USER"
Write-Host "Token configured: $(-not [string]::IsNullOrEmpty($env:JFROG_TOKEN))"
mvn -s .mvn/settings.xml help:evaluate "-Dexpression=project.version" -q -DforceStdout
mvn -s .mvn/settings.xml clean deploy
```

Only run `deploy` with a version not previously published, unless intentionally testing overwrites in an isolated test repository.

## Verified Maven output

```text
Uploaded to artifactory-release: .../1.0.7/maven-docker-artifactory-1.0.7.pom
Uploaded to artifactory-release: .../1.0.7/maven-docker-artifactory-1.0.7.jar
Uploaded to artifactory-release: .../maven-metadata.xml
[INFO] BUILD SUCCESS
[INFO] Total time: 13.278 s
```

No passwords, access tokens, or sensitive environment variable values are included here.

## Next hands-on step

Inspect the saved JFrog permission target and effective group permissions. Then perform a controlled negative authorization test using a separate safe test repository, not an existing published release.
