import time
import subprocess
import redis
import zlib
import base64

def poll():

    # connect to redis
    # fixme: configurable host, port, credentials
    redis_client = redis.StrictRedis(host='pitchfork', port=9006, db=0)

    bjobs = [
        "bjobs",
        "-u", "all",
        "-a",
        "-o", "jobid proj_name job_name stat submit_time start_time finish_time run_time effective_resreq exec_host delimiter='\t'",
        "-noheader"
    ]

    process = subprocess.Popen(bjobs, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    data = process.stdout.read()

    # 10mb to 88K

    msg = base64.b64encode(zlib.compress(data))

    redis_client.set('bjobs', msg)
    print "sent: {} bytes".format(len(msg))


if __name__ == "__main__":

    while True:
        poll()
        time.sleep(30)
