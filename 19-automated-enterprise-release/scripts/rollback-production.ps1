param(
    [switch]$Execute
)

$ErrorActionPreference = "Stop"

$PhaseRoot = Split-Path $PSScriptRoot -Parent

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

$Config = Get-Content `
    "$PhaseRoot/config/rollback-baseline.json" -Raw |
    ConvertFrom-Json

$Release = Get-Content `
    "$PhaseRoot/config/release-baseline.json" -Raw |
    ConvertFrom-Json

$Namespace = $Config.namespace
$JobName = $Config.rollback_job
$PolicyName = $Config.policy_name
$RollbackImage = $Config.rollback_image
$CurrentImage = $Config.current_image

$EvidenceRoot = "$PhaseRoot/evidence/rollback-1.0.8"

$Timestamp = [DateTime]::UtcNow.ToString(
    "yyyyMMdd-HHmmss-fff"
)

$RunRoot = Join-Path $EvidenceRoot $Timestamp

New-Item -ItemType Directory `
    -Path $RunRoot -Force | Out-Null

$PolicyChanged = $false
$PolicyRestored = $false
$JobCreated = $false
$CredentialRoot = $null
$Status = "FAILED"

function Set-ImageExpression {
    param(
        [string]$ExpectedExpression,
        [string]$NewExpression
    )

    $LivePolicy = (
        Invoke-Checked "kubectl" @(
            "get", "validatingadmissionpolicy",
            $PolicyName, "-o", "json"
        )
    ) -join "`n" | ConvertFrom-Json

    $Path = "/spec/validations/$RuleIndex/expression"

    $Patch = @(
        @{
            op = "test"
            path = "/metadata/resourceVersion"
            value = $LivePolicy.metadata.resourceVersion
        },
        @{
            op = "test"
            path = $Path
            value = $ExpectedExpression
        },
        @{
            op = "replace"
            path = $Path
            value = $NewExpression
        }
    )

    $PatchFile = Join-Path $RunRoot "policy-patch.json"

    ConvertTo-Json -InputObject $Patch -Depth 10 |
        Set-Content $PatchFile -Encoding ascii

    Invoke-Checked "kubectl" @(
        "patch", "validatingadmissionpolicy",
        $PolicyName,
        "--type=json",
        "--patch-file=$PatchFile"
    ) | Out-Null
}

try {

    # 1. Verify cluster context

    $Context = Invoke-Checked "kubectl" @(
        "config", "current-context"
    )

    if ($Context -ne "minikube") {
        throw "Unexpected Kubernetes context"
    }

    # 2. Verify rollback configuration

    $ApprovedCurrentImage = (
        "$($Release.jfrog.registry)/" +
        "$($Release.environments.PROD.docker_repository)/" +
        "$($Release.docker.image_name)@$($Release.docker.digest)"
    )

    if ($CurrentImage -cne $ApprovedCurrentImage) {
        throw "Current image does not match release baseline"
    }

    if ($RollbackImage -cnotmatch '@sha256:[a-f0-9]{64}$') {
        throw "Invalid rollback image digest"
    }

    # 3. Verify security evidence

    $Security = Get-Content `
        "$EvidenceRoot/rollback-security-summary.json" -Raw |
        ConvertFrom-Json

    if (
        $Security.SecurityGate -ne "PASSED" -or
        $Security.Image -cne $RollbackImage -or
        $null -eq $Security.ScanExitCode -or
        $Security.ScanExitCode -ne 0 -or
        $null -eq $Security.Critical -or
        $null -eq $Security.High -or
        $Security.Critical -ne 0 -or
        $Security.High -ne 0
    ) {
        throw "Rollback security gate failed"
    }

    Write-Pass "Rollback security evidence verified"

    # 4. Verify historical execution

    $HistoricalJob = (
        Invoke-Checked "kubectl" @(
            "get", "job", $Config.historical_job,
            "-n", $Namespace, "-o", "json"
        )
    ) -join "`n" | ConvertFrom-Json

    if (
        $HistoricalJob.status.succeeded -ne 1 -or
        $HistoricalJob.spec.template.spec.containers[0].image `
            -cne $RollbackImage
    ) {
        throw "Historical rollback verification failed"
    }

    Write-Pass "Historical rollback execution verified"

    # 5. Verify image availability

    $Inspect = Invoke-Checked "docker" @(
        "buildx", "imagetools", "inspect", $RollbackImage
    )

    $Inspect |
        Set-Content "$RunRoot/image-inspect.txt"

    $DigestLine = $Inspect |
        Where-Object { $_ -match '^Digest:\s+' } |
        Select-Object -First 1

    $ActualDigest = (
        $DigestLine -replace '^Digest:\s+', ''
    ).Trim()

    if ($ActualDigest -cne ($RollbackImage.Split("@")[-1])) {
        throw "Rollback digest mismatch"
    }

    Write-Pass "Rollback image digest verified"

    # 6. Verify rollback Job does not exist

    $Existing = Invoke-Checked "kubectl" @(
        "get", "job", $JobName,
        "-n", $Namespace,
        "--ignore-not-found", "-o", "name"
    )

    if ($Existing) {
        throw "Rollback Job already exists"
    }

    # 7. Render rollback manifest

    $Template = Get-Content `
        "$PhaseRoot/kubernetes/deployment/production-job-template.yaml" `
        -Raw

    $Manifest = $Template.Replace(
        "__JOB_NAME__", $JobName
    ).Replace(
        "__RELEASE_VERSION__", "1.0.8-rollback"
    ).Replace(
        "__APPROVED_IMAGE__", $RollbackImage
    )

    $ManifestFile = "$RunRoot/rollback-job.yaml"

    $Manifest |
        Set-Content $ManifestFile -Encoding ascii

    # 8. Back up live admission policy

    $PolicyJson = (
        Invoke-Checked "kubectl" @(
            "get", "validatingadmissionpolicy",
            $PolicyName, "-o", "json"
        )
    ) -join "`n"

    $PolicyJson |
        Set-Content "$RunRoot/original-policy.json"

    $Policy = $PolicyJson | ConvertFrom-Json

    $Indexes = @(
        for ($i = 0; $i -lt $Policy.spec.validations.Count; $i++) {
            if (
                $Policy.spec.validations[$i].message -eq
                "Only the approved production image digest is allowed"
            ) {
                $i
            }
        }
    )

    if ($Indexes.Count -ne 1) {
        throw "Unexpected image authorization rules"
    }

    $RuleIndex = $Indexes[0]

    $OriginalExpression = `
        $Policy.spec.validations[$RuleIndex].expression

    $ExpectedExpression = (
        "variables.pod.containers.all(c," +
        "c.image=='$CurrentImage')"
    )

    if (
        ($OriginalExpression -replace '\s', '') -cne
        ($ExpectedExpression -replace '\s', '')
    ) {
        throw "Unexpected original admission expression"
    }

    # Permit the rollback image only for the named rollback Job.

    $TemporaryExpression = (
        "variables.pod.containers.all(c, " +
        "c.image == '$CurrentImage' || " +
        "(object.metadata.name == '$JobName' && " +
        "c.image == '$RollbackImage'))"
    )

    $OriginalExpression |
        Set-Content "$RunRoot/original-expression.txt"

    $TemporaryExpression |
        Set-Content "$RunRoot/temporary-expression.txt"

    if (-not $Execute) {

        $Status = "PREFLIGHT_PASSED"

        Write-Host "Preflight passed. No policy or Job modified."

        return
    }

    # 9. Generate restricted deployment credentials

    $AdminConfig = (
        Invoke-Checked "kubectl" @(
            "config", "view", "--raw",
            "--minify", "--flatten", "-o", "json"
        )
    ) -join "`n" | ConvertFrom-Json

    $Cluster = $AdminConfig.clusters[0].cluster

    if (
        -not $Cluster.'certificate-authority-data' -or
        $Cluster.server -notmatch '^https://'
    ) {
        throw "Secure Kubernetes configuration missing"
    }

    $CredentialRoot = Join-Path $env:TEMP (
        "enterprise-rollback-" +
        [Guid]::NewGuid().ToString()
    )

    New-Item -ItemType Directory `
        -Path $CredentialRoot | Out-Null

    $Token = Invoke-Checked "kubectl" @(
        "create", "token", "enterprise-deployer",
        "-n", $Namespace, "--duration=15m"
    )

    $DeployConfig = @{
        apiVersion = "v1"
        kind = "Config"
        clusters = @(
            @{
                name = "cluster"
                cluster = @{
                    server = $Cluster.server
                    "certificate-authority-data" = `
                        $Cluster.'certificate-authority-data'
                }
            }
        )
        users = @(
            @{
                name = "deployer"
                user = @{ token = $Token }
            }
        )
        contexts = @(
            @{
                name = "rollback"
                context = @{
                    cluster = "cluster"
                    user = "deployer"
                    namespace = $Namespace
                }
            }
        )
        "current-context" = "rollback"
    }

    $Kubeconfig = "$CredentialRoot/config.json"

    $DeployConfig |
        ConvertTo-Json -Depth 10 |
        Set-Content $Kubeconfig -Encoding ascii

    $Token = $null
    $DeployConfig = $null
    $AdminConfig = $null

    $KubeArgs = @(
        "--kubeconfig=$Kubeconfig",
        "-n", $Namespace
    )

    $Identity = (
        Invoke-Checked "kubectl" (
            $KubeArgs + @("auth", "whoami", "-o", "json")
        )
    ) -join "`n" | ConvertFrom-Json

    if (
        $Identity.status.userInfo.username -ne
        "system:serviceaccount:enterprise-prod:enterprise-deployer"
    ) {
        throw "Unexpected deployment identity"
    }

    Write-Pass "Restricted deployment identity verified"

    # 10. Temporarily authorize rollback

    Set-ImageExpression `
        $OriginalExpression $TemporaryExpression

    $PolicyChanged = $true

    Write-Pass "Temporary rollback authorization installed"

    # Allow admission configuration to propagate.

    $Accepted = $false

    for ($Attempt = 1; $Attempt -le 15; $Attempt++) {

        $Result = & kubectl @KubeArgs create `
            --dry-run=server -f $ManifestFile 2>&1

        if ($LASTEXITCODE -eq 0) {
            $Accepted = $true
            break
        }

        Start-Sleep -Seconds 2
    }

    if (-not $Accepted) {
        throw "Rollback admission validation failed"
    }

    Write-Pass "Rollback manifest accepted"

    # 11. Execute rollback Job

    Invoke-Checked "kubectl" (
        $KubeArgs + @("create", "-f", $ManifestFile)
    )

    $JobCreated = $true

    # Restore authorization immediately after Job creation.

    Set-ImageExpression `
        $TemporaryExpression $OriginalExpression

    $PolicyRestored = $true
    $PolicyChanged = $false

    Write-Pass "Original admission expression restored"

    # 12. Verify rollback runtime

    Invoke-Checked "kubectl" (
        $KubeArgs + @(
            "wait", "--for=condition=complete",
            "job/$JobName", "--timeout=240s"
        )
    )

    $Logs = @(
        Invoke-Checked "kubectl" (
            $KubeArgs + @("logs", "job/$JobName")
        )
    )

    $Logs |
        Set-Content "$RunRoot/application.log"

    if (
        ($Logs -join "`n") -cne
        ($Release.runtime.expected_output -join "`n")
    ) {
        throw "Rollback application output mismatch"
    }

    $PodsJson = (
        Invoke-Checked "kubectl" (
            $KubeArgs + @(
                "get", "pods",
                "-l", "batch.kubernetes.io/job-name=$JobName",
                "-o", "json"
            )
        )
    ) -join "`n"

    $PodsJson |
        Set-Content "$RunRoot/pod-status.json"

    $Pods = $PodsJson | ConvertFrom-Json

    if (@($Pods.items).Count -ne 1) {
        throw "Unexpected rollback Pod count"
    }

    $Pod = $Pods.items[0]
    $Container = $Pod.status.containerStatuses[0]

    if (
        $Pod.status.phase -ne "Succeeded" -or
        $Container.state.terminated.exitCode -ne 0 -or
        $Container.restartCount -ne 0 -or
        $Pod.spec.containers[0].image -cne $RollbackImage -or
        $Pod.spec.serviceAccountName -ne "enterprise-runtime" -or
        $Pod.spec.automountServiceAccountToken -ne $false
    ) {
        throw "Rollback runtime verification failed"
    }

    $Logs

    Write-Pass "Rollback application runtime verified"

    $Status = "PASSED"

}
finally {

    try {

        if ($PolicyChanged) {

            Set-ImageExpression `
                $TemporaryExpression $OriginalExpression

            $PolicyRestored = $true
            $PolicyChanged = $false

            Write-Pass "Original admission expression restored"
        }

    }
    finally {

        if (
            $CredentialRoot -and
            (Test-Path $CredentialRoot)
        ) {
            Remove-Item $CredentialRoot -Recurse -Force

            Write-Pass "Temporary credentials removed"
        }

        $Summary = [ordered]@{
            SourceRelease = $Config.source_release
            Namespace = $Namespace
            RollbackJob = $JobName
            RollbackImage = $RollbackImage
            ExecuteRequested = [bool]$Execute
            JobCreated = $JobCreated
            PolicyRestored = $PolicyRestored
            Status = $Status
            NetworkPolicyEnforcement = "NOT_VERIFIED"
            TimestampUTC = [DateTime]::UtcNow.ToString("o")
        }

        $Summary |
            ConvertTo-Json -Depth 5 |
            Set-Content "$RunRoot/rollback-summary.json"

        [PSCustomObject]$Summary | Format-List

        Write-Host "Evidence directory: $RunRoot"
    }
}
