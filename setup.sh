#!/bin/bash

# Update system packages
sudo apt update

# Install OpenJDK 8
echo "-------------------------------------------"
echo "Insatlling openjdk-8-jdk ..."
sudo apt install openjdk-8-jdk -y

# Download and extract Kafka
echo "-------------------------------------------"
echo "Installing Kafka ..."
wget https://archive.apache.org/dist/kafka/3.4.0/kafka_2.13-3.4.0.tgz
tar xzf kafka_2.13-3.4.0.tgz
mv kafka_2.13-3.4.0 kafka
rm kafka_2.13-3.4.0.tgz

# Set Kafka path in environment variables
sleep 2
cdir=$(pwd)
echo "export PATH=\$PATH:$cdir/kafka/bin" >> ~/.bashrc

sleep 2
source ~/.bashrc

# Configure Kafka's advertised listeners using the public IP
echo "-------------------------------------------"
echo "Update Kafka IP Binding"
sleep 2
mip=$(curl ifconfig.me)
echo "advertised.listeners=PLAINTEXT://$mip:9092" >> kafka/config/server.properties

# Install MySQL server
echo "-------------------------------------------"
echo "Installing MySQL Server"
sleep 2
sudo apt install mysql-server -y

# Configure MySQL to allow connections from any IP
echo "-------------------------------------------"
echo "Update MySQL IP Binding"
sleep 2
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

echo "-------------------------------------------"
echo "Restarting MySQL Server"
sleep 2
sudo systemctl restart mysql

# MySQL configuration
echo "------------------------------------------"
echo "Creating Database and New User ..."
sleep 2

sudo mysql -e "CREATE DATABASE IF NOT EXISTS stockdb;
CREATE USER IF NOT EXISTS 'stock'@'%' IDENTIFIED BY 'stock';
GRANT ALL PRIVILEGES ON stockdb.* TO 'stock'@'%';
FLUSH PRIVILEGES;"

echo ""
echo ""
echo "------------------------------------------"
echo "Creating Database nad user ..."
echo "Database Name: stockdb"
echo "username: stock"
echo "password: stock"

echo ""
echo ""
echo "Setup Complete!"
