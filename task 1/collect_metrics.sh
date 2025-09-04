#!/bin/bash

# ---------------- Configuration ----------------
servers=("192.168.56.11" "192.168.56.12" "192.168.56.13")
ssh_user="vagrant"
ssh_key="/home/tn-99646/.ssh/id_rsa"

report_dir="/var/reports"
log_file="/var/log/server-metrics.log"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
report_file="$report_dir/report_$timestamp.json"

mkdir -p "$report_dir"
touch "$log_file"

# ---------------- Function to collect metrics ----------------
collect_metrics() {
    server=$1
    {
        cpu=$(ssh -o ConnectTimeout=5 -i "$ssh_key" $ssh_user@$server "top -bn1 | grep 'Cpu(s)' | awk '{print 100-\$8}'" 2>/dev/null)
        ram=$(ssh -o ConnectTimeout=5 -i "$ssh_key" $ssh_user@$server "free -m | awk '/Mem:/ {print \$3}'" 2>/dev/null)
        storage=$(ssh -o ConnectTimeout=5 -i "$ssh_key" $ssh_user@$server "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//'" 2>/dev/null)

        if [[ -n "$cpu" && -n "$ram" && -n "$storage" ]]; then
            echo "{\"server\":\"$server\",\"cpu\":$cpu,\"ram\":$ram,\"storage\":$storage}"
        else
            echo "{\"server\":\"$server\",\"error\":\"unreachable or no data\"}" >> "$log_file"
        fi
    } &
}

# ---------------- Collect metrics in parallel ----------------
results=()
for s in "${servers[@]}"; do
    results+=("$(collect_metrics $s)")
done
wait

# ---------------- Generate JSON report ----------------
echo "[" > "$report_file"
printf "%s\n" "${results[@]}" | jq -s 'sort_by(.storage, .cpu, .ram) | reverse | .[]' >> "$report_file"
echo "]" >> "$report_file"

echo "Report saved at $report_file"

