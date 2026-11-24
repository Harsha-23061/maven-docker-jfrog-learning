# Phase 06 — Maven dependency resolution

## Purpose
Route developer and CI Maven dependency and plugin resolution through the JFrog virtual repository for centralized access and caching. This complements earlier artifact publishing exercises.

## Step 1 — Permissions (user confirmed)
Permission target `maven-dependency-read` grants `maven-deployer` Read and Deploy/Cache on `maven-central-remote`, without Delete/Overwrite, Annotate or Manage. Read permits cached artifact access; Deploy/Cache permits fetching and caching new upstream artifacts. Existing local repository permissions are reused. This demonstrates least privilege.

## Step 2 — Isolated Maven settings (pending user confirmation)
On Windows, run `notepad "$env:USERPROFILE\.m2\settings-jfrog.xml"`. Keep existing deployment settings unchanged.

```xml
<settings>
    <servers>
        <server>
            <id>jfrog-maven</id>
            <username>${env.JFROG_USER}</username>
            <password>${env.JFROG_TOKEN}</password>
        </server>
    </servers>
    <mirrors>
        <mirror>
            <id>jfrog-maven</id>
            <name>JFrog Maven Virtual Repository</name>
            <url>https://trialgccoro.jfrog.io/artifactory/maven-virtual</url>
            <mirrorOf>*</mirrorOf>
        </mirror>
    </mirrors>
</settings>
```

The server ID must match the mirror ID. Environment variable references avoid hardcoding secrets. The wildcard mirror redirects remote dependency and plugin repository resolution; it does not replace Maven's local cache or automatically change deployment destinations. Use `mvn -s` to select this separate settings file.

## Enterprise use
Developer laptops, Jenkins agents, GitHub Actions and other build servers can use a standardized resolution endpoint. Internal artifacts resolve from the local member; external artifacts resolve through the remote member and its cache.

## Next verification
Run Maven with the new settings and an isolated local Maven cache; inspect download URLs and Artifactory cache. No successful resolution claimed yet.

## Interview notes
Why match server and mirror IDs? Maven uses the repository ID to select authentication. Why use a separate settings file? Avoid disrupting existing working configuration while testing the new resolution path.

## Where to obtain configuration snippets
User confirmed saving settings-jfrog.xml. JFrog Artifactory's Set Me Up feature provides repository-specific Maven configuration examples and URLs (UI location varies by version). Maven XML structure is documented at https://maven.apache.org/settings.html and mirror syntax at https://maven.apache.org/guides/mini/guide-mirror-settings.html. The server/mirror ID jfrog-maven is our chosen identifier; environment variable names and wildcard mirror are our customizations. Never commit generated credentials. Set Me Up is also useful for other package types.

## Credential troubleshooting and reuse
A new PowerShell session showed an empty JFROG_USER and Token configured: False. Existing credentials were restored using the commands below; user confirmed maven-deployer and Token configured: True. Token presence is verified, but server authentication remains to be tested.

```powershell
$env:JFROG_USER = "maven-deployer"
$secureToken = Read-Host "Enter existing JFrog access token" -AsSecureString
$env:JFROG_TOKEN = [System.Net.NetworkCredential]::new("", $secureToken).Password
Remove-Variable secureToken
Write-Host "JFrog User: $env:JFROG_USER"
Write-Host "Token configured: $(-not [string]::IsNullOrEmpty($env:JFROG_TOKEN))"
```
Session environment variables are process-scoped and inherited by child processes. The token is masked during input but exists as plaintext in the process environment. Reuse a valid token when its scope permits the required permissions; never commit or print it.

## Build verification command (pending)
```powershell
mvn -s "$env:USERPROFILE\.m2\settings-jfrog.xml" "-Dmaven.repo.local=$env:USERPROFILE\.m2\repository-jfrog-test" clean package
```
An isolated initially empty local cache forces dependency downloads without deleting the existing Maven cache. Check download URLs for maven-virtual and BUILD SUCCESS. This models a fresh developer or CI build agent.

## Successful build verification — 2026-11-24
User supplied Maven logs showing downloads from https://trialgccoro.jfrog.io/artifactory/maven-virtual/ and BUILD SUCCESS, total time 02:22 min, finished 12:34:31 +05:30. Generated target/maven-docker-artifactory-1.0.7.jar. Example resolved packages: commons-compress 1.28.0, commons-codec 1.19.0, commons-lang3 3.18.0, commons-io 2.21.0, aircompressor 0.27, xz 1.10, zstd-jni 1.5.7-6. Existing token authentication and virtual endpoint resolution succeeded. Server-side cache inspection remains pending.

## Next step — inspect remote cache
In Artifactory > Artifacts, locate maven-central-remote-cache (or expand the remote repository cache in the UI) and inspect org/apache/commons/commons-compress/1.28.0/commons-compress-1.28.0.jar. Maven's local cache is on the client; Artifactory's remote cache is shared on the server. A repeat build with the same client cache does not prove server-side caching. Inspect the actual server cache before declaring this verified.

## Completion
User confirmed locating the requested artifact in the server-side remote cache. Phases 05 and 06 are complete based on user confirmation and supplied successful Maven build logs. Next: Docker Hub proxy and caching.
