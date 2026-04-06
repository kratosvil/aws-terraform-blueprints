#!/bin/bash
yum update -y
yum install -y httpd mysql
systemctl start httpd
systemctl enable httpd

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Lab 2 - Two Tier</title></head>
<body>
  <h1>Lab 2 - Two-Tier Architecture</h1>
  <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
  <p><strong>Public IP:</strong> ${PUBLIC_IP}</p>
  <p><strong>Availability Zone:</strong> ${AZ}</p>
  <p><strong>DB:</strong> MySQL RDS (private subnet - not publicly accessible)</p>
</body>
</html>
EOF
