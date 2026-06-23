#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node Exporter for Prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

cat > /etc/systemd/system/node_exporter.service << 'INNEREOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=ec2-user
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
INNEREOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

# Install CloudWatch Agent
yum install -y amazon-cloudwatch-agent

# Create Docker run script for Drupal
mkdir -p /opt/drupal
cat > /opt/drupal/run.sh << 'INNEREOF'
#!/bin/bash
docker pull austinodocker/drupal-app:v1
docker stop drupal || true
docker rm drupal || true
docker run -d \
  --name drupal \
  -p 80:80 \
  -e DB_HOST=${rds_endpoint} \
  -e DB_NAME=drupaldb \
  -e DB_USER=drupaladmin \
  -e DB_PASSWORD=${db_password} \
  -v drupal-files:/var/www/html/sites/default/files \
  --restart always \
  austinodocker/drupal-app:v1
INNEREOF

chmod +x /opt/drupal/run.sh

# Run the script
/opt/drupal/run.sh
