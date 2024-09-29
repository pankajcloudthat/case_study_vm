# Producer

### First install kafka-python
<pre>
pip install kafka-python
</pre>

### Import library amd methods
<pre>
import pandas as pd
from kafka import KafkaProducer
from time import sleep
from json import dumps
import json
</pre>

### Create Producer Object
<pre>
producer = KafkaProducer(
    bootstrap_servers=['your-ip-adress:9092'], #change ip here
    value_serializer=lambda x: dumps(x).encode('utf-8')
    )
</pre>

### start producer
<pre>
while True:
  dict_stock = df.sample(1).to_dict(orient="records")[0]
  producer.send('demo', value=dict_stock)
  sleep(1)
</pre>
