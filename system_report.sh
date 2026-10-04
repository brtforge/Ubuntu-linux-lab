g#!/bin/bash

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
