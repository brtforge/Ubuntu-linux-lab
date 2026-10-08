#!/bin/bash

#Honestly the most advanced thing i made back then

LOG_FILE="health.log"

mode=""
target="/"
target_set=false

check_dependencies() {

  commands="free lscpu df awk grep find uname hostname uptime date ps cut xargs tail tr"

  for cmd in $commands
  do
    if ! command -v "$cmd" >/dev/null
    then
      echo "Error: Required command '$cmd' is missing"
      exit 1
    fi
  done

}

if [ ! -f "config.conf" ]
then
  echo "Error: config file missing"
  exit 1
fi

source config.conf

memory() {
  echo "Memory:"
  free -h
}

cpu() {
  echo "CPU:"
  lscpu | grep "Model name:" | cut -d: -f2 | xargs
}

processes() {
  echo "Processes:"
  ps -e | head
}

disk() {
  echo "Disk:"
  df -h "$target"
}

files() {
  xfile_count=$(find "$target" -type f -executable | wc -l)
  echo "Executable Files: $xfile_count"
}

check_health() {

  name=$1
  usage=$2
  limit=$3

  echo "$name usage: $usage%"

  if [ "$usage" -ge "$limit" ]
  then
    echo "Warning: $name usage high"
    log_message "WARNING: $name usage: $usage%"
    return 1
  else
    echo "OK"
    log_message "INFO: $name usage: $usage%"
    return 0
  fi

}

disk_health() {
  usage=$(df "$target" | tail -1 | awk '{print $5}' | tr -d '%')
  echo "Current disk usage: $usage%"

  check_health "Disk" "$usage" "$DISK_LIMIT"
}

memory_health() {

 total=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')

 available=$(cat /proc/meminfo | grep MemAvailable | awk '{print $2}')

 used=$((total - available))

 usage=$((used * 100 / total))

 echo "Memory usage: $usage%"

 check_health "Memory" "$usage" "$MEMORY_LIMIT"

}

system_info() {
  echo "System:"
  echo "Hostname: $(hostname)"
  echo "Kernel: $(uname -r)"
  echo "Uptime: $(uptime -p)"
}

log_message() {

    level=$1
    message=$2

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if ! echo "$timestamp [$level] $message" >> "$LOG_FILE"
    then
        echo "ERROR: Unable to write to log file"
        return 1
    fi

}

help() {
  echo "Health Monitor V1.0"
  echo
  echo "Monitors system resources and reports potential health issues"
  echo
  echo "Examples:"
  echo "./system_info.sh -m memory"
  echo "./system_info.sh -m disk_health"
  echo "./system_info.sh -m all"
  echo
  echo "Usage:"
  echo
  echo "$0 -m {system_info|cpu|memory|processes|disk|disk_health|files|memory_health|all} [-t directory]"
  echo
  echo "Modes:"
  echo "system_info     Show system information"
  echo "cpu             Show CPU information"
  echo "memory          Show memory information"
  echo "processes       Show running processes"
  echo "disk            Show disk information"
  echo "disk_health     Check disk usage"
  echo "files           Count executable files"
  echo "memory_health   Check memory usage"
  echo "all             Run complete health report"
  echo
  echo "Options:"
  echo "-m   Select monitoring mode"
  echo "-t   Select target directory"
  echo "-h   Show help"
}

separator() {
  echo "---------------------------------------------------------------------------------------"
}

print_header() {

  echo "====================================================================================="
  echo "                                Health Monitor V1.0"
  echo "====================================================================================="
  echo "Report Time: $(date)"
  echo

}

main() {

  print_header

  system_info
  separator
  echo
  memory
  echo
  separator
  echo
  cpu
  separator
  echo
  processes
  separator
  echo
  disk
  separator
  echo

  overall_status=0

  disk_health

  if [ $? -ne 0 ]
  then
    overall_status=1
  fi

  separator
  echo

  memory_health

  if [ $? -ne 0 ]
  then
    overall_status=1
  fi

  separator
  echo
  files

  separator
  echo

  if [ "$overall_status" -eq 0 ]
  then
    echo "Overall Status: HEALTHY"
  else
    echo "Overall Status: WARNING"
  fi

  exit $overall_status
}


while getopts "m:t:h" option
do
  case $option in

    m)
      mode=$OPTARG
      ;;

    t)
      target=$OPTARG
      target_set=true
      ;;

    h)
      help
      exit 0
      ;;

    *)
      help
      exit 1
      ;;

  esac
done


if [ -z "$mode" ]
then
  echo "Error: No mode selected"
  help
  exit 1
fi

if [ "$target_set" = true ] && [ "$target_supported" = false ]
then
  echo "Error: Option '-t' cannot be used with mode '$mode'"
  exit 1
fi

case "$mode" in
  disk|disk_health|files)
    ;;
  *)
    if [ "$target_set" = true ]
    then
      echo "Error: Option '-t' cannot be used with mode '$mode'"
      exit 1
    fi
    ;;
esac

case "$mode" in

  system_info|cpu|memory|processes|disk|files|disk_health|memory_health|all)
    ;;

  *)
    echo "Error: Invalid mode: $mode"
    help
    exit 1
    ;;

esac

case "$mode" in
  disk|disk_health|files)
    target_supported=true
    ;;
  *)
    target_supported=false
    ;;
esac

case "$mode" in
  system_info)
    system_info
    ;;

  cpu)
    cpu
    ;;

  memory)
    memory
    ;;

  processes)
    processes
    ;;

  files)
    files
    ;;

  disk)
    disk
    ;;

  disk_health)
    disk_health
    ;;

  memory_health)
    memory_health
    ;;

  all)
    main
    ;;

esac


