# Linux System Monitoring and Alerting Script

## Project Overview

A Bash-based system monitoring and alerting script developed on Ubuntu Linux. It monitors essential system resource utilization, identifies resource-intensive processes, and generates timestamped logs for monitoring and troubleshooting.

## Features

- **Disk Monitoring:** Checks root filesystem disk utilization.
- **Memory Monitoring:** Calculates memory usage using available system memory information.
- **CPU Monitoring:** Checks CPU utilization.
- **Configurable Thresholds:** Allows users to customize disk, memory, and CPU alert thresholds.
- **Process Monitoring:** Displays the top 5 CPU-consuming and memory-consuming processes.
- **Timestamped Logging:** Displays monitoring results in the terminal and stores them in a log file.
- **Input Validation:** Checks threshold values and required system commands before execution.

## Technologies Used

- Ubuntu Linux 26.04 LTS
- GNU Bash
- Linux utilities: `df`, `free`, `top`, `ps`, `awk`, `tee`, `date`
- Git and GitHub
- ShellCheck

## Project Structure

```text
system-monitoring/
├── system_monitor.sh
├── README.md
├── .gitignore
└── logs/
    └── .gitkeep
```

## Prerequisites

- Linux operating system
- Bash shell
- Required Linux utilities (`df`, `free`, `top`, `ps`, `awk`, `tee`, `date`)

## How to Run

1. Clone the repository:

   ```bash
   git clone https://github.com/Jiya-k/system-monitoring-script.git
   cd system-monitoring-script
   ```

2. Give execution permission:

   ```bash
   chmod +x system_monitor.sh
   ```

3. Run the monitoring script:

   ```bash
   ./system_monitor.sh
   ```

## Configure Monitoring Thresholds

The default alert thresholds are 80% for disk, memory, and CPU utilization.

You can override them when executing the script:

```bash
DISK_THRESHOLD=90 MEMORY_THRESHOLD=85 CPU_THRESHOLD=75 ./system_monitor.sh
```

Threshold values must be integers between 1 and 100.

## View Monitoring Logs

Monitoring results are stored in:

```text
logs/monitoring.log
```

To view the latest entries:

```bash
tail -n 20 logs/monitoring.log
```

To monitor the log file in real time:

```bash
tail -f logs/monitoring.log
```

## Validation

The script was validated using:

```bash
bash -n system_monitor.sh
shellcheck system_monitor.sh
```

Both checks completed successfully.

## Sample Output

```text
========== System Monitoring Started ==========
All required commands are available.
Checking disk usage...
OK: Disk usage is 49%
Checking memory usage...
OK: Memory usage is 13%
Checking CPU usage...
OK: CPU usage is 0%
Top 5 CPU-consuming processes:
Top 5 memory-consuming processes:
========== System Monitoring Completed ==========
```

*Resource utilization values vary depending on system activity.*

## Learning Outcomes

- Linux system resource monitoring
- Bash scripting and functions
- Input validation and error handling
- Process monitoring
- Log management
- Git version control
- Shell script validation using ShellCheck
