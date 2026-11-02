# Task: HTTP Performance Benchmarking with Docker, Nginx, FastAPI & k6

## 1. Objective

Design and implement a reproducible HTTP performance benchmarking environment using Docker, Docker Compose, Nginx, FastAPI, and Grafana k6.

The objective is to evaluate HTTP throughput, latency, and resource consumption under different load conditions, while comparing the impact of Nginx reverse proxying and FastAPI worker counts.

The project must run directly on a Windows machine using Docker Desktop. No virtual machines or Vagrant are required.

**The most important requirement is simplicity: deploying the environment and executing benchmarks must require as few manual steps as possible.**

## 2. Architecture

The project must include:

- **FastAPI:** A lightweight backend application.
- **Nginx:** An HTTP reverse proxy.
- **k6:** A load testing tool.
- **Docker Compose:** Service orchestration.
- **Resource Monitoring:** Automated collection of CPU and memory metrics.

All application services must run using Docker Compose.

The k6 load generator may run directly on the host or as a separate container. Its resource consumption must be measured independently.

## 3. Backend Application

Implement a FastAPI application with the following endpoint:

`GET /api/test`

Requirements:

- Accept HTTP GET requests.
- Perform a small simulated processing operation.
- Log each processed request.
- Return a JSON response containing the processing status and processing time.
- Keep application logic lightweight to focus on HTTP performance.

Example response:

```json
{
  "status": "success",
  "message": "Request processed",
  "processing_time_ms": 2
}
```

Use Uvicorn as the ASGI server.

The number of workers must be configurable through an environment variable.

Example:

`WEB_CONCURRENCY=1`

or:

`WEB_CONCURRENCY=4`

## 4. Nginx Configuration

Configure Nginx as a reverse proxy.

Requirements:

- Expose HTTP on host port 8080.
- Forward `/api/` requests to FastAPI.
- Configure appropriate proxy headers.
- Support concurrent HTTP connections.
- Keep the configuration simple and document any non-default tuning parameters.

## 5. Benchmark Scenarios

Implement the following five scenarios:

| Scenario | Request Flow | FastAPI Workers |
|---|---|---:|
| A | k6 → FastAPI | 1 |
| B | k6 → Nginx → FastAPI | 1 |
| C | k6 → FastAPI | 4 |
| D | k6 → Nginx → FastAPI | 4 |
| E (Optional) | k6 → Nginx Static Response | N/A |

Each scenario must be independently executable.

The application configuration must automatically use the appropriate number of workers for each scenario.

## 6. Load Testing with k6

Use Grafana k6 to generate HTTP traffic.

Implement the following concurrency levels:

| Test | Virtual Users | Duration |
|---|---:|---:|
| 1 | 10 | 60 seconds |
| 2 | 50 | 60 seconds |
| 3 | 100 | 60 seconds |
| 4 | 250 | 60 seconds |
| 5 | 500 | 60 seconds |
| 6 | 1000 | 60 seconds |

Requirements:

- Include a warm-up period.
- Measure total requests, successful requests, and failed requests.
- Measure average and peak Requests Per Second.
- Collect average, P50, P95, and P99 latency.
- Repeat benchmarks at least three times where practical.
- Gradually increase concurrency and stop if resource limits or excessive errors are observed.

Do not assume that Virtual Users equal Requests Per Second.

## 7. Resource Monitoring

Automatically collect CPU and RAM consumption throughout every benchmark.

Monitor:

- k6 Load Generator.
- Nginx Container.
- FastAPI Container.
- Overall Windows Host.

Use appropriate tools such as Docker Stats and Windows PowerShell performance counters.

Record average and peak CPU and memory consumption.

Ensure that host-level and container-level metrics are reported separately to avoid double-counting.

## 8. Benchmark Comparison

The final report must compare:

1. Direct FastAPI with one worker vs. four workers.
2. FastAPI behind Nginx with one worker vs. four workers.
3. Direct FastAPI vs. Nginx + FastAPI.
4. The impact of worker count on throughput, latency, and CPU consumption.
5. The impact of Nginx on overall performance.

Identify the bottleneck in each scenario.

## 9. Automation and Ease of Execution

The project must be designed for minimal manual interaction.

The expected workflow should be as simple as:

**Start the environment:**

```bash
docker compose up -d --build
```

**Execute a specific benchmark:**

```bash
bash script.sh scenario-a
```

Other examples:

```bash
bash script.sh scenario-b
bash script.sh scenario-c
bash script.sh scenario-d
bash script.sh scenario-e
```

Alternatively, provide direct k6 commands:

```bash
k6 run benchmark/scenario-a.js
```

The preferred implementation is a single script that:

1. Accepts a scenario name.
2. Configures the appropriate FastAPI worker count and request endpoint.
3. Starts or selects the required services.
4. Verifies service readiness.
5. Starts resource monitoring.
6. Executes the k6 benchmark.
7. Stops resource monitoring.
8. Saves raw benchmark results.
9. Generates or updates the corresponding report data.

The user should not need to manually edit configuration files or change worker counts between scenarios.

If necessary, use Docker Compose profiles or multiple Compose configuration files to keep scenario selection simple.

**Important:** Each benchmark must start from a clean and reproducible application configuration. Do not allow a previous scenario's worker configuration to affect the next scenario.

## 10. Final Report

Produce a Markdown report containing:

### Request Metrics
- Total requests.
- Successful and failed requests.
- Test duration.
- Average and peak RPS.

### Latency Metrics
- Average latency.
- Minimum and maximum latency.
- P50, P95, and P99 latency.

### Resource Metrics
- Average and peak k6 CPU and RAM.
- Average and peak Nginx CPU and RAM.
- Average and peak FastAPI CPU and RAM.
- Overall Windows CPU and RAM utilization.

### Analysis
- Performance comparison across all scenarios.
- Impact of increasing concurrency.
- Impact of increasing FastAPI workers from 1 to 4.
- Nginx reverse proxy overhead.
- Identification of CPU, memory, or application bottlenecks.
- Explanation of performance degradation and errors.

Include charts for throughput, latency, CPU, and memory consumption.

## 11. Project Structure

Use a clean and maintainable repository structure, for example:

```text
http-benchmark/
├── docker-compose.yml
├── nginx/
│   └── nginx.conf
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── main.py
├── benchmark/
│   ├── scenario-a.js
│   ├── scenario-b.js
│   ├── scenario-c.js
│   ├── scenario-d.js
│   └── scenario-e.js
├── scripts/
│   ├── run.sh
│   └── collect_metrics.ps1
└── reports/
    ├── report.md
    └── results/
```

## 12. Deliverables

- Complete source code in a Git repository.
- Docker Compose configuration.
- Nginx configuration.
- FastAPI application.
- k6 benchmark scripts.
- Automated execution script.
- Resource monitoring scripts.
- Raw benchmark results.
- Final technical report with charts.
- README with installation and execution instructions.

## 13. Acceptance Criteria

- No virtual machine or Vagrant is required.
- The complete environment must start with one documented command.
- Every benchmark scenario must be executable with one command.
- FastAPI worker counts must be configured automatically per scenario.
- Resource metrics must be collected automatically.
- Results must be reproducible.
- All configurations and scripts must be included in the repository.
- The final report must explain the results and identify performance bottlenecks.

## 14. Optional Challenge: Docker Resource Limits

After completing the initial benchmarks, introduce resource constraints:

- Limit FastAPI to 1 CPU.
- Limit FastAPI memory to 512 MB.
- Repeat selected benchmarks.
- Compare the results with the unconstrained configuration.

Explain the impact of resource constraints on throughput, latency, and service stability.

---

**Expected Outcome:** A fully automated and reproducible HTTP benchmarking project that demonstrates practical knowledge of Docker, Docker Compose, Nginx, FastAPI, Uvicorn workers, k6, resource monitoring, and performance analysis.
