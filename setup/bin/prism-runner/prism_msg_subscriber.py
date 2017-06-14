#!/usr/bin/env python

import redis
import json


def main():
    "main function"

    # connect to redis
    # fixme: configurable host, port, credentials
    redis_client = redis.StrictRedis(host='pitchfork', port=9006, db=0)

    pubsub = redis_client.pubsub()
    pubsub.subscribe("roslin-run-results")

    while True:

        for item in pubsub.listen():

            data = None

            try:
                data = json.loads(item['data'])
            except Exception:
                pass

            if data is None:
                continue

            # for lsf_job in data["batchSystemJobs"]:

            print json.dumps(data, indent=2)


if __name__ == "__main__":

    main()


# /srv/www/redis/redis-3.2.9/src/redis-cli -p 9006 subscribe roslin-run-results
