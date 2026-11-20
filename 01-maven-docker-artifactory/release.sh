#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ -z "${JFROG_USER:-}" || -z "${JFROG_TOKEN:-}" ]]; then
    echo "ERROR: JFROG_USER and JFROG_TOKEN are required." >&2
    exit 1
fi
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is unavailable." >&2
    exit 1
fi
if [[ ! -f .mvn/settings.xml ]]; then
    echo "ERROR: Missing .mvn/settings.xml" >&2
    exit 1
fi

current_version="$(mvn -q -s .mvn/settings.xml help:evaluate -Dexpression=project.version -DforceStdout)"
if [[ ! "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "ERROR: Unsupported version: $current_version" >&2
    exit 1
fi
new_version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.$((10#${BASH_REMATCH[3]} + 1))"
echo "Releasing $current_version -> $new_version"

mvn -B -ntp -s .mvn/settings.xml versions:set "-DnewVersion=$new_version" -DgenerateBackupPoms=false

docker build --progress=plain \
    --secret 'id=maven_settings,src=.mvn/settings.xml' \
    --secret 'id=jfrog_user,env=JFROG_USER' \
    --secret 'id=jfrog_token,env=JFROG_TOKEN' \
    -t "maven-demo:$new_version" .

echo "Release build finished: $new_version; verify artifacts in JFrog."
