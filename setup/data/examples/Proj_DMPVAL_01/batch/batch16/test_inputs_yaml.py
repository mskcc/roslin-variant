#!/usr/bin/env python

import yaml
from nose.tools import assert_equals
from nose.tools import assert_true
from nose.tools import nottest

NUM_OF_GROUPS_EXPECTED=16
NUM_OF_PAIRS_EXPECTED=16
NUM_OF_SAMPLES_EXPECTED=32

class TestUM(object):
    "system under test"

    def __init__(self):
        "initialize"

        self.inputs_yaml_list = list()
        for batch_id in range(1, 5):
            with open("./batch-{}/inputs.yaml".format(batch_id), "rt") as myfile:
                self.inputs_yaml_list.append(yaml.load(myfile.read()))

    def setup(self):
        "setup before each test method"
        pass

    def teardown(self):
        "teardown after each test method"
        pass

    @classmethod
    def setup_class(cls):
        "setup before any methods in this class"
        pass

    @classmethod
    def teardown_class(cls):
        "teardown after any methods in this class"
        pass

    def test_group_count(self):
        "The number of groups should be " + str(NUM_OF_GROUPS_EXPECTED)

        for inputs_yaml in self.inputs_yaml_list:
            assert_true(len(inputs_yaml["groups"]) == NUM_OF_GROUPS_EXPECTED)

    def test_pair_count(self):
        "The number of pairs should be " + str(NUM_OF_PAIRS_EXPECTED)

        for inputs_yaml in self.inputs_yaml_list:
            assert_true(len(inputs_yaml["pairs"]) == NUM_OF_PAIRS_EXPECTED)

    def test_sample_count(self):
        "The number of samples should be " + str(NUM_OF_SAMPLES_EXPECTED)

        for inputs_yaml in self.inputs_yaml_list:
            assert_true(len(inputs_yaml["samples"]) == NUM_OF_SAMPLES_EXPECTED)


if __name__ == "__main__":

    my_test = TestUM()

    print my_test.inputs_yaml_list[0]["groups"]
