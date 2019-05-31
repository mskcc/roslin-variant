#!/usr/bin/python

import json
import argparse
import multiprocessing
from multiprocessing.dummy import Pool, current_process
import logging
from subprocess import Popen, PIPE, call
import sys
import os
from Queue import Queue
import traceback
import ast
import tempfile
import shutil
import signal
import time

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
script_path = os.path.dirname(os.path.realpath(__file__))

def construct_jobs(tool_json,status_queue,build_docker,build_singularity,docker_registry,docker_push):
    job_list = []
    for single_image_name in tool_json['programs']:
        image_name = single_image_name
        single_image = tool_json['programs'][single_image_name]
        for single_version in single_image:
            image_version = single_version
            single_job = (image_name,image_version,build_docker,build_singularity,docker_registry,docker_push,status_queue)
            job_list.append(single_job)
    return job_list

def build_image_wrapper(image_info):
    image_name = image_info[0]
    image_version = image_info[1]
    status_queue = image_info[6]
    image_id = str(image_name) + ":" + str(image_version)
    done = False
    retry_attempts = 4
    current_attempt = 1
    try:
        while not done:
            build_output = build_image(*image_info)
            if build_output['status'] != 0:
                if current_attempt < retry_attempts:
                    retry_message = image_id + " failed to build. Retrying\n ({}/{})".format(str(current_attempt),str(retry_attempts))
                    current_attempt = current_attempt + 1
                    logger.info(retry_message)
                    verbose_logging(build_output)
                    time.sleep(60)
                else:
                    done = True
            else:
                done = True
        status_queue.put(build_output)
    except:
        error_message = "Error: " + str(image_name) + " version " + str(image_version) + " failed\n " + traceback.format_exc()
        logger.error(error_message)
        output = {'image_id':image_id,'stdout':None,'stderr':error_message,'status':1,'name':current_process().name,'meta':None}
        status_queue.put(output)

def build_image(image_name,image_version,build_docker,build_singularity,docker_registry,docker_push,status_queue):
    image_id_str = str(image_name) + " version " + str(image_version)
    logger.info("Building " + image_id_str)
    image_id = str(image_name) + ':' + str(image_version)
    build_script_path = os.path.join(script_path,'build-images.sh')
    command = [build_script_path]
    if build_docker:
        command.append('-d')
    if build_singularity:
        command.append('-s')
    if docker_registry:
        command.extend(['-r',docker_registry])
    if docker_push:
        command.append('-p')
    command.extend(["-t",image_id])
    process = Popen(command, stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()
    exit_code = process.returncode
    meta_info = None
    if exit_code == 0 and build_singularity:
        container_path = os.path.abspath(os.path.join(script_path,os.pardir,"containers",image_name,image_version))
        image_name = image_name + ".sif"
        meta_info = create_meta_info(container_path,image_name)
    output = {'image_id':image_id,'stdout':stdout,'stderr':stderr,'status':exit_code,'name':current_process().name,'meta':meta_info}
    return output

def docker_login():
    logger.info("Logging into Docker")
    login_script_path = os.path.join(script_path,'docker-login.sh')
    command = login_script_path
    exit_code = call(command, shell=True)
    if exit_code != 0:
        print "Docker login failed"
        exit(1)

def create_meta_info(container_dir,image_name):
    container_path = os.path.join(container_dir,image_name)
    run_script_path = os.path.join(container_dir,"runscript.sh")
    temp_dir = tempfile.mkdtemp()
    temp_container_path = os.path.join(temp_dir,image_name)
    shutil.copyfile(container_path,temp_container_path)
    retrieve_labels_command = ["singularity","exec",temp_container_path,"cat","/labels.json"]
    process = Popen(retrieve_labels_command, stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()
    exit_code = process.returncode
    if exit_code != 0:
        logger.info("Label retrieval failed: " + stderr)
        labels = ""
    else:
        labels = json.loads(stdout)
    meta_info = {}
    found_help = False
    command_type = "Single"
    with open(run_script_path) as run_script_file:
        for single_line in run_script_file:
            split_word = None
            if "echo" in single_line and not found_help:
                split_word = "echo"
            elif "exec" in single_line:
                split_word = "exec"
            if split_word:
                command = split_word + " " + single_line.split(split_word,1)[1].replace(';;','').strip()
                if not found_help:
                    meta_info["help"] = command
                    found_help = True
                else:
                    if ';;' in single_line and command_type == "Single":
                        command_type = "Multi"
                        meta_info["command"] = {}
                    if command_type == "Multi":
                        command_name = single_line.split(")",1)[0].strip()
                        meta_info["command"][command_name] = command
                    else:
                        meta_info["command"] = command
                    meta_info["commandType"] = command_type
    meta_info['labels'] = labels
    shutil.rmtree(temp_dir)
    return meta_info

def verbose_logging(single_item):
    if single_item["stdout"]:
        stdout_logging = '---------- STDOUT of '+ single_item["image_id"] + ' ----------\n' + single_item["stdout"]
        logger.info(stdout_logging)
    if single_item["stderr"]:
        stderr_logging = '---------- STDERR of '+ single_item["image_id"] + ' ----------\n' + single_item["stderr"]
        logger.info(stderr_logging)

def build_parallel(threads,tool_json,build_docker,build_singularity,docker_registry,docker_push,debug_mode):
    status_queue = Queue()
    job_list = construct_jobs(tool_json,status_queue,build_docker,build_singularity,docker_registry,docker_push)
    original_sigint_handler = signal.signal(signal.SIGINT, signal.SIG_IGN)
    pool = Pool(threads)
    signal.signal(signal.SIGINT, original_sigint_handler)
    try:
        build_results = pool.map_async(build_image_wrapper,job_list)
        total_number_of_jobs = len(job_list)
        total_processed = 0
        image_meta_info = {}
        while build_results.ready() == False and total_processed!=total_number_of_jobs:
            single_item = status_queue.get()
            thread_name = single_item['name']
            image_id = single_item["image_id"]
            image_id_split = image_id.split(":")
            image_name = image_id_split[0]
            image_version = image_id_split[1]
            image_meta = single_item["meta"]
            if single_item['status'] == 0:
                total_processed = total_processed + 1
                if image_name not in image_meta_info:
                    image_meta_info[image_name] = []
                image_obj = {'version':image_version,'meta': image_meta}
                image_meta_info[image_name].append(image_obj)
                logger.info("["+thread_name+"] " + image_id + " finished building ( " + str(total_processed) + "/"+str(total_number_of_jobs)+" )")
                if debug_mode == True:
                    verbose_logging(single_item)
            else:
                status_message = "["+thread_name+"] " + image_id + " failed to build"
                verbose_logging(single_item)
                logger.error(status_message)
                pool.terminate()
                sys.exit(status_message)
    except KeyboardInterrupt:
        exit_message = "Keyboard interrupt, terminating workers"
        logger.info(exit_message)
        pool.terminate()
        sys.exit(exit_message)
    logger.info("---------- Finished building images ----------")
    pool.close()
    pool.join()
    image_meta_path = os.path.abspath(os.path.join(script_path,os.pardir,"containers","images_meta.json"))
    with open(image_meta_path,"w") as image_meta_file:
        json.dump(image_meta_info,image_meta_file, indent=4,separators=(',', ': '), sort_keys=True)



def move_images():
    move_script_path = os.path.join(script_path,'move-artifacts-to-setup.sh')
    command=[move_script_path]
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
        '--t',
        action="store",
        dest="threads",
        type=int,
        help='Number of threads'
    )
    parser.add_argument(
        '--build_docker',
        action='store_true',
        dest='build_docker',
        help='Build docker images'
    )
    parser.add_argument(
        '--build_singularity',
        action='store_true',
        dest='build_singularity',
        help='Build singularity images'
    )
    parser.add_argument(
        '--docker_registry',
        action='store',
        dest='docker_registry',
        help='Docker registry name\nExample: "mskcc" for dockerhub or "localhost:5000" for local registry'
    )
    parser.add_argument(
        '--docker_push',
        action='store_true',
        dest='push_docker',
        help="Push to docker registry"
    )
    parser.add_argument(
        '--d',
        action='store_true',
        dest='debug_mode',
        help="Verbose logging"
    )
    params = parser.parse_args()
    if params.push_docker and not params.docker_registry:
        print "Error, please specify docker_registry when docker_push is enabled"
        exit(1)
    if params.push_docker and "localhost" not in params.docker_registry:
        docker_login()
    tool_path = os.path.abspath(os.path.join(script_path,os.pardir,"tools.json"))
    with open(tool_path, "r") as file_in:
        tools = json.load(file_in)

    build_parallel(params.threads,tools,params.build_docker,params.build_singularity,params.docker_registry,params.push_docker,params.debug_mode)
    move_images()


if __name__ == "__main__":
    main()
