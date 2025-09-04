## সংক্ষিপ্ত বিবরণ (Summary)

এই প্রকল্পটি একটি সাধারণ ব্যাশ স্ক্রিপ্ট প্রদান করে যা Docker ব্যবহার করে একটি Nginx ওয়েব সার্ভার স্বয়ংক্রিয়ভাবে ডেপ্লয় করার প্রক্রিয়া বর্ণনা করে। এই স্ক্রিপ্টটি বিশেষভাবে নতুনদের জন্য তৈরি করা হয়েছে, যেখানে প্রতিটি ধাপ সহজবোধ্য এবং কোডের ফ্লো সোজাসাপ্টা রাখা হয়েছে। এর প্রধান বৈশিষ্ট্য হলো শক্তিশালী এরর হ্যান্ডলিং এবং স্বয়ংক্রিয় রোলব্যাক, যা ডেপ্লয়মেন্ট প্রক্রিয়ার যেকোনো ব্যর্থতায় সিস্টেমকে পরিচ্ছন্ন রাখে।

## বৈশিষ্ট্য (Features)

- **সম্পূর্ণ স্বয়ংক্রিয়:** একটি মাত্র কমান্ডে Nginx কন্টেইনার ডেপ্লয়মেন্ট সম্পন্ন হয়।
- **কাস্টমাইজেশন:** ডিফল্ট Nginx ওয়েবপেজকে একটি কাস্টম `index.html` ফাইল দ্বারা প্রতিস্থাপন করে।
- **নিরাপদ রোলব্যাক:** ডেপ্লয়মেন্টের যেকোনো ধাপে (যেমন: ইমেজ খুঁজে না পাওয়া, ফাইল কপি করতে ব্যর্থ হওয়া) ব্যর্থ হলে, স্ক্রিপ্টটি স্বয়ংক্রিয়ভাবে তৈরি করা সমস্ত রিসোর্স (কন্টেইনার, নেটওয়ার্ক) মুছে ফেলে।
- **সহজবোধ্য কোড:** ফাংশন বা জটিল লজিকের পরিবর্তে সরল, রৈখিক (linear) কমান্ড এবং `if/else` কন্ডিশন ব্যবহার করা হয়েছে, যা নতুনদের জন্য বোঝা খুব সহজ।
- **পোর্ট ম্যাপিং:** হোস্ট মেশিনের একটি নির্দিষ্ট পোর্টের (যেমন: `8888`) মাধ্যমে Nginx সার্ভার অ্যাক্সেস করার সুবিধা।
- **লগিং:** ডেপ্লয়মেন্ট সফল হলে `/var/log/nginx-deploy.log` ফাইলে একটি টাইমস্ট্যাম্পসহ লগ সংরক্ষণ করে।

## পূর্বপ্রস্তুতি (Prerequisites)

এই স্ক্রিপ্টটি চালানোর জন্য আপনার সিস্টেমে নিম্নলিখিত জিনিসগুলো থাকতে হবে:

1.  **Docker ইনস্টল থাকা:**
    আপনি নিচের কমান্ড দিয়ে ইনস্টলেশন পরীক্ষা করতে পারেন:
    ```bash
    docker --version
    ```
2.  **`sudo` বা `root` অ্যাক্সেস:**
    সিস্টেম ডিরেক্টরিতে লগ ফাইল লেখা এবং Docker কমান্ড চালানোর জন্য।

## কিভাবে ব্যবহার করবেন (How to Use)

### ধাপ ১: আপনার ওয়েবপেজ প্রস্তুত করুন

স্ক্রিপ্টটি চালানোর আগে, আপনাকে একটি কাস্টম `index.html` ফাইল তৈরি করতে হবে যা Nginx সার্ভারে দেখানো হবে।

```bash
# আপনার হোম ডিরেক্টরিতে একটি ফোল্ডার তৈরি করুন
mkdir ~/my_webpage

# সেই ফোল্ডারের ভেতরে একটি index.html ফাইল তৈরি করুন
echo "<h1>My First Automated Deployment is a Success!</h1>" > ~/my_webpage/index.html
```

### ধাপ ২: ডেপ্লয়মেন্ট স্ক্রিপ্টটি তৈরি করুন

নিচের সম্পূর্ণ কোডটি `deploy_nginx.sh` নামে একটি ফাইলে সেভ করুন।

```bash
#!/bin/bash

# --- চূড়ান্ত, নির্ভরযোগ্য এবং ফ্রেসার-ফ্রেন্ডলি ডেপ্লয়মেন্ট স্ক্রিপ্ট ---

echo "--- Starting Deployment ---"

# ধাপ ১: নেটওয়ার্ক তৈরি করা
echo "Step 1: Creating Docker network 'fresher-net'..."
docker network create fresher-net
if [ $? -ne 0 ]; then
    echo "ERROR: Could not create the network. Stopping."
    exit 1
fi

# ধাপ ২: Nginx কন্টেইনার চালানো
echo "Step 2: Running Nginx container 'fresher-nginx'..."
docker run -d --name fresher-nginx --network fresher-net -p 8888:80 nginx
if [ $? -ne 0 ]; then
    echo "ERROR: Could not run the container. Rolling back..."
    docker network rm fresher-net
    exit 1
fi

# ধাপ ৩: কন্টেইনার চালু হওয়ার জন্য অপেক্ষা করা
echo "Step 3: Waiting for 10 seconds for the container to start..."
sleep 10

# ধাপ ৪: নতুন ওয়েবপেজ কপি করা
echo "Step 4: Copying the new homepage..."
# নিচের লাইনে 'your_username' পরিবর্তন করে আপনার নিজের ইউজারনেম লিখুন
docker cp /home/your_username/my_webpage/index.html fresher-nginx:/usr/share/nginx/html/index.html
if [ $? -ne 0 ]; then
    echo "ERROR: Could not copy the file. Rolling back..."
    docker stop fresher-nginx; docker rm fresher-nginx; docker network rm fresher-net
    exit 1
fi

# অতিরিক্ত অপেক্ষা, যেন Nginx নতুন ফাইল লোড করতে পারে
echo "Step 4.5: Waiting 2 seconds for Nginx to serve the new file..."
sleep 2

# ধাপ ৫: সব ঠিক আছে কিনা তা পরীক্ষা করা
echo "Step 5: Verifying the change..."
curl -s http://localhost:8888 | grep -i -q "My First Automated Deployment is a Success!"
if [ $? -ne 0 ]; then
    echo "ERROR: Verification failed. The content is not updated. Rolling back..."
    echo "--- What curl sees: ---"
    curl http://localhost:8888
    echo "-------------------------"
    docker stop fresher-nginx; docker rm fresher-nginx; docker network rm fresher-net
    exit 1
fi

# যদি সব ধাপ সফল হয়
echo "----------------------------------------"
echo "Success! Nginx container is deployed and updated."
echo "You can check it at http://localhost:8888"
echo "----------------------------------------"
echo "$(date): Deployment of fresher-nginx was successful." | sudo tee -a /var/log/nginx-deploy.log
exit 0
```

### ধাপ ৩: স্ক্রিপ্টটি কাস্টমাইজ করুন (গুরুত্বপূর্ণ!)

স্ক্রিপ্টটি চালানোর আগে, আপনাকে অবশ্যই `deploy_nginx.sh` ফাইলটি এডিট করে `docker cp` কমান্ডের পাথটি আপনার নিজের ইউজারনেম দিয়ে পরিবর্তন করতে হবে।

`your_username` লেখাটি খুঁজে বের করুন এবং আপনার আসল ইউজারনেম দিন:
```bash
# পুরনো লাইন
docker cp /home/your_username/my_webpage/index.html fresher-nginx:/usr/share/nginx/html/index.html

# উদাহরণস্বরূপ, আপনার ইউজারনেম 'sadman' হলে:
docker cp /home/sadman/my_webpage/index.html fresher-nginx:/usr/share/nginx/html/index.html
```

### ধাপ ৪: স্ক্রিপ্টটি চালান

১. স্ক্রিপ্ট ফাইলটিকে এক্সিকিউটেবল করুন:
   ```bash
   chmod +x deploy_nginx.sh
   ```
২. `sudo` দিয়ে স্ক্রিপ্টটি চালান:
   ```bash
   sudo ./deploy_nginx.sh
   ```

## যাচাইকরণ (Verification)

ডেপ্লয়মেন্ট সফল হলে, আপনি নিচের কমান্ডগুলো দিয়ে তা যাচাই করতে পারেন:

* **চলমান কন্টেইনার দেখুন:**
  ```bash
  sudo docker ps
  ```
* **ওয়েবপেজটি পরীক্ষা করুন:**
  ```bash
  curl http://localhost:8888
  ```
  আপনি আউটপুট হিসেবে `<h1>My First Automated Deployment is a Success!</h1>` দেখতে পাবেন।
* **লগ ফাইল দেখুন:**
  ```bash
  sudo tail /var/log/nginx-deploy.log
  ```

## রোলব্যাক ফিচার পরীক্ষা করা

স্ক্রিপ্টের রোলব্যাক ফিচারটি পরীক্ষা করতে, `deploy_nginx.sh` ফাইলটি এডিট করুন এবং `docker run` কমান্ডের `nginx` ইমেজটিকে একটি ভুল নাম দিন (যেমন `nginx:nonexistent`)। এরপর স্ক্রিপ্টটি আবার চালান। আপনি দেখবেন যে এটি `Step 2`-এ ব্যর্থ হবে এবং স্বয়ংক্রিয়ভাবে তৈরি করা `fresher-net` নেটওয়ার্কটি ডিলিট করে দেবে।