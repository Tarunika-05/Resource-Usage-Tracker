#!/bin/bash

# Define log file path
log_file="./system_monitor.log"
history_file="./history.log"
echo "" > $log_file


# Define threshold percentages for alerting
cpu_threshold=80.0
mem_threshold=80.0
disk_user_threshold=80.0

# Centered heading function with hyphens
center_heading() {
    local heading="$1"
    local width=100
    local padding=$(($width - ${#heading} - 2))
    local hyphens=$(printf '%*s' "$((padding / 2))" | tr ' ' '-')
    printf "%s %s %s\n" "$hyphens" "$heading" "$hyphens"
}

# Get system information
hostname=$(hostname)
ip_address=$(hostname -I | awk '{print $1}')
uptime=$(uptime -p)
os_info=$(lsb_release -d | awk '{print $2, $3, $4}')
kernel_version=$(uname -r)
architecture=$(uname -m)
processor=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
cpu_cores=$(nproc)
total_ram=$(free -h | awk '/^Mem:/ {print $2}')

# Log system information
center_heading "System Information" >> $log_file
echo "Hostname        : $hostname" >> $log_file
echo "IP Address      : $ip_address" >> $log_file
echo "Uptime          : $uptime" >> $log_file
echo "Operating System: $os_info" >> $log_file
echo "Kernel Version  : $kernel_version" >> $log_file
echo "Architecture    : $architecture" >> $log_file
echo "Processor       : $processor" >> $log_file
echo "CPU Cores       : $cpu_cores" >> $log_file
echo "Total RAM       : $total_ram" >> $log_file
echo "" >> $log_file

center_heading "System Information" >> $history_file
echo "Hostname        : $hostname" >> $history_file
echo "IP Address      : $ip_address" >> $history_file
echo "Uptime          : $uptime" >> $history_file
echo "Operating System: $os_info" >> $history_file
echo "Kernel Version  : $kernel_version" >> $history_file
echo "Architecture    : $architecture" >> $history_file
echo "Processor       : $processor" >> $history_file
echo "CPU Cores       : $cpu_cores" >> $history_file
echo "Total RAM       : $total_ram" >> $history_file
echo "" >> $history_file

# Get resource usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
mem_usage=$(free | awk '/^Mem:/ {print $3/$2 * 100.0}')
disk_usage=$(iostat -c | awk 'NR==4 {print $1, $2, $3, $6}')

# Initialize alerts
alerts=""

# Check for alerts
if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
    alerts+="ALERT: CPU usage is high ($cpu_usage%)\n"
fi

if (( $(echo "$mem_usage > $mem_threshold" | bc -l) )); then
    alerts+="ALERT: Memory usage is high ($mem_usage%)\n"
fi

# Disk usage values
disk_user=$(echo $disk_usage | awk '{print $1}')
disk_system=$(echo $disk_usage | awk '{print $2}')
disk_iowait=$(echo $disk_usage | awk '{print $3}')
disk_idle=$(echo $disk_usage | awk '{print $4}')

if (( $(echo "$disk_user > $disk_user_threshold" | bc -l) )); then
    alerts+="ALERT: Disk user usage is high ($disk_user%)\n"
fi

# Log resource usage
center_heading "Resource Usage" >> $log_file
echo "CPU Usage       : $cpu_usage%" >> $log_file
echo "Memory Usage    : $mem_usage%" >> $log_file
center_heading "Disk Usage" >> $log_file
echo "  User   : $disk_user%" >> $log_file
echo "  System : $disk_system%" >> $log_file
echo "  Iowait : $disk_iowait%" >> $log_file
echo "  Idle   : $disk_idle%" >> $log_file
echo "" >> $log_file
# Log resource usage
center_heading "Resource Usage" >> $history_file
echo "CPU Usage       : $cpu_usage%" >> $history_file
echo "Memory Usage    : $mem_usage%" >> $history_file
center_heading "Disk Usage" >> $history_file
echo "  User   : $disk_user%" >> $history_file
echo "  System : $disk_system%" >> $history_file
echo "  Iowait : $disk_iowait%" >> $history_file
echo "  Idle   : $disk_idle%" >> $history_file
echo "" >> $history_file

# Display system status message
if [ -z "$alerts" ]; then
    echo "System status: All systems are operating within normal parameters." >> $log_file
    echo "System status: All systems are operating within normal parameters." >> $history_file
else
    echo -e "$alerts" >> $log_file
    echo -e "$alerts" >> $history_file
fi

# Email the log file
email_subject="System Monitoring Report for $hostname"
email_recipient="tarunikaa2005@gmail.com"
email_sender="linuxsender24@gmail.com"

# Send the email with the log file content
mail -s "$email_subject" -r "$email_sender" "$email_recipient" < $log_file

# ---- REST API JSON Output ----

# Create a JSON object for system information and usage
system_info=$(cat <<EOF
{
    "hostname": "$hostname",
    "ip_address": "$ip_address",
    "uptime": "$uptime",
    "os_info": "$os_info",
    "kernel_version": "$kernel_version",
    "architecture": "$architecture",
    "processor": "$processor",
    "cpu_cores": "$cpu_cores",
    "total_ram": "$total_ram",
    "cpu_usage": "$cpu_usage%",
    "memory_usage": "$mem_usage%",
    "disk_usage": {
        "user": "$disk_user%",
        "system": "$disk_system%",
        "iowait": "$disk_iowait%",
        "idle": "$disk_idle%"
    }
}
EOF
)

# Save the JSON to a file (optional, for API usage)
echo "$system_info" > /mnt/c/project/system_info.json

# Alternatively, if you need to send this data to an API, you can use curl to POST it
# curl -X POST -H "Content-Type: application/json" -d "$system_info" http://your_api_url/endpoint

# You can now retrieve this system information using the Flask API from the system_info.json file
