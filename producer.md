# Producer

### First install kafka-python

pip install kafka-python

### Import library amd methods

import pandas as pd
from kafka import KafkaProducer
from time import sleep
from json import dumps
import json


### Create Producer Object
producer = KafkaProducer(
    bootstrap_servers=['your-ip-adress:9092'], #change ip here
    value_serializer=lambda x: dumps(x).encode('utf-8')
    )

### start producer
while True:
  dict_stock = df.sample(1).to_dict(orient="records")[0]
  producer.send('demo', value=dict_stock)
  sleep(1)
