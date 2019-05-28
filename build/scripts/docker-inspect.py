import argparse
import requests
import json
from distutils.spawn import find_executable
from subprocess import Popen, PIPE
import os

            if [ -x "$(command -v docker)" ]
            then
                docker pull $docker_image_registry
            fi

def run_command(command,name):
    process = Popen(command, stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()
    exit_code = process.returncode
    if exit_code != 0:
        print str(name) + " failed"
        if stdout:
            print "----stdout----\n" + stdout
        if stderr:
            print "----stderr----\n" + stderr
        exit(1)
    return stdout

def get_docker_labels(docker_image,output):
    docker_labels = None
    docker_id = None
    docker_meta = None
    docker_image_split = docker_image.split(":")
    docker_image_name = docker_image_split[0]
    docker_image_tag = docker_image_split[1]
    if find_executable('docker') is not None:
        docker_repository_url= "https://hub.docker.com/v2/repositories/" + str(docker_image_name) + "/tags/" + str(docker_image_tag)
        docker_pulled_image = False
        if requests.get(docker_repository_url).ok:
            pull_command = ["docker","pull",docker_image]
            run_command(pull_command,"docker pull")
            docker_pulled_image = True
        inspect_command = ["docker","inspect",docker_image]
        inspect_stdout = run_command(inspect_command,"docker inspect")
        if docker_pulled_image:
            remove_command = ["docker","image","rm",docker_image]
            run_command(remove_command,'docker image rm')
        docker_meta = json.loads(inspect_stdout)[0]
        docker_labels = docker_meta['Config']['Labels']
        docker_id = docker_meta['Id']
    else:
        docker_auth_url = "https://auth.docker.io/token?scope=repository:"+str(docker_image_name)+":pull&service=registry.docker.io"
        docker_label_url = "https://registry-1.docker.io/v2/" +str(docker_image_name)+"/manifests/" + str(docker_image_tag)
        token_request = requests.get(docker_auth_url)
        if token_request.ok:
            token_data = token_request.json()['token']
            token_str = "Bearer " + token_data
            label_request = requests.get(docker_label_url, headers={'Authorization':token_str})
            if label_request.ok:
                docker_meta = json.loads(label_request.json()['history'][0]['v1Compatibility'])
                docker_labels = docker_meta['config']['Labels']
                docker_id = docker_meta['id']
            else:
                print "Docker label request failed. Reason:\n" + label_request.text
                exit(1)
        else:
            print "Docker token request failed. Reason:\n" + token_request.text
            exit(1)
    docker_labels['Docker_Image'] = docker_image

    meta_path = os.path.join(output,'dockerMeta.json')
    labels_path = os.path.join(output,'labels.json')
    id_path = os.path.join(output,'dockerId.json')
    with open(meta_path,'w') as meta_file:
        json.dump(docker_meta,meta_file)
    with open(labels_path,'w') as labels_file:
        json.dump(docker_labels,labels_file)
    with open(id_path,'w') as id_file:
        json.dump(docker_id,id_file)

def main():
    parser = argparse.ArgumentParser(description='inspect-docker-images')
    parser.add_argument(
        '--docker_image',
        action='store',
        dest='docker_image',
        help='Docker image. Example: "mskcc/roslin-variant-picard:2.9"'
    )
    parser.add_argument(
        '--output',
        action='store',
        dest='output',
        help='Output directory for docker labels'
    )
    args = parser.parse_args()
    get_docker_labels(args.docker_image,args.output)


if __name__ == "__main__":
    main()