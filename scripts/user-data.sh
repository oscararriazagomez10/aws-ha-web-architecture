#!/bin/bash
# 1. Update OS packages
yum update -y

# 2. Install and enable Apache Web Server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# 3. Retrieve EC2 Metadata (Instance ID and Availability Zone)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# 4. Generate dynamic landing page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS High Availability Web Architecture</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #0f172a; color: #f8fafc; text-align: center; margin-top: 100px; }
        .container { background: #1e293b; padding: 40px; border-radius: 12px; display: inline-block; box-shadow: 0 10px 25px rgba(0,0,0,0.5); border: 1px solid #334155; }
        h1 { color: #38bdf8; margin-bottom: 10px; }
        p { color: #94a3b8; font-size: 1.1rem; }
        .highlight { font-weight: bold; color: #f59e0b; font-family: monospace; font-size: 1.2rem; }
        .badge { background-color: #10b981; color: white; padding: 5px 12px; border-radius: 20px; font-size: 0.9rem; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <span class="badge">HTTP 200 OK</span>
        <h1>🚀 High Availability Cluster Active</h1>
        <p>Response served by EC2 Instance: <span class="highlight">$INSTANCE_ID</span></p>
        <p>Availability Zone: <span class="highlight">$AZ</span></p>
    </div>
</body>
</html>
EOF