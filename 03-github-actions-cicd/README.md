# Exercise 03 — GitHub Actions Maven CI

## Goal
Build and test the Java 17 Maven application automatically on pushes and pull requests. **No JFrog credentials or deployment are used in this first milestone.**

## Files
- Workflow: [`.github/workflows/maven-ci.yml`](../.github/workflows/maven-ci.yml)
- Maven project: [`01-maven-docker-artifactory/`](../01-maven-docker-artifactory/)

## How it works
1. GitHub Actions checks out the repository.
2. It installs Temurin JDK 17 and enables Maven dependency caching.
3. It runs `mvn -B -ntp clean verify` from the exercise 01 project directory.
4. The job succeeds only if Maven verification succeeds.

The workflow runs when project files or the workflow itself change on `main`, on matching pull requests, or when started manually from **Actions → Exercise 03 - Maven CI → Run workflow**.

## First verification
Open the repository's **Actions** tab, select **Exercise 03 - Maven CI**, and inspect the newest run. A green check means the CI build passed. If it fails, inspect the `Build and run tests` step.

## Important notes
The GitHub sample POM and Java source in Exercise 01 were reconstructed from prior guidance and may not match the exact local IntelliJ project. This CI job verifies what is **committed to GitHub**, not unpushed local changes. The current sample has no automated test cases, so `verify` confirms build lifecycle success but not substantive test coverage.

## Next milestone
After confirming CI succeeds, add JFrog deployment with GitHub Actions secrets, scoped user permissions, and release safeguards. Never commit a real access token.
