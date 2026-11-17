# HTTP Performance Benchmarking

A Windows-based HTTP load-testing project using Docker Desktop, Docker Compose, FastAPI/Uvicorn, Nginx, Grafana k6, and PowerShell resource monitoring.

## Requirements

- Windows 10/11
- Docker Desktop with Linux containers enabled
- Docker Compose v2 (`docker compose`)
- PowerShell
- Grafana k6 installed and available on `PATH`

No VM, Vagrant, or Linux distribution is required.

## Architecture

- FastAPI listens on container port `8000`.
- Direct backend access is published on host port `8000`.
- Nginx listens on container port `80`, published on host port `8080`.
- Nginx proxies `/api/` to the Compose service `backend:8000`.
- k6 runs on the Windows host.
- PowerShell collects Windows host and Docker container CPU/RAM samples.

## Start the environment

From the repository root:

```powershell
docker compose up -d --build
```

Check service status:

```powershell
docker compose ps
```

Check the Nginx configuration:

```powershell
docker compose exec web nginx -t
```

## Run a benchmark

The PowerShell runner selects the correct worker count and endpoint for each scenario, recreates the backend with the selected `WEB_CONCURRENCY`, checks readiness, starts resource collection, runs k6, and writes result files.

Run from the repository root:

```powershell
.\scriptsun.ps1 -Scenario A -VUS 50 -Duration 60
```

Scenarios:

| Scenario | Request path | Workers |
|---|---|---:|
| A | k6 → FastAPI (`http://localhost:8000`) | 1 |
| B | k6 → Nginx → FastAPI (`http://localhost:8080`) | 1 |
| C | k6 → FastAPI (`http://localhost:8000`) | 4 |
| D | k6 → Nginx → FastAPI (`http://localhost:8080`) | 4 |

Example commands:

```powershell
.\scriptsun.ps1 -Scenario A -VUS 100 -Duration 60
.\scriptsun.ps1 -Scenario B -VUS 250 -Duration 60
.\scriptsun.ps1 -Scenario C -VUS 500 -Duration 60
.\scriptsun.ps1 -Scenario D -VUS 1000 -Duration 60
```

Run only one benchmark at a time. Concurrent runs share the same Docker services and can recreate the backend while another test is running, which invalidates a controlled comparison.

## Result files

The runner writes generated files under:

```text
reports/
└── results/
    ├── scenario-*.json       # Raw k6 time-series output
    ├── k6-summary-*.json     # k6 summary export
    ├── summary-*.csv         # One-row summary for comparison
    └── metrics-*.csv         # Periodic host/container resource samples
```

The final report is:

```text
reports/report.md
```

Charts used by the report are stored in:

```text
reports/charts/
```

The supplied result archive contains the summary and metrics CSVs used for the report. It does not include the raw k6 JSON time-series files.

## Stop the environment

```powershell
docker compose down
```

## Benchmark scenarios and measurements

The final recorded comparison includes 50, 100, 250, 500, and 1,000 virtual users, each for 60 seconds, across scenarios A–D. The 1,000-VU test was the final load level.

The summary export contains request count, RPS, average/P50/P90/P95/maximum latency, failed request count, failure rate, and check counts. The resource collector samples Windows host and Docker container CPU/RAM.

See [`reports/report.md`](reports/report.md) for the full analysis, charts, results, limitations, and conclusions.

## Important interpretation notes

- VUs are virtual users, not requests per second.
- Docker container CPU percentages can exceed 100% because they are expressed relative to one CPU core.
- Host and container resource values overlap; do not add them together.
- The resource collector is periodic, so averages and peaks are sampled values.
- A single run per scenario/load level is not a statistical guarantee. The report identifies this limitation.
