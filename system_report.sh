#!/bin/bash

echo "===== System Report ====="

echo "User: $(whoami)"
echo
echo "Machine: $(hostname)"
echo
echo "Kernel: $(uname -r)"
echo
echo "Uptime: $(uptime)"

