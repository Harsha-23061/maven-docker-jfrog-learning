
#!/usr/bin/env bash

set -Eeuo pipefail

trap 'echo "ERROR: Integrity verification failed at line $LINENO" >&2' ERR

# --------------------------------------------------
# 1. Input parameters
# --------------------------------------------------

ENVIRONMENT="${1:?Environment is required}"
BASELINE="${2:?Baseline JSON file is required}"
BUILD_INVENTORY="${3:?Build inventory JSON is required}"
EVIDENCE_DIR="${4:?Evidence directory is required}"

: "${JFROG_SERVER_ID:?JFROG_SERVER_ID is required}"
: "${JFROG_USER:?JFROG_USER is required}"
: "${JFROG_TOKEN:?JFROG_TOKEN is required}"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

pass() {
    echo "PASS: $*"
}

case "$ENVIRONMENT" in
    DEV|QA|PROD) ;;
    *) fail "Unsupported environment: $ENVIRONMENT" ;;
esac

for cmd in jq jf docker sha256sum awk; do
    command -v "$cmd" >/dev/null 2>&1 ||
        fail "Required command not found: $cmd"
done

test -f "$BASELINE" ||
    fail "Baseline configuration missing"

test -f "$BUILD_INVENTORY" ||
    fail "Original build inventory missing"

mkdir -p "$EVIDENCE_DIR/maven"

# --------------------------------------------------
# 2. Read trusted release configuration
# --------------------------------------------------

RELEASE_BUNDLE=$(jq -er '.release.bundle_name' "$BASELINE")
RELEASE_VERSION=$(jq -er '.release.bundle_version' "$BASELINE")
ARTIFACT_VERSION=$(jq -er '.release.artifact_version' "$BASELINE")

BUILD_NAME=$(jq -er '.source_build.name' "$BASELINE")
BUILD_NUMBER=$(jq -er '.source_build.number' "$BASELINE")

REGISTRY=$(jq -er '.jfrog.registry' "$BASELINE")

MAVEN_PATH=$(jq -er '.maven.repository_path' "$BASELINE")
ARTIFACT_ID=$(jq -er '.maven.artifact_id' "$BASELINE")

EXPECTED_JAR=$(jq -er '.maven.jar_sha256' "$BASELINE")
EXPECTED_POM=$(jq -er '.maven.pom_sha256' "$BASELINE")

IMAGE_NAME=$(jq -er '.docker.image_name' "$BASELINE")
EXPECTED_DIGEST=$(jq -er '.docker.digest' "$BASELINE")

EXPECTED_MAVEN=$(jq -er '.inventory.expected_maven_artifacts' "$BASELINE")
EXPECTED_DOCKER=$(jq -er '.inventory.expected_docker_artifacts' "$BASELINE")
EXPECTED_TOTAL=$(jq -er '.inventory.expected_total_artifacts' "$BASELINE")

MAVEN_REPO=$(jq -er \
    --arg env "$ENVIRONMENT" \
    '.environments[$env].maven_repository' "$BASELINE")

DOCKER_REPO=$(jq -er \
    --arg env "$ENVIRONMENT" \
    '.environments[$env].docker_repository' "$BASELINE")

EXPECTED_USER=$(jq -er \
    --arg env "$ENVIRONMENT" \
    '.environments[$env].expected_user' "$BASELINE")

[[ "$EXPECTED_JAR" =~ ^[a-f0-9]{64}$ ]] ||
    fail "Invalid JAR checksum"

[[ "$EXPECTED_POM" =~ ^[a-f0-9]{64}$ ]] ||
    fail "Invalid POM checksum"

[[ "$EXPECTED_DIGEST" =~ ^sha256:[a-f0-9]{64}$ ]] ||
    fail "Invalid Docker digest"

[[ "$JFROG_USER" == "$EXPECTED_USER" ]] ||
    fail "Unexpected JFrog identity"

[[ "$EXPECTED_MAVEN" == "2" ]] ||
    fail "Unsupported Maven artifact count"

[[ "$EXPECTED_DOCKER" == "13" ]] ||
    fail "Unexpected Docker artifact count"

[[ "$EXPECTED_TOTAL" == "15" ]] ||
    fail "Unexpected total artifact count"

echo "=========================================="
echo "Enterprise Integrity Verification"
echo "Environment: $ENVIRONMENT"
echo "Release: $RELEASE_BUNDLE/$RELEASE_VERSION"
echo "Build: $BUILD_NAME/$BUILD_NUMBER"
echo "Artifact version: $ARTIFACT_VERSION"
echo "=========================================="

pass "Release configuration validated"

# --------------------------------------------------
# 3. Validate original build inventory
# --------------------------------------------------

jq -e \
    --argjson total "$EXPECTED_TOTAL" \
    --argjson docker "$EXPECTED_DOCKER" \
    --argjson maven "$EXPECTED_MAVEN" \
    '
    type == "array" and
    length == $total and
    ([.[] | select(.type == "docker")] | length) == $docker and
    ([.[] | select(.type == "generic")] | length) == $maven and
    all(.[];
        (.name | type == "string") and
        (.sha256 | type == "string") and
        (.sha256 | test("^[a-f0-9]{64}$"))
    )
    ' "$BUILD_INVENTORY" >/dev/null ||
    fail "Invalid original build inventory"

jq -e \
    --arg jar "$EXPECTED_JAR" \
    --arg pom "$EXPECTED_POM" \
    --arg digest "${EXPECTED_DIGEST#sha256:}" \
    '
    any(.[]; .type == "generic" and .sha256 == $jar) and
    any(.[]; .type == "generic" and .sha256 == $pom) and
    any(.[]; .type == "docker" and .sha256 == $digest)
    ' "$BUILD_INVENTORY" >/dev/null ||
    fail "Build inventory does not match release baseline"

pass "Original build inventory validated"

# --------------------------------------------------
# 4. Verify JFrog connectivity
# --------------------------------------------------

jf rt ping --server-id="$JFROG_SERVER_ID"

for repo in "$MAVEN_REPO" "$DOCKER_REPO"; do

    jf rt curl -f -XGET \
        "/api/storage/$repo" \
        --server-id="$JFROG_SERVER_ID" \
        >/dev/null

    pass "Repository read access: $repo"

done

# --------------------------------------------------
# 5. Download and verify Maven artifacts
# --------------------------------------------------

MAVEN_RESULTS="$EVIDENCE_DIR/maven-results.ndjson"

: > "$MAVEN_RESULTS"

for extension in jar pom; do

    FILE_NAME="${ARTIFACT_ID}-${ARTIFACT_VERSION}.${extension}"

    SOURCE="${MAVEN_REPO}/${MAVEN_PATH}/${ARTIFACT_VERSION}/${FILE_NAME}"

    TARGET="$EVIDENCE_DIR/maven/$FILE_NAME"

    rm -f -- "$TARGET"

    jf rt dl "$SOURCE" "$EVIDENCE_DIR/maven/" \
        --server-id="$JFROG_SERVER_ID" \
        --flat=true \
        --fail-no-op=true

    test -f "$TARGET" ||
        fail "Downloaded artifact missing: $FILE_NAME"

    ACTUAL_HASH=$(sha256sum "$TARGET" | awk '{print $1}')

    if [[ "$extension" == "jar" ]]; then
        EXPECTED_HASH="$EXPECTED_JAR"
    else
        EXPECTED_HASH="$EXPECTED_POM"
    fi

    [[ "$ACTUAL_HASH" == "$EXPECTED_HASH" ]] ||
        fail "Maven checksum mismatch: $FILE_NAME"

    jq -n \
        --arg env "$ENVIRONMENT" \
        --arg repo "$MAVEN_REPO" \
        --arg artifact "$FILE_NAME" \
        --arg expected "$EXPECTED_HASH" \
        --arg actual "$ACTUAL_HASH" \
        '{
            environment: $env,
            repository: $repo,
            artifact: $artifact,
            expected_sha256: $expected,
            actual_sha256: $actual,
            status: "PASSED"
        }' >> "$MAVEN_RESULTS"

    pass "Maven SHA256: $FILE_NAME"

done

jq -s '.' "$MAVEN_RESULTS" \
    > "$EVIDENCE_DIR/maven-integrity.json"

# --------------------------------------------------
# 6. Verify Docker image index digest
# --------------------------------------------------

DOCKER_CONFIG=$(mktemp -d)
export DOCKER_CONFIG

cleanup() {
    docker logout "$REGISTRY" >/dev/null 2>&1 || true
    rm -rf -- "$DOCKER_CONFIG"
}

trap cleanup EXIT

printf '%s' "$JFROG_TOKEN" |
    docker login "$REGISTRY" \
        --username "$JFROG_USER" \
        --password-stdin

IMAGE="$REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$ARTIFACT_VERSION"

docker buildx imagetools inspect "$IMAGE" \
    > "$EVIDENCE_DIR/docker-inspect.txt"

ACTUAL_DIGEST=$(awk \
    '$1 == "Digest:" {print $2; exit}' \
    "$EVIDENCE_DIR/docker-inspect.txt")

[[ "$ACTUAL_DIGEST" == "$EXPECTED_DIGEST" ]] ||
    fail "Docker image digest mismatch"

jq -n \
    --arg env "$ENVIRONMENT" \
    --arg image "$IMAGE" \
    --arg expected "$EXPECTED_DIGEST" \
    --arg actual "$ACTUAL_DIGEST" \
    '{
        environment: $env,
        image: $image,
        expected_digest: $expected,
        actual_digest: $actual,
        status: "PASSED"
    }' > "$EVIDENCE_DIR/docker-digest.json"

pass "Docker image index digest verified"

# --------------------------------------------------
# 7. Retrieve complete Docker repository inventory
# --------------------------------------------------

jf rt s "$DOCKER_REPO/$IMAGE_NAME/*" \
    --server-id="$JFROG_SERVER_ID" \
    --recursive=true \
    > "$EVIDENCE_DIR/docker-repository-inventory.json"

jq -e 'type == "array" and length > 0' \
    "$EVIDENCE_DIR/docker-repository-inventory.json" \
    >/dev/null ||
    fail "Docker repository inventory is empty or invalid"

# --------------------------------------------------
# 8. Compare original Docker artifact checksums
# --------------------------------------------------

jq \
    --arg env "$ENVIRONMENT" \
    --slurpfile repo "$EVIDENCE_DIR/docker-repository-inventory.json" \
    '
    [
        .[]
        | select(.type == "docker")
        | . as $artifact
        | [
            $repo[0][]
            | select(.sha256 == $artifact.sha256)
            | .path
          ] as $matches
        | {
            environment: $env,
            module: $artifact.module,
            artifact: $artifact.name,
            expected_sha256: $artifact.sha256,
            match_count: ($matches | length),
            matched_paths: $matches,
            status: (
                if ($matches | length) > 0
                then "PASSED"
                else "NOT_FOUND"
                end
            )
        }
    ]
    ' "$BUILD_INVENTORY" \
    > "$EVIDENCE_DIR/docker-artifact-comparison.json"

jq -e \
    --argjson expected "$EXPECTED_DOCKER" \
    '
    length == $expected and
    all(.[]; .status == "PASSED")
    ' "$EVIDENCE_DIR/docker-artifact-comparison.json" \
    >/dev/null ||
    fail "Docker artifact inventory verification failed"

pass "All $EXPECTED_DOCKER Docker artifact checksums found"

# --------------------------------------------------
# 9. Final integrity gate
# --------------------------------------------------

MAVEN_COUNT=$(jq 'length' \
    "$EVIDENCE_DIR/maven-integrity.json")

DOCKER_COUNT=$(jq 'length' \
    "$EVIDENCE_DIR/docker-artifact-comparison.json")

TOTAL_COUNT=$((MAVEN_COUNT + DOCKER_COUNT))

[[ "$MAVEN_COUNT" -eq "$EXPECTED_MAVEN" ]] ||
    fail "Unexpected Maven verification count"

[[ "$DOCKER_COUNT" -eq "$EXPECTED_DOCKER" ]] ||
    fail "Unexpected Docker verification count"

[[ "$TOTAL_COUNT" -eq "$EXPECTED_TOTAL" ]] ||
    fail "Unexpected total verification count"

# --------------------------------------------------
# 10. Generate environment audit summary
# --------------------------------------------------

VERIFIED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq -n \
    --arg env "$ENVIRONMENT" \
    --arg bundle "$RELEASE_BUNDLE" \
    --arg release "$RELEASE_VERSION" \
    --arg build "$BUILD_NUMBER" \
    --arg version "$ARTIFACT_VERSION" \
    --arg jar "$EXPECTED_JAR" \
    --arg pom "$EXPECTED_POM" \
    --arg digest "$ACTUAL_DIGEST" \
    --arg verified "$VERIFIED_AT" \
    --argjson maven "$MAVEN_COUNT" \
    --argjson docker "$DOCKER_COUNT" \
    --argjson total "$TOTAL_COUNT" \
    '{
        environment: $env,
        release_bundle: $bundle,
        release_version: $release,
        build_number: $build,
        artifact_version: $version,
        maven_artifacts_verified: $maven,
        docker_artifacts_verified: $docker,
        total_artifacts_verified: $total,
        failed_artifacts: 0,
        jar_sha256: $jar,
        pom_sha256: $pom,
        docker_digest: $digest,
        maven_integrity: "PASSED",
        docker_digest_integrity: "PASSED",
        docker_inventory_integrity: "PASSED",
        overall_status: "PASSED",
        verified_at_utc: $verified
    }' > "$EVIDENCE_DIR/environment-summary.json"

cat "$EVIDENCE_DIR/environment-summary.json"

echo "=========================================="
pass "$ENVIRONMENT integrity verification"
echo "Maven artifacts: $MAVEN_COUNT"
echo "Docker artifacts: $DOCKER_COUNT"
echo "Total artifacts: $TOTAL_COUNT"
echo "Failed artifacts: 0"
echo "=========================================="
