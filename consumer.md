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
    insert_query = """
    INSERT INTO StockData (IndexName, Date, Open, High, Low, Close, AdjClose, Volume, CloseUSD)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
    """
    for message in messages_list:
      print(f"Consumed: {message.value}")

      json_object = message.value

      json_object['Date'] = datetime.strptime(json_object['Date'], '%Y-%b-%d').strftime('%Y-%m-%d')

      cursor.execute(insert_query, (
          json_object['Index'],
          json_object['Date'],
          json_object['Open'],
          json_object['High'],
          json_object['Low'],
          json_object['Close'],
          json_object['Adj Close'],  # Use underscore for the column name
          json_object['Volume'],
          json_object['CloseUSD']
      ))

    conn.commit()
    cursor.close()
  else:
    print("No message from producer")
</pre>
