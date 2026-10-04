#!/bin/bash

echo "=== MEMORY SNAPSHOT ==="
echo
printf "%-20s %s\n" "USER" "%MEM"
echo "-------------------- -----"

ps aux | awk '{print $1, $4}' | sort -k2 -nr | head -5
