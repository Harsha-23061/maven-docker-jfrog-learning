$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not $env:JFROG_USER -or -not $env:JFROG_TOKEN) {
    throw 'JFROG_USER and JFROG_TOKEN are required.'
}
if (-not (Test-Path '.mvn/settings.xml')) {
    throw 'Missing .mvn/settings.xml. Copy settings.xml.example and keep secrets in environment variables.'
}
docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker is unavailable. Start Docker Desktop.'
}

[xml]$pom = Get-Content 'pom.xml' -Raw
$currentVersion = [string]$pom.project.version
if ($currentVersion -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
    throw "Unsupported version: $currentVersion"
}
$newVersion = "$($Matches[1]).$($Matches[2]).$([int]$Matches[3] + 1)"
Write-Host "Releasing $currentVersion -> $newVersion"

mvn -B -ntp -s .mvn/settings.xml versions:set "-DnewVersion=$newVersion" '-DgenerateBackupPoms=false'
if ($LASTEXITCODE -ne 0) { throw 'Maven version update failed.' }

docker build --progress=plain `
    --secret 'id=maven_settings,src=.mvn/settings.xml' `
    --secret id=jfrog_user,env=JFROG_USER `
    --secret id=jfrog_token,env=JFROG_TOKEN `
    -t "maven-demo:$newVersion" .
if ($LASTEXITCODE -ne 0) {
    throw 'Docker build or JFrog deployment failed. Check whether the version was published before retrying.'
}
Write-Host "Release build finished: $newVersion. Verify artifacts in JFrog."
