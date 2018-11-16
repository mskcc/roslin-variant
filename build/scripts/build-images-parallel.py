#!/usr/bin/python

import json
import argparse
import multiprocessing
from multiprocessing.dummy import Pool, current_process
import logging
from subprocess import Popen, PIPE
import sys
import os
from Queue import Queue

logger = logging.getLogger("build_images_parallel")
logger.setLevel(logging.INFO)
log_file_handler = logging.FileHandler('build_images_parallel.log')
log_stream_handler = logging.StreamHandler()
log_file_handler.setLevel(logging.INFO)
log_stream_handler.setLevel(logging.INFO)
log_formatter = logging.Formatter('%(asctime)s - %(message)s')
log_file_handler.setFormatter(log_formatter)
log_stream_handler.setFormatter(log_formatter)
logger.addHandler(log_file_handler)
logger.addHandler(log_stream_handler)

def construct_jobs(tool_json,status_queue):
    job_list = []    
    for single_image_name in tool_json['programs']:
        image_name = single_image_name
        single_image = tool_json['programs'][single_image_name]
        for single_version in single_image:
            image_version = single_version
            single_job = (image_name,image_version,status_queue)
            job_list.append(single_job)
    return job_list

def build_image(image_job):
    image_name = image_job[0]
    image_version = image_job[1]
    status_queue = image_job[2]
    image_id_str = str(image_name) + " version " + str(image_version)
    logger.info("Building " + image_id_str)
    image_id = str(image_name) + ':' + str(image_version)
    command = ["/vagrant/build/scripts/build-images.sh","-t",image_id]    
    process = Popen(command, stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()
    exit_code = process.returncode 
    output = {'image_id':image_id,'stdout':stdout,'stderr':stderr,'status':exit_code,'name':current_process().name}
    status_queue.put(output)

def verbose_logging(single_item):
    stdout_logging = '---------- STDOUT of '+ single_item["image_id"] + ' ----------\n' + single_item["stdout"]
    stderr_logging = '---------- STDERR of '+ single_item["image_id"] + ' ----------\n' + single_item["stderr"]
    logger.info(stdout_logging)
    logger.info(stderr_logging)

def build_parallel(threads,tool_json,debug_mode):
    status_queue = Queue()
    job_list = construct_jobs(tool_json,status_queue)    
    pool = Pool(threads)
    build_results = pool.map_async(build_image,job_list)
    total_number_of_jobs = len(job_list)
    total_processed = 0
    while build_results.ready() == False:
        single_item = status_queue.get()
        if single_item['status'] == 0:
            total_processed = total_processed + 1
            logger.info("["+single_item['name']+"] " + single_item["image_id"] + " finished building ( " + str(total_processed) + "/"+str(total_number_of_jobs)+" )")
            if debug_mode == True:
                verbose_logging(single_item)
        else:
            status_message = "["+single_item['name']+"] " + single_item["image_id"] + " failed to build"
            verbose_logging(single_item)
            logger.info(status_message)
            pool.terminate()
            sys.exit(status_message) 
    pool.close()
    pool.join()
    logger.info("---------- Finished building images ----------")

def move_images():
    command=["/vagrant/build/scripts/move-container-artifacts-to-setup.sh"]
    process = Popen(command, stdout=PIPE, stderr=PIPE)
    logger.info("---------- Moving Images ----------")    
    stdout, stderr = process.communicate()
    exit_code = process.returncode
    if stdout:
        logger.info(stdout)
    if stderr:
        logger.info(stderr)
    if exit_code != 0:
        status_message = "Moving Images Failed"
        logger.info(status_message)
        sys.exit(status_message)

def main():
    parser = argparse.ArgumentParser(description='build-images-parallel')
    parser.add_argument(
        '-t',
        action="store",
        dest="threads",
        type=int,
        help='Number of threads'
    )
    parser.add_argument(
        '-f',
        action='store',
        dest='filename',
        help='Filename of the JSON tools definition',
        default='tools.json'
    )
    parser.add_argument(
        '-d',
        action='store_true',
        dest='debug_mode',
        help="Verbose logging"
    )
    params = parser.parse_args()
    with open(params.filename, "r") as file_in:
        tools = json.load(file_in)

    build_parallel(params.threads,tools,params.debug_mode)
    move_images()


if __name__ == "__main__":
    main()
