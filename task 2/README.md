এই ডকুমেন্টেশনটি দেখাবে কিভাবে একটি **Node.js অ্যাপ্লিকেশন** কে **systemd service** হিসেবে কনফিগার করবেন।  

---

## 📋 পূর্বপ্রস্তুতি (Prerequisites)

সেটআপ করার আগে আপনার সিস্টেমে নিচের জিনিসগুলো থাকতে হবে:

- **Systemd সহ একটি লিনাক্স সার্ভার**  
  (Ubuntu 16.04+, CentOS 7+, Debian 8+)

- **sudo বা root অ্যাক্সেস**

- **Node.js এবং npm ইনস্টল করা**  
  ```bash
  node -v
  npm -v
  ```

---

## ⚙️ সেটআপ এবং কনফিগারেশন (Setup and Configuration)

পুরো প্রক্রিয়া ৪টি ধাপে সম্পন্ন হবে।

---

### ✅ ধাপ ১: Node.js অ্যাপ্লিকেশন সেটআপ

```bash
# অ্যাপ্লিকেশন রাখার জন্য একটি ডিরেক্টরি তৈরি করুন
sudo mkdir -p /opt/my-node-app

# app.js ফাইল তৈরি করুন
sudo vim /opt/my-node-app/app.js
```

**`app.js` কোড:**

```javascript
// app.js
const http = require("http");

const PORT = 3000;

const server = http.createServer((req, res) => {
  res.end("Hello, Systemd Service is running!\n");
});

server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
```

---

### ✅ ধাপ ২: ব্যবহারকারী এবং ডিরেক্টরি সেটআপ

```bash
# 'loguser' নামে সিস্টেম ইউজার তৈরি করুন
sudo useradd -r -s /bin/false loguser

# লগ ডিরেক্টরি তৈরি করুন
sudo mkdir -p /home/log

# মালিকানা পরিবর্তন করুন
sudo chown -R loguser:loguser /opt/my-node-app
sudo chown loguser:loguser /home/log
```

---

### ✅ ধাপ ৩: Systemd সার্ভিস ইউনিট তৈরি করা

```bash
sudo vim /etc/systemd/system/my_node_app.service
```

**সার্ভিস ফাইল কনফিগারেশন:**

```ini
[Unit]
Description=My Node.js Application Service
After=network.target

[Service]
User=loguser
Group=loguser

Type=simple
WorkingDirectory=/opt/my-node-app
ExecStart=/usr/bin/node /opt/my-node-app/app.js

Restart=on-failure
RestartSec=5s

StandardOutput=append:/home/log/my_node_app.log
StandardError=append:/home/log/my_node_app.log

[Install]
WantedBy=multi-user.target
```

---

### ✅ ধাপ ৪: লগ রোটেশন কনফিগার করা

```bash
sudo nano /etc/logrotate.d/my_node_app_logrotate
```

**Logrotate config:**

```conf
/home/log/my_node_app.log {
    size 100M
    rotate 30
    daily
    compress
    missingok
    notifempty
    create 0640 loguser loguser
}
```

---

## 🚀 সার্ভিস ব্যবস্থাপনা (Managing the Service)

```bash
# নতুন সার্ভিস লোড করুন
sudo systemctl daemon-reload

# সার্ভিস চালু করুন
sudo systemctl start my_node_app.service

# সার্ভিস স্ট্যাটাস দেখুন
sudo systemctl status my_node_app.service

# বুটে স্বয়ংক্রিয় চালু করতে
sudo systemctl enable my_node_app.service

# সার্ভিস বন্ধ করতে
sudo systemctl stop my_node_app.service

# লাইভ লগ দেখতে
sudo tail -f /home/log/my_node_app.log
```

---

## ✅ যাচাইকরণ এবং পরীক্ষা (Validation and Testing)

### 🔹 প্রাথমিক যাচাইকরণ
```bash
curl http://localhost:3000
```
✔️ যদি আউটপুটে `Hello, Systemd Service is running!` পান, তাহলে সার্ভিস সফলভাবে কাজ করছে।  

---

### 🔹 ব্যর্থতা পুনরুদ্ধার পরীক্ষা (Failure Recovery Test)

```bash
# Node.js প্রসেস খুঁজে বের করুন
ps aux | grep node

# প্রসেস বন্ধ করুন (<PID> পরিবর্তন করুন)
sudo kill -9 <PID>

# স্ট্যাটাস চেক করুন
sudo systemctl status my_node_app.service

# পুনরায় যাচাই করুন
curl http://localhost:3000
```

Systemd স্বয়ংক্রিয়ভাবে সার্ভিসটি রিস্টার্ট করবে।  

---

## 🎯 উপসংহার

এখন আপনার Node.js অ্যাপ্লিকেশনটি একটি **systemd service** হিসেবে চলছে।  
এটি রিস্টার্টেবল, লগ ম্যানেজেবল, এবং প্রোডাকশন-রেডি কনফিগারেশন সহ।  
