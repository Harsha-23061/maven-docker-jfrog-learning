# Phase 12 — Security policies, watches and build gates

Policies define security rules; watches apply them to selected resources; violations are findings that breach applicable rules. Build gates stop pipeline progression when configured blocking conditions are met. Target: detect High and Critical vulnerabilities in docker-trial, evaluate with a watch, and later configure and verify blocking behavior.

## Step 1 (pending)
Navigate Platform > Security & Compliance > Policies > New Policy. Name: enterprise-security-policy. Type: Security. Description: Detect high and critical vulnerabilities in enterprise artifacts. Name and description are project choices. Rule and blocking actions will be configured next. No policy enforcement verified yet.
