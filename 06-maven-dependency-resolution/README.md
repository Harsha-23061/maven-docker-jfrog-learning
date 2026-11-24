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
