param(
    [switch]$Execute
)

$ErrorActionPreference = "Stop"

$PhaseRoot = Split-Path $PSScriptRoot -Parent
$Namespace = "enterprise-prod"

function Invoke-Checked {
    param(
        [string]$Command,
        [string[]]$Arguments
    )

    $Result = & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $Command"
    }

    return $Result
}

function Write-Pass {
    param([string]$Message)

    Write-Host "PASS: $Message" -ForegroundColor Green
}

# --------------------------------------------------
# 1. Load approved release configuration
# --------------------------------------------------

$BaselineFile = Join-Path $PhaseRoot "config/release-baseline.json"

$Config = Get-Content $BaselineFile -Raw |
    ConvertFrom-Json

$ReleaseVersion = $Config.release.bundle_version
$Registry = $Config.jfrog.registry
$ProdRepo = $Config.environments.PROD.docker_repository
$ImageName = $Config.docker.image_name
$Digest = $Config.docker.digest

$ApprovedImage = "$Registry/$ProdRepo/$ImageName@$Digest"

if ($Digest -cnotmatch '^sha256:[a-f0-9]{64}$') {
    throw "Invalid approved image digest"
}

if ($ReleaseVersion -notmatch '^\d+\.\d+\.\d+$') {
    throw "Invalid release version"
}

$ReleaseSlug = $ReleaseVersion.Replace(".", "-")
$JobName = "enterprise-demo-release-$ReleaseSlug"

$Timestamp = [DateTime]::UtcNow.ToString("yyyyMMdd-HHmmss-fff")

$EvidenceRoot = Join-Path $PhaseRoot `
    "evidence/deployment-$ReleaseVersion/$Timestamp"

New-Item -ItemType Directory `
    -Path $EvidenceRoot -Force | Out-Null

$CredentialRoot = $null
$DeploymentStatus = "FAILED"
$JobCreated = $false

try {

    Write-Host ""
    Write-Host "ENTERPRISE PRODUCTION DEPLOYMENT" `
        -ForegroundColor Cyan

    Write-Host "Release: $ReleaseVersion"
    Write-Host "Image: $ApprovedImage"
    Write-Host "Job: $JobName"

    # --------------------------------------------------
    # 2. Verify GitHub release provenance
    # --------------------------------------------------

    $Repository = $Config.github.repository

    $ProductionRunId = `
        $Config.github.production_promotion_run_id

    $ProductionRun = (
        Invoke-Checked -Command "gh" -Arguments @(
            "api",
            "repos/$Repository/actions/runs/$ProductionRunId"
        )
    ) -join "`n" | ConvertFrom-Json

    if (
        $ProductionRun.status -ne "completed" -or
        $ProductionRun.conclusion -ne "success" -or
        $ProductionRun.head_branch -ne "main" -or
        $ProductionRun.head_repository.full_name -ne $Repository -or
        $ProductionRun.run_attempt -ne
            $Config.github.production_promotion_run_attempt -or
        $ProductionRun.path -ne
            ".github/workflows/enterprise-release-prod-promotion.yml"
    ) {
        throw "Production promotion provenance verification failed"
    }

    Write-Pass "Production promotion verified"

    $ProductionEvidence = Join-Path $EvidenceRoot "promotion"

    New-Item -ItemType Directory `
        -Path $ProductionEvidence -Force | Out-Null

    $ArtifactName = "production-release-evidence-$ProductionRunId-$($ProductionRun.run_attempt)"

    Invoke-Checked -Command "gh" -Arguments @(
        "run", "download", "$ProductionRunId",
        "--repo", $Repository,
        "--name", $ArtifactName,
        "--dir", $ProductionEvidence
    ) | Out-Null

    $PromotionFile = Join-Path $ProductionEvidence "prod-validation.json"

    $Promotion = Get-Content $PromotionFile -Raw |
        ConvertFrom-Json

    if (
        $Promotion.release_bundle -ne $Config.release.bundle_name -or
        $Promotion.release_version -ne $ReleaseVersion -or
        $Promotion.build_number -ne $Config.source_build.number -or
        $Promotion.artifact_version -ne $Config.release.artifact_version -or
        $Promotion.environment -ne "PROD" -or
        $Promotion.github_run_id -ne $ProductionRunId -or
        $Promotion.github_run_attempt -ne $ProductionRun.run_attempt -or
        $Promotion.promotion -ne "PASSED" -or
        $Promotion.qa_validation -ne "PASSED" -or
        $Promotion.security_gate -ne "PASSED" -or
        $Promotion.integrity_validation -ne "PASSED" -or
        $Promotion.jar_sha256 -ne $Config.maven.jar_sha256 -or
        $Promotion.pom_sha256 -ne $Config.maven.pom_sha256 -or
        $Promotion.docker_digest -ne $Digest
    ) {
        throw "Production release evidence verification failed"
    }

    Write-Pass "Production release evidence matches baseline"

    # Verified integrity run for this lab release

    $IntegrityRunId = "45929475846"

    $IntegrityRun = (
        Invoke-Checked -Command "gh" -Arguments @(
            "api",
            "repos/$Repository/actions/runs/$IntegrityRunId"
        )
    ) -join "`n" | ConvertFrom-Json

    if (
        $IntegrityRun.status -ne "completed" -or
        $IntegrityRun.conclusion -ne "success" -or
        $IntegrityRun.run_attempt -ne 1 -or
        $IntegrityRun.head_branch -ne "main" -or
        $IntegrityRun.head_repository.full_name -ne $Repository -or
        $IntegrityRun.path -ne
            ".github/workflows/enterprise-integrity-verification.yml"
    ) {
        throw "Integrity workflow verification failed"
    }

    Write-Pass "Enterprise integrity workflow verified"

    # --------------------------------------------------
    # 3. Verify Kubernetes readiness
    # --------------------------------------------------

    $Context = Invoke-Checked -Command "kubectl" `
        -Arguments @("config", "current-context")

    if ($Context -ne "minikube") {
        throw "Unexpected Kubernetes context: $Context"
    }

    Invoke-Checked -Command "kubectl" `
        -Arguments @("get", "--raw=/readyz") |
        Out-Null

    Write-Pass "Kubernetes API is ready"

    $NamespaceInfo = (
        Invoke-Checked -Command "kubectl" -Arguments @(
            "get", "namespace", $Namespace, "-o", "json"
        )
    ) -join "`n" | ConvertFrom-Json

    if (
        $NamespaceInfo.metadata.labels.
            'pod-security.kubernetes.io/enforce' -ne "restricted"
    ) {
        throw "Restricted Pod Security is not enabled"
    }

    Write-Pass "Restricted Pod Security enabled"

    $Resources = @(
        "serviceaccount/enterprise-deployer",
        "serviceaccount/enterprise-runtime",
        "role/enterprise-deployment-role",
        "rolebinding/enterprise-deployer-binding",
        "resourcequota/enterprise-production-quota",
        "limitrange/enterprise-container-limits",
        "networkpolicy/enterprise-default-deny"
    )

    foreach ($Resource in $Resources) {

        Invoke-Checked -Command "kubectl" -Arguments @(
            "get", $Resource, "-n", $Namespace
        ) | Out-Null

        Write-Pass "$Resource exists"
    }

    $PolicyResources = @(
        "validatingadmissionpolicy/enterprise-deployment-security",
        "validatingadmissionpolicy/enterprise-job-execution-policy",
        "validatingadmissionpolicybinding/enterprise-deployment-security-binding",
        "validatingadmissionpolicybinding/enterprise-job-execution-binding"
    )

    foreach ($Resource in $PolicyResources) {

        Invoke-Checked -Command "kubectl" -Arguments @(
            "get", $Resource
        ) | Out-Null

        Write-Pass "$Resource exists"
    }

    $SecretType = Invoke-Checked -Command "kubectl" -Arguments @(
        "get", "secret", "jfrog-registry-secret",
        "-n", $Namespace,
        "-o", "jsonpath={.type}"
    )

    if ($SecretType -ne "kubernetes.io/dockerconfigjson") {
        throw "Invalid registry Secret type"
    }

    Write-Pass "Registry Secret available"

    $ExistingJob = Invoke-Checked -Command "kubectl" -Arguments @(
        "get", "job", $JobName,
        "-n", $Namespace,
        "--ignore-not-found",
        "-o", "name"
    )

    if ($ExistingJob) {
        throw "Job already exists. Deployment will not overwrite it."
    }

    # --------------------------------------------------
    # 4. Render production manifest
    # --------------------------------------------------

    $TemplateFile = Join-Path $PhaseRoot `
        "kubernetes/deployment/production-job-template.yaml"

    $ManifestFile = Join-Path $EvidenceRoot "production-job.yaml"

    $Template = Get-Content $TemplateFile -Raw

    $RenderedManifest = $Template.Replace(
        "__JOB_NAME__", $JobName
    ).Replace(
        "__RELEASE_VERSION__", $ReleaseVersion
    ).Replace(
        "__APPROVED_IMAGE__", $ApprovedImage
    )

    $RenderedManifest |
        Set-Content $ManifestFile -Encoding ascii

    Write-Pass "Production manifest rendered"

    # --------------------------------------------------
    # 5. Generate temporary deployment credentials
    # --------------------------------------------------

    $AdminConfig = (
        Invoke-Checked -Command "kubectl" -Arguments @(
            "config", "view", "--raw", "--minify",
            "--flatten", "-o", "json"
        )
    ) -join "`n" | ConvertFrom-Json

    $Cluster = $AdminConfig.clusters[0].cluster

    $ApiServer = $Cluster.server
    $CAData = $Cluster.'certificate-authority-data'

    if (-not $CAData -or $ApiServer -notmatch '^https://') {
        throw "Secure cluster connection configuration missing"
    }

    $CredentialRoot = Join-Path $env:TEMP `
        ("enterprise-deploy-" + [Guid]::NewGuid().ToString())

    New-Item -ItemType Directory `
        -Path $CredentialRoot | Out-Null

    $DeployKubeconfig = Join-Path $CredentialRoot "config.json"

    $Token = Invoke-Checked -Command "kubectl" -Arguments @(
        "create", "token", "enterprise-deployer",
        "-n", $Namespace,
        "--duration=15m"
    )

    $TemporaryConfig = @{
        apiVersion = "v1"
        kind = "Config"

        clusters = @(
            @{
                name = "enterprise-cluster"
                cluster = @{
                    server = $ApiServer
                    "certificate-authority-data" = $CAData
                }
            }
        )

        users = @(
            @{
                name = "enterprise-deployer"
                user = @{
                    token = $Token
                }
            }
        )

        contexts = @(
            @{
                name = "enterprise-deployment"
                context = @{
                    cluster = "enterprise-cluster"
                    user = "enterprise-deployer"
                    namespace = $Namespace
                }
            }
        )

        "current-context" = "enterprise-deployment"
    }

    $TemporaryConfig |
        ConvertTo-Json -Depth 10 |
        Set-Content $DeployKubeconfig -Encoding ascii

    $Token = $null
    $TemporaryConfig = $null
    $AdminConfig = $null

    $KubeArgs = @(
        "--kubeconfig=$DeployKubeconfig",
        "-n", $Namespace
    )

    $Identity = (
        Invoke-Checked -Command "kubectl" -Arguments (
            $KubeArgs + @("auth", "whoami", "-o", "json")
        )
    ) -join "`n" | ConvertFrom-Json

    $ExpectedIdentity = "system:serviceaccount:enterprise-prod:enterprise-deployer"

    if ($Identity.status.userInfo.username -ne $ExpectedIdentity) {
        throw "Unexpected deployment identity"
    }

    Write-Pass "Short-lived deployment authentication"

    # --------------------------------------------------
    # 6. Server-side dry run
    # --------------------------------------------------

    Invoke-Checked -Command "kubectl" -Arguments (
        $KubeArgs + @(
            "create", "--dry-run=server",
            "-f", $ManifestFile
        )
    )

    Write-Pass "Server-side deployment validation"

    if (-not $Execute) {

        $DeploymentStatus = "DRY_RUN_PASSED"

        Write-Host "Dry run completed. No Job created." `
            -ForegroundColor Cyan

        return
    }

    # --------------------------------------------------
    # 7. Create production Job
    # --------------------------------------------------

    Invoke-Checked -Command "kubectl" -Arguments (
        $KubeArgs + @("create", "-f", $ManifestFile)
    )

    $JobCreated = $true

    Write-Pass "Production Job created"

    # --------------------------------------------------
    # 8. Wait for Job completion
    # --------------------------------------------------

    Invoke-Checked -Command "kubectl" -Arguments (
        $KubeArgs + @(
            "wait",
            "--for=condition=complete",
            "job/$JobName",
            "--timeout=240s"
        )
    )

    Write-Pass "Production Job completed"

    # --------------------------------------------------
    # 9. Verify application output
    # --------------------------------------------------

    $ApplicationLogs = @(
        Invoke-Checked -Command "kubectl" -Arguments (
            $KubeArgs + @("logs", "job/$JobName")
        )
    )

    $ApplicationLogs |
        Set-Content "$EvidenceRoot/application.log" -Encoding utf8

    $ApplicationLogs

    $ExpectedOutput = @($Config.runtime.expected_output)

    if (
        ($ApplicationLogs -join "`n") -cne
        ($ExpectedOutput -join "`n")
    ) {
        throw "Application output validation failed"
    }

    Write-Pass "Application output verified"

    # --------------------------------------------------
    # 10. Capture runtime evidence
    # --------------------------------------------------

    $JobJson = (
        Invoke-Checked -Command "kubectl" -Arguments (
            $KubeArgs + @("get", "job", $JobName, "-o", "json")
        )
    ) -join "`n"

    $JobJson |
        Set-Content "$EvidenceRoot/job-status.json" -Encoding utf8

    $Job = $JobJson | ConvertFrom-Json

    if ($Job.status.succeeded -ne 1) {
        throw "Unexpected Job completion count"
    }

    $PodJson = (
        Invoke-Checked -Command "kubectl" -Arguments (
            $KubeArgs + @(
                "get", "pods",
                "-l", "batch.kubernetes.io/job-name=$JobName",
                "-o", "json"
            )
        )
    ) -join "`n"

    $PodJson |
        Set-Content "$EvidenceRoot/pod-status.json" -Encoding utf8

    $Pods = $PodJson | ConvertFrom-Json

    if (@($Pods.items).Count -ne 1) {
        throw "Unexpected number of application Pods"
    }

    $Pod = $Pods.items[0]

    $Container = $Pod.status.containerStatuses[0]

    if (
        $Pod.status.phase -ne "Succeeded" -or
        $Container.state.terminated.exitCode -ne 0 -or
        $Container.restartCount -ne 0 -or
        $Pod.spec.containers[0].image -ne $ApprovedImage -or
        $Pod.spec.serviceAccountName -ne "enterprise-runtime" -or
        $Pod.spec.automountServiceAccountToken -ne $false
    ) {
        throw "Runtime verification failed"
    }

    Write-Pass "Pod runtime verification"

    $DeploymentStatus = "PASSED"

}
finally {

    # --------------------------------------------------
    # 11. Remove temporary credentials
    # --------------------------------------------------

    if (
        $CredentialRoot -and
        (Test-Path $CredentialRoot)
    ) {
        Remove-Item $CredentialRoot -Recurse -Force

        Write-Pass "Temporary credential files removed"
    }

    # --------------------------------------------------
    # 12. Generate deployment summary
    # --------------------------------------------------

    $Summary = [ordered]@{
        ReleaseVersion = $ReleaseVersion
        Namespace = $Namespace
        JobName = $JobName
        ApprovedImage = $ApprovedImage
        ProductionRunId = $Config.github.production_promotion_run_id
        IntegrityRunId = "45929475846"
        ExecuteRequested = [bool]$Execute
        JobCreated = $JobCreated
        Status = $DeploymentStatus
        NetworkPolicyEnforcement = "NOT_VERIFIED"
        TimestampUTC = [DateTime]::UtcNow.ToString("o")
    }

    $Summary |
        ConvertTo-Json -Depth 10 |
        Set-Content "$EvidenceRoot/deployment-summary.json" `
            -Encoding utf8

    Write-Host ""
    Write-Host "Deployment summary" -ForegroundColor Cyan

    [PSCustomObject]$Summary | Format-List

    Write-Host "Evidence directory: $EvidenceRoot"
}
