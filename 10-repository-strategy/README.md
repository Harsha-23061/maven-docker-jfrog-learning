# Phase 10 — Enterprise repository strategy

Proposed convention: `<package>-<environment>-<type>`, a project choice rather than a JFrog requirement. DEV holds new builds, QA holds validated candidates, PROD holds approved artifacts. Promote the same artifact rather than rebuilding. Maven, Docker and Generic may each use dev/qa/prod local repositories; existing repositories remain unchanged. Other organizations may organize by team, project or release maturity.

## Step 1 (pending)
Reuse generic-dev-local. Create generic-qa-local and generic-prod-local as Generic local repositories in Administration > Repositories > Local. Leave other settings at defaults. These support later promotion of the existing generic artifact and build metadata. No need to create all nine example repositories. Creation not yet verified.
