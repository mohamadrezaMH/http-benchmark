# DevOps First Task : Skills and Lessons Learned

## HTTP Benchmarking and Performance Testing

## Introduction

This project involved designing and implementing a test environment to
evaluate a backend service under different load conditions. FastAPI was
used as the backend, Nginx as a reverse proxy, Docker and Docker Compose
for service management, and k6 for load testing and performance
measurement. PowerShell scripts were also used to automate test
execution and system-resource metrics collection.

The following sections summarize the main concepts and skills explored
during the project.

------------------------------------------------------------------------

## 1. Docker and Containerization

**Approximate experience level: Beginner to intermediate**

Topics learned and practiced:

-   Understanding containerization and running applications in isolated
    environments.
-   Writing a `Dockerfile` to build an application image.
-   Becoming familiar with the main Dockerfile instructions: `FROM`,
    `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `CMD`, and `ENV`.
-   Understanding the difference between a Docker image and a container.
-   Running applications inside containers.
-   Managing container states and viewing logs.
-   Understanding port mapping between the host and a container.
-   Using `docker stats` to inspect container resource usage.

**Topics for further learning:**

-   Multi-stage builds
-   Docker networking
-   Docker volumes
-   Docker image optimization
-   Advanced container resource management

## 2. Docker Compose

**Approximate experience level: Beginner to intermediate**

Topics learned:

-   Writing and configuring a `docker-compose.yml` file.
-   Defining and managing multiple services in a shared environment.
-   Running the backend and Nginx together.
-   Configuring port mappings and environment variables.
-   Connecting services through service names.
-   Managing service lifecycles and restarting services after
    configuration changes.

Docker Compose made it possible to define and manage the project
environment through one configuration file instead of starting and
managing each container separately.

## 3. Nginx and Reverse Proxy

**Approximate experience level: Beginner**

Nginx was used as a **reverse proxy** in this project.

Request flow:

``` text
Client -> Nginx -> FastAPI / Uvicorn
```

Topics learned:

-   Understanding Nginx as a web server and reverse proxy.
-   Running Nginx in a Docker container.
-   Writing and configuring an Nginx configuration file.
-   Using `proxy_pass` to forward requests to the backend.
-   Connecting Nginx to the backend service.
-   Comparing direct backend access with access through Nginx.
-   Evaluating the effect of a reverse proxy on performance.

**Conceptual distinction:**

-   A **forward proxy** sends requests to destination servers on behalf
    of clients.
-   A **reverse proxy** receives incoming client requests and forwards
    them to backend services.

**Topics for further learning:**

-   Load balancing
-   SSL/TLS termination
-   Caching
-   Rate limiting
-   Advanced Nginx configuration

## 4. Performance Testing with k6

**Approximate experience level: Beginner to intermediate**

k6 was used to perform load tests and evaluate service performance under
different load conditions.

Topics learned:

-   Writing k6 test scripts.
-   Defining virtual users (VUs).
-   Setting test durations.
-   Running tests with different numbers of virtual users.
-   Checking HTTP response status codes.
-   Writing checks to validate responses.
-   Saving test output.
-   Comparing results across test scenarios.

**Key performance metrics explored:**

-   **VUs:** Number of active virtual users.
-   **Requests:** Total number of requests sent.
-   **RPS:** Requests per second.
-   **Average Latency:** Average response time.
-   **P50:** 50th percentile (median) response time.
-   **P90:** 90th percentile response time.
-   **P95:** 95th percentile response time.
-   **Max Latency:** Highest recorded response time.
-   **Failure Rate:** Proportion of failed requests.
-   **Checks:** Number of successful and failed check evaluations.

## 5. Performance Analysis and Architecture Comparison

**Approximate experience level: Beginner to intermediate**

An important part of the project was analyzing test results and
comparing different application architectures.

Four scenarios were tested:

-   **Scenario A:** Direct connection to FastAPI with one worker.
-   **Scenario B:** Nginx forwarding requests to FastAPI with one
    worker.
-   **Scenario C:** Direct connection to FastAPI with four workers.
-   **Scenario D:** Nginx forwarding requests to FastAPI with four
    workers.

Topics learned:

-   Comparing single-worker and multiple-worker configurations.
-   Evaluating the effect of worker count on throughput.
-   Analyzing latency increases as load grows.
-   Identifying signs that a system is approaching saturation.
-   Observing failure-rate changes under heavy load.
-   Comparing Nginx-based access with direct backend access.
-   Drawing conclusions from measured data rather than assumptions.

Related concepts:

-   Concurrency
-   Throughput
-   Latency
-   Bottleneck analysis
-   System saturation

## 6. PowerShell and Automation

**Approximate experience level: Beginner**

PowerShell scripts were used to automate much of the test execution and
data collection process.

### A. Test Automation

-   Selecting a test scenario.
-   Configuring the number of workers.
-   Restarting services.
-   Checking whether the backend was ready.
-   Running k6 tests automatically.
-   Saving results to output files.
-   Executing multiple steps sequentially through a single script.

### B. Metrics Collection

-   Collecting host CPU usage.
-   Collecting host memory usage.
-   Collecting CPU and memory usage for containers.
-   Saving collected data in CSV files.
-   Using tools such as `docker stats` and PowerShell capabilities to
    gather metrics.

As a result, scenario execution, performance testing, and data
collection were largely automated. These activities are related to
**test automation** and **operations scripting**.

## 7. Monitoring and Resource Metrics

**Approximate experience level: Beginner**

The project provided practical exposure to collecting and examining
system resource metrics.

Topics explored:

-   CPU usage.
-   Memory usage.
-   Container resource usage.
-   Performance metrics.
-   Collecting and organizing measurement data.
-   Examining the relationship between resource consumption and service
    performance.

**Important note:** The implementation was not a complete, continuously
running monitoring system. It was a basic resource-metrics collection
approach used during performance tests.

**Topics for further learning:**

-   Prometheus
-   Grafana
-   Dashboards
-   Alerting
-   Observability

## 8. Linux and Shell Scripting

**Experience level: Further learning required**

Because the main project environment was Windows, PowerShell was used
for most scripting tasks. To strengthen DevOps skills, learning Linux
and Bash is an important next step.

Topics to learn:

-   Linux command line
-   Bash scripting
-   File and directory management
-   File permissions
-   Process management
-   Environment variables
-   Package management
-   Service management with systemd
-   Linux networking commands
-   SSH

Learning Bash alongside PowerShell will make it easier to automate tasks
across different environments.

## 9. Git and Project Documentation

**Approximate experience level: Beginner**

The project completion and documentation work involved:

-   Organizing the project directory structure.
-   Saving and managing test results.
-   Generating CSV output files.
-   Preparing reports with Markdown.
-   Creating performance charts.
-   Writing a README file.
-   Documenting test results, limitations, and analysis.
-   Managing project changes with Git.

------------------------------------------------------------------------

# Summary of Skills Gained

  -----------------------------------------------------------------------
  Area                    Skill                   Approximate Experience
                                                  Level
  ----------------------- ----------------------- -----------------------
  Containerization        Docker and Dockerfiles  Beginner to
                                                  intermediate

  Orchestration           Docker Compose          Beginner to
                                                  intermediate

  Web Server              Nginx and reverse proxy Beginner

  Performance Testing     k6                      Beginner to
                                                  intermediate

  Scripting               PowerShell              Beginner

  Automation              Test automation         Beginner

  Monitoring              Resource metrics        Beginner
                          collection              

  Performance Analysis    Latency and throughput  Beginner to
                          analysis                intermediate

  Backend Deployment      FastAPI and Uvicorn     Practical exposure

  Documentation           Markdown and README     Beginner

  Version Control         Git                     Practical familiarity
  -----------------------------------------------------------------------

These levels are approximate and reflect the practical experience gained
during this project. They do not imply full proficiency in every tool or
concept.

------------------------------------------------------------------------

# Recommended Learning Roadmap

The following roadmap is intended to build on the skills gained in this
project and support further development in DevOps.

## 1. Linux and Bash

-   Become comfortable with essential Linux commands.
-   Work with files, permissions, and processes.
-   Manage services and users.
-   Write Bash scripts.

## 2. More Advanced Docker

-   Docker networking
-   Volumes
-   Multi-stage builds
-   Dockerfile optimization
-   Container resource management

## 3. More Advanced Nginx

-   Load balancing
-   SSL/TLS
-   Caching
-   Rate limiting
-   Advanced reverse proxy configuration

## 4. Monitoring and Observability

-   Prometheus
-   Grafana
-   Metrics
-   Dashboards
-   Alerting

## 5. CI/CD

-   Learn GitLab CI/CD.
-   Design pipelines.
-   Automate build and test processes.
-   Understand automated deployment workflows.

## 6. Infrastructure and Networking Fundamentals

-   DNS
-   HTTP and HTTPS
-   TCP/IP
-   Ports
-   Firewalls
-   SSH

**Recommendation:** Before moving seriously into Kubernetes, develop a
solid understanding of Linux, Bash, Docker, networking fundamentals, and
CI/CD. These foundations will make advanced infrastructure and
container-orchestration concepts easier to understand.

------------------------------------------------------------------------

## Conclusion

This project provided practical experience with a broad workflow
involving application execution, containerization, reverse-proxy
configuration, load testing, metrics collection, process automation, and
performance analysis.

One of the most important outcomes was gaining a practical understanding
of how different components of a software infrastructure work together,
and how architectural and configuration choices can affect service
performance under varying load conditions.

This experience provides a useful foundation for further learning in
DevOps, infrastructure, CI/CD, and more advanced service-management
practices.
