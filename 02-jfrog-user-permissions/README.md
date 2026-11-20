# Exercise 02 — JFrog User Authentication & Permissions

Goal: A dedicated, non-administrator user can deploy Maven artifacts only to the approved repository.

## Progress

- [x] Created JFrog user `maven-deployer` (non-admin, member of `readers`).
- [ ] Finalize and verify permission target `maven-release-deploy`.
- [ ] Generate a limited-lifetime user-scoped access token.
- [ ] Configure `JFROG_USER` and `JFROG_TOKEN` locally, without committing secrets.
- [ ] Test permitted deployment with a new version.
- [ ] Test denial using a separate read-only identity.

## Permission target

In JFrog Administration → User Management → Permissions → New Permission:

- **Repository scope:** `libs-release-local` only.
- **User:** `maven-deployer`.
- **Allow:** `Read`, `Deploy/Cache`.
- **Do not allow:** `Annotate`, `Delete/Overwrite`, `Manage`, `Manage Xray Metadata`.

Review any other group permission grants, including `readers`. Do not assign platform-administrator privileges. Save the permission only after confirming the repository scope.

## Authentication

Use an access token associated with `maven-deployer`; set the environment variables in your own shell. The existing `.mvn/settings.xml` references:

```xml
<username>${env.JFROG_USER}</username>
<password>${env.JFROG_TOKEN}</password>
```

JFrog controls repository authorization; a username check in a release script does not constitute access control.

## Next hands-on step

Finish creating `maven-release-deploy` in JFrog, verify it applies only to `libs-release-local`, and then generate an access token. Never paste the token into chat, screenshots, commits, or README files.
