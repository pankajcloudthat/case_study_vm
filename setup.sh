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
echo "-------------------------------------------10"
sleep 10
cdir=$(pwd)
echo "export PATH=\$PATH:$cdir/kafka/bin" >> ~/.bashrc
source ~/.bashrc

# Configure Kafka's advertised listeners using the public IP
echo "-------------------------------------------02"
sleep 2
mip=$(curl ifconfig.me)
echo "advertised.listeners=PLAINTEXT://$mip:9092" >> kafka/config/server.properties

echo "-------------------------------------------01"
sleep 1
echo "Currect IP: $mip"
echo "advertised.listeners=PLAINTEXT://$mip:9092"


# Install MySQL server
echo "-------------------------------------------01"
sleep 1
sudo apt install mysql-server -y

# Configure MySQL to allow connections from any IP
echo "-------------------------------------------10"
sleep 10
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# MySQL configuration
echo "-------------------------------------------10"
sleep 10
echo "------------------------------------------"
echo "|          Configure MySQL               |"
echo "------------------------------------------"

sudo mysql -e "CREATE DATABASE IF NOT EXISTS stockdb;
CREATE USER IF NOT EXISTS 'stock'@'%' IDENTIFIED BY 'stock';
GRANT ALL PRIVILEGES ON stock.* TO 'stock'@'%';
FLUSH PRIVILEGES;"

# Show databases and users
sudo mysql -e "SHOW DATABASES;"
sudo mysql -e "SELECT User, Host FROM mysql.user;"


echo "-------------------------------------------10"
sleep 5
# Start Zookeeper and Kafka server
nohup zookeeper-server-start.sh kafka/config/zookeeper.properties > zookeeper.log 2>&1 &
nohup kafka-server-start.sh kafka/config/server.properties > broker.log 2>&1 &

# Check if the Kafka broker is running
zookeeper-shell.sh localhost:2181 ls /brokers/ids
