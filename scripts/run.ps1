param(
    [ValidateSet("A", "B", "C", "D")]
    [string]$Scenario = "A",

    [ValidateRange(1, 10000)]
    [int]$VUS = 50,

    [ValidateRange(1, 3600)]
    [int]$Duration = 60
)

$ErrorActionPreference = "Stop"

# -------------------------
# Project paths
# -------------------------

$projectRoot = Split-Path $PSScriptRoot -Parent
$resultsDir = Join-Path $projectRoot "reports\results"

$benchmarkDir = Join-Path $projectRoot "benchmark"
$collectorPath = Join-Path $PSScriptRoot "collect_metrics.ps1"

New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

Push-Location $projectRoot

try {

    # -------------------------
    # Scenario configuration
    # -------------------------

    switch ($Scenario) {
        "A" {
            $workerCount = 1
            $baseUrl = "http://localhost:8000"
            $testScript = Join-Path $benchmarkDir "scenario-a.js"
        }

        "B" {
            $workerCount = 1
            $baseUrl = "http://localhost:8080"
            $testScript = Join-Path $benchmarkDir "scenario-b.js"
        }

        "C" {
            $workerCount = 4
            $baseUrl = "http://localhost:8000"
            $testScript = Join-Path $benchmarkDir "scenario-a.js"
        }

        "D" {
            $workerCount = 4
            $baseUrl = "http://localhost:8080"
            $testScript = Join-Path $benchmarkDir "scenario-b.js"
        }
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    $jsonPath = Join-Path $resultsDir "scenario-$($Scenario.ToLower())-$($workerCount)workers-$($VUS)vus-$timestamp.json"

    $metricsPath = Join-Path $resultsDir "metrics-$($Scenario.ToLower())-$($VUS)vus-$timestamp.csv"

    Write-Host ""
    Write-Host "=================================="
    Write-Host "       HTTP BENCHMARK RUNNER"
    Write-Host "=================================="
    Write-Host "Scenario:       $Scenario"
    Write-Host "Workers:        $workerCount"
    Write-Host "Virtual Users:  $VUS"
    Write-Host "Duration:       $Duration seconds"
    Write-Host "Target:         $baseUrl"
    Write-Host "=================================="
    Write-Host ""

    # -------------------------
    # Configure backend workers
    # -------------------------

    $env:WEB_CONCURRENCY = "$workerCount"

    Write-Host "[1/5] Starting Docker services..."

    docker compose up -d web

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to start Nginx service."
    }

    docker compose up -d --force-recreate backend

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to start backend service."
    }

    # -------------------------
    # Wait for API readiness
    # -------------------------

    Write-Host "[2/5] Waiting for API readiness..."

    $ready = $false
    $deadline = (Get-Date).AddSeconds(60)

    while ((Get-Date) -lt $deadline) {

        try {
            $response = Invoke-RestMethod `
                -Uri "$baseUrl/api/test" `
                -TimeoutSec 3

            if ($response.status -eq "success") {
                $ready = $true
                break
            }
        }
        catch {
            Start-Sleep -Seconds 2
        }
    }

    if (-not $ready) {
        throw "API did not become ready within 60 seconds."
    }

    Write-Host "API is ready."

    # -------------------------
    # Start metrics collector
    # -------------------------

    Write-Host "[3/5] Starting metrics collector..."

    $collectorDuration = $Duration + 10

    $collectorJob = Start-Job -ScriptBlock {
        param($ScriptPath, $Seconds, $CsvPath)

        & $ScriptPath `
            -DurationSeconds $Seconds `
            -IntervalSeconds 5 `
            -OutputPath $CsvPath

    } -ArgumentList $collectorPath, $collectorDuration, $metricsPath

    Start-Sleep -Seconds 2

    # -------------------------
    # Run k6 benchmark
    # -------------------------

    Write-Host "[4/5] Running k6 benchmark..."
    Write-Host ""

    & k6 run `
        -e "VUS=$VUS" `
        -e "DURATION=${Duration}s" `
        -e "BASE_URL=$baseUrl" `
        --out "json=$jsonPath" `
        $testScript

    $k6ExitCode = $LASTEXITCODE

    # -------------------------
    # Wait for metrics collection
    # -------------------------

    Write-Host ""
    Write-Host "[5/5] Waiting for metrics collector..."

    Wait-Job -Job $collectorJob | Out-Null

    Receive-Job -Job $collectorJob

    $collectorFailed = $collectorJob.State -ne "Completed"

    Remove-Job -Job $collectorJob

    # -------------------------
    # Final result
    # -------------------------

    Write-Host ""
    Write-Host "=================================="

    if ($k6ExitCode -ne 0) {
        Write-Host "Benchmark finished with errors."
        Write-Host "k6 exit code: $k6ExitCode"
    }
    elseif ($collectorFailed) {
        Write-Host "Benchmark completed, but metrics collection failed."
    }
    else {
        Write-Host "Benchmark completed successfully."
    }

    Write-Host ""
    Write-Host "JSON results: $jsonPath"
    Write-Host "Metrics CSV:  $metricsPath"
    Write-Host "=================================="

    if ($k6ExitCode -ne 0) {
        throw "k6 returned a non-zero exit code."
    }

    if ($collectorFailed) {
        throw "Metrics collector did not complete successfully."
    }
}
finally {
    Pop-Location
}