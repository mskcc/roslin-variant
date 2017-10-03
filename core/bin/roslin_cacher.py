#!/usr/bin/env python

import os
import time
import subprocess
import redis
import zlib
import base64
from datetime import datetime


def poll():

    # connect to redis
    redis_host = os.environ.get("ROSLIN_REDIS_HOST")
    redis_port = int(os.environ.get("ROSLIN_REDIS_PORT"))
    redis_client = redis.StrictRedis(host=redis_host, port=redis_port, db=0)

    bjobs = [
        "bjobs",
        "-u", "all",
        "-a",
        "-o", "user jobid proj_name job_name stat submit_time start_time finish_time run_time effective_resreq exec_host delimiter='\t'",
        "-noheader"
    ]

    process = subprocess.Popen(bjobs, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    data = process.stdout.read()

    # compress and base64
    msg = base64.b64encode(zlib.compress(data))

    redis_client.set('bjobs', msg)
    print "sent: {0:,} bytes ({1})".format(len(msg), datetime.now().strftime("%H:%M:%S"))


if __name__ == "__main__":

    # in seconds
    polling_interval = 30

    while True:
        poll()
        time.sleep(polling_interval)
