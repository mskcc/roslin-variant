from __future__ import print_function
import pytest
import os
import sys

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)
from core_utils  import run_command_realtime, print_error

def run_test(folder_name):
    print(folder_name)
    user_examples_path = os.path.dirname(os.path.realpath(__file__))
    test_path = os.path.join(user_examples_path,folder_name)
    os.chdir(test_path)
    run_example_command = ['./run-example.sh']
    output = run_command_realtime(run_example_command,False)
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
