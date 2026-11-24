#!/usr/bin/env bash
# Enterprise CI stages. Each function does one job and exits on errors.
set -euo pipefail

APP_DIR="01-maven-docker-artifactory"
STAGING="staging"
REGISTRY="trialgccoro.jfrog.io"
MAVEN_REPO="$REGISTRY/artifactory/libs-release-local"
IMAGE_REPO="$REGISTRY/docker-trial/enterprise-demo"

require_credentials() {
  : "${JFROG_USER:?Missing JFROG_USER}"
  : "${JFROG_TOKEN:?Missing JFROG_TOKEN}"
}

build() {
  local version="1.0.7-ci-${GITHUB_RUN_ID:?}-${GITHUB_RUN_ATTEMPT:?}"
  (cd "$APP_DIR" &&
    mvn -B -ntp versions:set "-DnewVersion=$version" -DgenerateBackupPoms=false &&
    mvn -B -ntp clean verify)
  test -f "$APP_DIR/target/surefire-reports/TEST-com.example.MainTest.xml"
  mkdir -p "$STAGING"
  cp "$APP_DIR/target/maven-docker-artifactory-$version.jar" "$STAGING/app.jar"
  cp "$APP_DIR/pom.xml" "$STAGING/pom.xml"
  printf 'VERSION=%s\n' "$version" >> "$GITHUB_ENV"
  echo "PASS: Maven build and JUnit test report"
}

docker() {
  local sha cid
  echo "STAGE: Record JAR checksum"
  sha=$(sha256sum "$STAGING/app.jar" | cut -d ' ' -f 1)
  printf '%s  app.jar\n' "$sha" > "$STAGING/app.jar.sha256"

  echo "STAGE: Build Docker image from tested JAR"
  docker build -f 15-enterprise-cicd/Dockerfile -t "enterprise-demo:$VERSION" "$STAGING"

  echo "STAGE: Verify embedded JAR"
  cid=$(docker create "enterprise-demo:$VERSION")
  docker cp "$cid:/app/app.jar" /tmp/container-app.jar
  docker rm "$cid" >/dev/null
  cmp "$STAGING/app.jar" /tmp/container-app.jar

  echo "STAGE: Verify non-root configuration"
  test "$(docker image inspect --format '{{.Config.User}}' "enterprise-demo:$VERSION")" = "10001:10001"

  echo "STAGE: Run application smoke test"
  printf 'Hello and welcome!\ni = 1\ni = 2\ni = 3\ni = 4\ni = 5\n' > /tmp/expected-output.txt
  docker run --rm "enterprise-demo:$VERSION" > /tmp/actual-output.txt
  diff -u /tmp/expected-output.txt /tmp/actual-output.txt
  echo "PASS: Docker checksum, non-root configuration and smoke test"
}

maven_publish() {
  require_credentials
  (cd "$STAGING" && sha256sum -c app.jar.sha256)
  mvn -B -ntp -s "$APP_DIR/.mvn/settings.xml.example" \
    org.apache.maven.plugins:maven-deploy-plugin:3.1.3:deploy-file \
    "-Dfile=$STAGING/app.jar" "-DpomFile=$STAGING/pom.xml" \
    "-DrepositoryId=artifactory-release" "-Durl=https://$MAVEN_REPO" \
    -DgeneratePom=false
  local remote="https://$MAVEN_REPO/com/example/maven-docker-artifactory/$VERSION/maven-docker-artifactory-$VERSION"
  curl --fail --silent --show-error --max-time 60 --user "$JFROG_USER:$JFROG_TOKEN" "$remote.jar" -o /tmp/jfrog-app.jar
  curl --fail --silent --show-error --max-time 60 --user "$JFROG_USER:$JFROG_TOKEN" "$remote.pom" -o /tmp/jfrog-app.pom
  cmp "$STAGING/app.jar" /tmp/jfrog-app.jar
  cmp "$STAGING/pom.xml" /tmp/jfrog-app.pom
  echo "PASS: JFrog Maven JAR and POM byte verification"
}

docker_publish() {
  require_credentials
  local image="$IMAGE_REPO:$VERSION"
  printf '%s' "$JFROG_TOKEN" | docker login "$REGISTRY" --username "$JFROG_USER" --password-stdin
  trap 'docker logout "$REGISTRY" >/dev/null 2>&1 || true' RETURN
  docker tag "enterprise-demo:$VERSION" "$image"
  docker push "$image" | tee /tmp/enterprise-push.log
  local digest
  digest=$(sed -nE 's/.*digest: (sha256:[a-f0-9]{64}).*/\1/p' /tmp/enterprise-push.log | tail -n 1)
  [[ "$digest" =~ ^sha256:[a-f0-9]{64}$ ]]
  local reference="$IMAGE_REPO@$digest"
  docker pull "$reference"
  test "$(docker image inspect --format '{{.Id}}' "$reference")" = "$(docker image inspect --format '{{.Id}}' "enterprise-demo:$VERSION")"
  local cid
  cid=$(docker create "$reference")
  docker cp "$cid:/app/app.jar" /tmp/registry-app.jar
  docker rm "$cid" >/dev/null
  cmp "$STAGING/app.jar" /tmp/registry-app.jar
  printf '%s\n' "$reference" > "$STAGING/docker-image-ref.txt"
  echo "PASS: JFrog Docker digest and embedded Maven JAR"
  echo "Registry image digest: $digest"
}

case "${1:-}" in
  build) build ;;
  docker) docker ;;
  maven-publish) maven_publish ;;
  docker-publish) docker_publish ;;
  *) echo "Usage: $0 {build|docker|maven-publish|docker-publish}" >&2; exit 2 ;;
esac
