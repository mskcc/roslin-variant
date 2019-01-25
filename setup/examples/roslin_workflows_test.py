from __future__ import print_function
import pytest
import os
import sys
import json
from shutil import copyfile

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)
from core_utils  import run_command_realtime, print_error
test_dir = os.path.join(os.environ['parentDir'],os.environ['TestDir'])

def move_logs(folder_name,log_folder):
    for root, dirs, files in os.walk(log_folder):
        file_prefix = ''
        if root != log_folder:
            file_prefix = os.path.basename(root)
        for single_file in files:
            if single_file.endswith(".log"):
                file_basename = os.path.basename(single_file)
                file_basename_no_ext = os.path.splitext(file_basename)[0]
                new_file_name = str(folder_name) + "_" + str(file_prefix) + file_basename_no_ext + ".txt"
                new_file_path = os.path.join(test_dir,new_file_name)
                copyfile(single_file,new_file_path)

def run_test(folder_name):
    submission_data = {}
    user_examples_path = os.path.dirname(os.path.realpath(__file__))
    test_path = os.path.join(user_examples_path,folder_name)
    os.chdir(test_path)
    run_example_command = ['./run-example.sh']
    output = run_command_realtime(run_example_command,False)
    with open("submission.json","r") as submission_file:
        submission_data = json.load(submission_file)
    log_folder = submission_data['log_dir']
    move_logs(folder_name,log_folder)
    assert output
    assert output['errorcode'] == 0

def test_alignment():
    run_test("Alignment")

def test_alignment_post():
    run_test('Alignment-post')

def test_gather_metrics():
    run_test('Gather-metrics')

def test_conpair():
    run_test('Conpair')

def test_variant_calling():
    run_test('Variant-calling')

def test_variant_calling_post():
    run_test('Variant-calling-post')

def test_structural_varaints():
    run_test('Structural-variants')

def test_filtering():
    run_test('Filtering')

def test_variant_workflow():
    run_test('Variant-workflow')

def test_variant_workflow_SV():
    run_test('Variant-workflow-SV')

def test_legacy_variant_workflow():
    run_test('Legacy-variant-workflow')

def test_legacy_variant_workflow_SV():
    run_test('Legacy-variant-workflow-SV')
