# Vagrant + Bash Script Setup

This project creates 3 Ubuntu VMs using Vagrant and collects CPU, RAM,
and Storage utilization via a Bash script.

## 📌 Prerequisites

-   Vagrant installed
-   VirtualBox installed
-   SSH key available at: `/home/tn-99646/.ssh/id_rsa.pub`

## 🚀 Steps

### 1. Clone or create project folder

``` bash
cd /home/tn-99646/experiment/linux-bash/task 1
```

### 2. Create `Vagrantfile`

-   Paste your **public key** into the `LOCAL_PUBLIC_KEY` section.
-   Run:

``` bash
vagrant up
```

This will create 3 VMs: - server1 → `192.168.56.11` - server2 →
`192.168.56.12` - server3 → `192.168.56.13`

### 3. Test SSH Access

``` bash
ssh vagrant@192.168.56.11
ssh vagrant@192.168.56.12
ssh vagrant@192.168.56.13
```

If login works **without password**, setup is correct.

### 4. Create Metrics Script

Save this file as:

    /home/tn-99646/experiment/linux-bash/task 1/collect_metrics.sh

Make it executable:

``` bash
sudo chmod +x "/home/tn-99646/experiment/linux-bash/task 1/collect_metrics.sh"
```

### 5. Prepare Directories

``` bash
#command gula local laptop ae chalabo. karon local thekke amra vm server gula monitor korbo just script execute kore.
sudo mkdir -p /var/reports
sudo touch /var/log/server-metrics.log
sudo chmod 666 /var/log/server-metrics.log
```

### 6. Run Script

``` bash
sudo "/home/tn-99646/experiment/linux-bash/task 1/collect_metrics.sh"
```

### 7. Validate Results

-   **Check report:**

``` bash
cat /var/reports/report_*.json | jq .
```

-   **Check errors:**

``` bash
cat /var/log/server-metrics.log
```

## ✅ Validation

-   If SSH works without password → Key setup is correct.
-   If JSON report is generated in `/var/reports/` → Script is correct.
-   If errors are logged in `/var/log/server-metrics.log` → Error
    handling works.

------------------------------------------------------------------------
