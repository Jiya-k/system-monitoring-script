#!/usr/bin/env bash

# System Monitoring and Alerting Script
# Capstone Project 1

set -o pipefail

DISK_THRESHOLD="${DISK_THRESHOLD:-80}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD:-80}"
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"

LOG_DIR="$(dirname "$0")/logs"
LOG_FILE="$LOG_DIR/monitoring.log"

mkdir -p "$LOG_DIR"

log_message() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

check_dependencies() {
    local commands=("df" "free" "awk" "ps" "top" "date" "tee" "head")

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_message "ERROR: Required command '$cmd' is missing."
            return 1
        fi
    done

    log_message "All required commands are available."
}

validate_threshold() {
    local name="$1"
    local value="$2"

    if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 1 || value > 100 )); then
        log_message "ERROR: $name must be between 1 and 100. Received: $value"
        return 1
    fi
}

check_disk() {
    log_message "Checking disk usage..."

    local usage
    usage=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

    if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: Unable to retrieve disk usage."
        return 1
    fi

    if (( usage >= DISK_THRESHOLD )); then
        log_message "WARNING: Disk usage is ${usage}% (threshold: ${DISK_THRESHOLD}%)"
    else
        log_message "OK: Disk usage is ${usage}%"
    fi
}

check_memory() {
    log_message "Checking memory usage..."

    local usage
    usage=$(free | awk '/^Mem:/ {printf "%.0f", ($2-$7)/$2*100}')

    if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: Unable to retrieve memory usage."
        return 1
    fi

    if (( usage >= MEMORY_THRESHOLD )); then
        log_message "WARNING: Memory usage is ${usage}% (threshold: ${MEMORY_THRESHOLD}%)"
    else
        log_message "OK: Memory usage is ${usage}%"
    fi
}

check_cpu() {
    log_message "Checking CPU usage..."

    local idle
    idle=$(top -bn1 | awk -F',' '/Cpu\(s\)/ {
        for (i=1; i<=NF; i++) {
            if ($i ~ /id/) {
                gsub(/[^0-9.]/, "", $i)
                print $i
                exit
            }
        }
    }')

    if [[ -z "$idle" ]]; then
        log_message "ERROR: Unable to determine CPU usage"
        return 1
    fi

    local usage
    usage=$(awk -v idle="$idle" 'BEGIN {
        printf "%.0f", 100-idle
    }')

    if (( usage >= CPU_THRESHOLD )); then
        log_message "WARNING: CPU usage is ${usage}% (threshold: ${CPU_THRESHOLD}%)"
    else
        log_message "OK: CPU usage is ${usage}%"
    fi
}

show_processes() {
    log_message "Top 5 CPU-consuming processes:"

    ps -eo pid,comm,%cpu,%mem --sort=-%cpu |
        awk 'NR == 1 || $2 !~ /^(ps|awk|head)$/ {print}' |
        head -n 6 | tee -a "$LOG_FILE"

    log_message "Top 5 memory-consuming processes:"

    ps -eo pid,comm,%cpu,%mem --sort=-%mem |
        awk 'NR == 1 || $2 !~ /^(ps|awk|head)$/ {print}' |
        head -n 6 | tee -a "$LOG_FILE"
}

main() {
    log_message "========== System Monitoring Started =========="

    check_dependencies || return 1
    validate_threshold "DISK_THRESHOLD" "$DISK_THRESHOLD" || return 1
    validate_threshold "MEMORY_THRESHOLD" "$MEMORY_THRESHOLD" || return 1
    validate_threshold "CPU_THRESHOLD" "$CPU_THRESHOLD" || return 1
    
    check_disk || log_message "Disk monitoring encountered an error."
    check_memory || log_message "Memory monitoring encountered an error."
    check_cpu || log_message "CPU monitoring encountered an error."

    show_processes

    log_message "========== System Monitoring Completed =========="
}

main "$@"
