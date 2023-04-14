#!/usr/bin/env python3

import time
import random

import boto3

client = boto3.client("kinesis", region_name="eu-central-1")


STREAM_NAME = "demo-event-log-stream"


try:
    while True:
        time.sleep(1)
        data = bytes(str(random.randint(1, 100)).encode("utf-8"))
        print(f"Sending {data=}")
        response = client.put_record(StreamName=STREAM_NAME, Data=data, PartitionKey="A")
        # print(f"Received {response=}")
except KeyboardInterrupt:
    print("Finishing due to keyboard interrupt")
