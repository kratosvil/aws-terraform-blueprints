#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Lab 1 - Single Tier</title></head>
<body>
  <h1>Lab 1 - Single Tier Architecture</h1>
  <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
  <p><strong>Public IP:</strong> ${PUBLIC_IP}</p>
  <p><strong>Availability Zone:</strong> ${AZ}</p>
</body>
</html>
EOF
