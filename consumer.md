# Consumer

### install packages for python kafka and MySQL
<pre>
pip install kafka-python
pip install mysql-connector-python
</pre>

### Import library and packages
<pre>
from kafka import KafkaConsumer
from time import sleep
from json import dumps,loads
import json
import mysql.connector
from mysql.connector import Error
from datetime import datetime
</pre>

### create Kafka Consumer Object
<pre>
consumer = KafkaConsumer(
    'demo',
    bootstrap_servers=['your-ip-address:9092'], #add your IP here
    auto_offset_reset='latest',  # Start from the earliest message
    enable_auto_commit=True,
    value_deserializer=lambda x: loads(x.decode('utf-8')))
</pre>

### Create MySQL Connection Object
<pre>
try:
  conn = mysql.connector.connect(
      host='your-ip-address',    # Remote MySQL server address
      user='stock',           # MySQL username
      password='stock',       # MySQL password
      database='stockdb',       # The database you want to connect to
      port=3306               # Default MySQL port (you can change it if necessary)
  )
except Error as e:
  print(f"Error connecting to MySQL: {e}")
</pre>

### Start Consumer
<pre>
while True:
  sleep(10)
  msg = consumer.poll(timeout_ms=10000)
  if msg:
    for topic_partition, messages_list in msg.items():
      print("\n\nBatch count: ", len(messages_list), "\n\n")

    cursor = conn.cursor()
   
    # Insert statement
    # Form your insert statement test it locally, replace the col1, col2, col3,... name and their coreesponting value with %s, %s, %s, ...
    insert_query = """
    INSERT INTO StockData (col1, col2, col3, ...)
    VALUES (%s, %s, %s, ...);
    """
   
    for message in messages_list:
      
      # message.value return a python dict object
      data = message.value
      print(f"Consumed: {data}")

      # Write your logic here to transform the data

      cursor.execute(insert_query, (
          data['col1'],
          data['col2'],
          data['col3'],
          .
          .
          .
      ))

    conn.commit()
    cursor.close()
  else:
    print("No message from producer")
</pre>
