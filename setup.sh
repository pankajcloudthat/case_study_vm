#!/bin/bash

# Update system packages
sudo apt update

# Install OpenJDK 8
sudo apt install openjdk-8-jdk -y

# Download and extract Kafka
wget https://archive.apache.org/dist/kafka/3.4.0/kafka_2.13-3.4.0.tgz
tar xzf kafka_2.13-3.4.0.tgz
mv kafka_2.13-3.4.0 kafka
rm kafka_2.13-3.4.0.tgz

# Set Kafka path in environment variables
echo "-------------------------------------------"
sleep 10
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
sleep 2
sudo apt install mysql-server -y

# Configure MySQL to allow connections from any IP
echo "-------------------------------------------"
echo "Update MySQL IP Binding"
sleep 2
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

sleep 2
sudo systemctl restart mysql

# MySQL configuration

echo "------------------------------------------"
echo "|          Configure MySQL               |"
echo "------------------------------------------"
sleep 10

sudo mysql -e "CREATE DATABASE IF NOT EXISTS stockdb;
CREATE USER IF NOT EXISTS 'stock'@'%' IDENTIFIED BY 'stock';
GRANT ALL PRIVILEGES ON stock.* TO 'stock'@'%';
FLUSH PRIVILEGES;"
