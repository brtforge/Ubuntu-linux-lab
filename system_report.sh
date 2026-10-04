#!/bin/bash

echo "===== System Report ====="

echo "User: $(whoami)"
echo
echo "Machine: $(hostname)"
echo
echo "Kernel: $(uname -r)"
echo
echo "Uptime: $(uptime)"
echo
echo "Memory: $(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
echo
echo "CPU: $(grep "model name" /proc/cpuinfo | uniq | awk '{print $4, $5, $6, $7, $8}')"

disk_usage=$(df -h | awk '$6 == "/" {print $5}' | sed 's/%//')
echo
echo "Disk Usage: ${disk_usage}%"

if [ "$disk_usage" -lt 80 ]; then
    echo "Disk Status: OK"
elif [ "$disk_usage" -lt 90 ]; then
    echo "Disk Status: WARNING"
else
    echo "Disk Status: CRITICAL"
fi
