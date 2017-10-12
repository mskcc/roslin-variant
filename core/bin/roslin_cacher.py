#!/usr/bin/env python

import os
import time
import subprocess
import redis
import argparse
import zlib
import base64
from datetime import datetime


def poll(lsf_queue, only_me):
    "store bjobs output in Redis every x seconds"

    # connect to redis
    redis_host = os.environ.get("ROSLIN_REDIS_HOST")
    redis_port = int(os.environ.get("ROSLIN_REDIS_PORT"))
    redis_client = redis.StrictRedis(host=redis_host, port=redis_port, db=0)

    bjobs = [
        "bjobs",
        "-a",
        "-o", "user jobid proj_name job_name stat submit_time start_time finish_time run_time effective_resreq exec_host delimiter='\t'",
        "-q", lsf_queue,
        "-noheader"
    ]

    if not only_me:
        bjobs.extend(["-u", "all"])

    process = subprocess.Popen(bjobs, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    data = process.stdout.read()

    # compress and base64
    msg = base64.b64encode(zlib.compress(data))

    redis_client.set('bjobs', msg)
    print "sent: {0:,} bytes ({1})".format(len(msg), datetime.now().strftime("%H:%M:%S"))


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='cacher')

    parser.add_argument(
        "--queue",
        action="store",
        dest="lsf_queue",
        help="name of LSF queue",
        required=True
    )

    parser.add_argument(
        "--interval",
        action="store",
        dest="polling_interval",
        help="Polling interval in seconds",
        type=float,
        default=30
    )

    parser.add_argument(
        "--only-me",
        action="store_true",
        default=False,
        dest="only_me",
        help="caches in Redis only the jobs that belong to you"
    )

    params = parser.parse_args()

    while True:
        poll(params.lsf_queue, params.only_me)
        time.sleep(params.polling_interval)
