# param(
#     [int]$DurationSeconds = 60,
#     [int]$IntervalSeconds = 1,
#     [string]$OutputPath = ""
# ) #determine the inputs of script

# $ErrorActionPreference = "Stop"

# # Create output directory
# $resultsDir = Join-Path $PSScriptRoot "..\reports\results"
# New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

# # Generate a unique output filename
# if ([string]::IsNullOrWhiteSpace($OutputPath)) {
#     $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
#     $OutputPath = Join-Path $resultsDir "metrics_$timestamp.csv"
# }

# $OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

# Write-Host "Starting metrics collection..."
# Write-Host "Duration: $DurationSeconds seconds"
# Write-Host "Interval: $IntervalSeconds second(s)"
# Write-Host "Output: $OutputPath"

# $endTime = (Get-Date).AddSeconds($DurationSeconds)

# while ((Get-Date) -lt $endTime) {

#     $timestamp = (Get-Date).ToString("o")
#     $sampleRows = @()

#     # -------------------------
#     # Host CPU and RAM
#     # -------------------------

#     $os = Get-CimInstance Win32_OperatingSystem

#     $processors = Get-CimInstance Win32_Processor
#     $cpuAverage = ($processors | Measure-Object -Property LoadPercentage -Average).Average

#     $totalMemoryMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 2)  #total ram
#     $freeMemoryMB = [math]::Round($os.FreePhysicalMemory / 1024, 2)
#     $usedMemoryMB = [math]::Round($totalMemoryMB - $freeMemoryMB, 2)
#     $memoryPercent = [math]::Round(($usedMemoryMB / $totalMemoryMB) * 100, 2)

#     $sampleRows += [PSCustomObject]@{
#         Timestamp          = $timestamp
#         Type               = "Host"
#         Name               = "Windows"
#         CPUPercent         = $cpuAverage
#         MemoryUsage        = $usedMemoryMB
#         MemoryLimit        = $totalMemoryMB
#         MemoryPercent      = $memoryPercent
#         PIDs               = ""
#     }

#     # -------------------------
#     # Docker container metrics
#     # -------------------------

#     $dockerOutput = docker stats --no-stream --format "{{json .}}" 2>$null

#     foreach ($line in $dockerOutput) {

#         if ([string]::IsNullOrWhiteSpace($line)) {
#             continue
#         }

#         $stats = $line | ConvertFrom-Json

#         $containerCPU = [double]::Parse(
#             $stats.CPUPerc.TrimEnd('%'),
#             [System.Globalization.CultureInfo]::InvariantCulture
#         )

#         $containerMemoryPercent = [double]::Parse(
#             $stats.MemPerc.TrimEnd('%'),
#             [System.Globalization.CultureInfo]::InvariantCulture
#         )

#         $sampleRows += [PSCustomObject]@{
#             Timestamp     = $timestamp
#             Type          = "Container"
#             Name          = $stats.Name
#             CPUPercent    = $containerCPU
#             MemoryUsage   = $stats.MemUsage
#             MemoryLimit   = ""
#             MemoryPercent = $containerMemoryPercent
#             PIDs          = $stats.PIDs
#         }
#     }

#     # -------------------------
#     # Save CSV
#     # -------------------------

#     if (Test-Path $OutputPath) {
#         $sampleRows | Export-Csv -Path $OutputPath -NoTypeInformation -Append -Encoding UTF8
#     }
#     else {
#         $sampleRows | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
#     }

#     Start-Sleep -Seconds $IntervalSeconds
# }

# Write-Host ""
# Write-Host "Metrics collection completed."
# Write-Host "Saved to: $OutputPath"




param(
    [int]$DurationSeconds = 60,
    [int]$IntervalSeconds = 5,
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

# Convert Docker memory values to MB
function ConvertTo-MB($value) {
    if ($value -match '^\s*([\d.]+)\s*(B|KiB|MiB|GiB|TiB)\s*$') {
        $number = [double]::Parse(
            $Matches[1],
            [System.Globalization.CultureInfo]::InvariantCulture
        )

        switch ($Matches[2]) {
            "B"   { return $number / 1MB }
            "KiB" { return $number / 1KB }
            "MiB" { return $number }
            "GiB" { return $number * 1KB }
            "TiB" { return $number * 1MB }
        }
    }

    return $null
}

# Prepare output directory
$resultsDir = Join-Path $PSScriptRoot "..\reports\results"
New-Item -ItemType Directory -Force -Path $resultsDir | Out-Null

# Generate output filename
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutputPath = Join-Path $resultsDir "metrics_$timestamp.csv"
}

$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

Write-Host "Starting metrics collection..."
Write-Host "Duration: $DurationSeconds seconds"
Write-Host "Target interval: $IntervalSeconds seconds"
Write-Host "Output: $OutputPath"

$startTime = Get-Date
$nextSample = $startTime

while (((Get-Date) - $startTime).TotalSeconds -lt $DurationSeconds) {

    $sampleStart = Get-Date
    $timestamp = $sampleStart.ToString("o")
    $sampleRows = @()

    # -------------------------
    # Host CPU and RAM
    # -------------------------

    $os = Get-CimInstance Win32_OperatingSystem

    $cpu = Get-CimInstance `
        Win32_PerfFormattedData_PerfOS_Processor `
        -Filter "Name='_Total'"

    $totalMemoryMB = [math]::Round(
        $os.TotalVisibleMemorySize / 1024, 2
    )

    $freeMemoryMB = [math]::Round(
        $os.FreePhysicalMemory / 1024, 2
    )

    $usedMemoryMB = [math]::Round(
        $totalMemoryMB - $freeMemoryMB, 2
    )

    $memoryPercent = [math]::Round(
        ($usedMemoryMB / $totalMemoryMB) * 100, 2
    )

    $sampleRows += [PSCustomObject]@{
        Timestamp     = $timestamp
        Type          = "Host"
        Name          = "Windows"
        CPUPercent    = $cpu.PercentProcessorTime
        MemoryUsageMB = $usedMemoryMB
        MemoryLimitMB = $totalMemoryMB
        MemoryPercent = $memoryPercent
        PIDs          = ""
    }

    # -------------------------
    # Docker container metrics
    # -------------------------

    $dockerOutput = docker stats --no-stream --format "{{json .}}"

    foreach ($line in $dockerOutput) {

        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $stats = $line | ConvertFrom-Json

        $containerCPU = [double]::Parse(
            $stats.CPUPerc.TrimEnd('%'),
            [System.Globalization.CultureInfo]::InvariantCulture
        )

        $memoryParts = $stats.MemUsage -split '\s*/\s*'

        $memoryUsedMB = ConvertTo-MB $memoryParts[0]
        $memoryLimitMB = ConvertTo-MB $memoryParts[1]

        $containerMemoryPercent = [double]::Parse(
            $stats.MemPerc.TrimEnd('%'),
            [System.Globalization.CultureInfo]::InvariantCulture
        )

        $sampleRows += [PSCustomObject]@{
            Timestamp     = $timestamp
            Type          = "Container"
            Name          = $stats.Name
            CPUPercent    = $containerCPU
            MemoryUsageMB = $memoryUsedMB
            MemoryLimitMB = $memoryLimitMB
            MemoryPercent = $containerMemoryPercent
            PIDs          = $stats.PIDs
        }
    }

    # -------------------------
    # Save CSV
    # -------------------------

    if (Test-Path $OutputPath) {
        $sampleRows | Export-Csv -Path $OutputPath `
            -NoTypeInformation -Append -Encoding UTF8
    }
    else {
        $sampleRows | Export-Csv -Path $OutputPath `
            -NoTypeInformation -Encoding UTF8
    }

    # Wait until the next sampling interval
    $nextSample = $nextSample.AddSeconds($IntervalSeconds)
    $remainingMs = ($nextSample - (Get-Date)).TotalMilliseconds

    if ($remainingMs -gt 0) {
        Start-Sleep -Milliseconds ([int]$remainingMs)
    }
    else {
        # If collection took too long, start a fresh interval
        $nextSample = (Get-Date).AddSeconds($IntervalSeconds)
    }
}

Write-Host ""
Write-Host "Metrics collection completed."
Write-Host "Saved to: $OutputPath"