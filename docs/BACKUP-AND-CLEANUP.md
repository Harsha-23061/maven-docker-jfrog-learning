# Backup, cleanup and recovery

The lab was cleaned locally on November 27, 2026. Source projects were retained. Docker images, containers, volumes and build cache were zero; Minikube profiles and dedicated JFrog CLI configurations were removed. Default Maven settings and repository were retained.

## Backup inventory

Private backup root on the original Windows machine: Documents/JFrog-Project-Backup.

- Original-Project and GitHub-Project: source copies.
- Docker: production.tar and rollback.tar.
- Maven: original JAR and POM.
- BuildInfo: build-info.json.
- QA, PROD and Integrity: evidence directories.
- backup-checksums.csv: five verified file hashes.

CI evidence recovery was not confirmed. Directory presence alone does not prove complete evidence recovery. Local ignored Kubernetes evidence was deleted and is not recoverable from Git. Docker archives preserve runnable images, not necessarily all original OCI attestations.

## Verify and recover

```powershell
$BackupRoot = "$env:USERPROFILE\Documents\JFrog-Project-Backup"
Import-Csv "$BackupRoot\backup-checksums.csv" | ForEach-Object {
    if ((Get-FileHash $_.Path -Algorithm SHA256 -ErrorAction Stop).Hash -ine $_.Hash) {
        throw "Backup checksum mismatch: $($_.Path)"
    }
}
docker load -i "$BackupRoot\Docker\production.tar"
docker load -i "$BackupRoot\Docker\rollback.tar"
docker images
```

The manifest uses original absolute paths; adjust them if the backup is relocated. Restore only when needed. Image archive loading and runtime restoration have not been tested after cleanup.

## Safe cleanup principles

Back up and verify first. Preview ignored/untracked files with git clean -ndX and git clean -nd before considering any deletion. Avoid broad prune or git clean -fdx commands on a shared environment. Remove only confirmed lab-specific resources. Preserve development tools and unrelated configurations.

Local logout and CLI profile removal do not revoke remote tokens. Revoke dedicated lab tokens in JFrog when no longer needed and review corresponding GitHub secrets. Do not publish private backup contents. GitHub workflow evidence expires according to retention settings.

See [Phase 19](../19-automated-enterprise-release) for release and integrity details.
