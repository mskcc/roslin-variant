#!/usr/bin/env python

import yaml
from nose.tools import assert_equals
from nose.tools import assert_true
from nose.tools import nottest


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
        "The number of groups should be 64"

        for inputs_yaml in self.inputs_yaml_list:
            assert_true(len(inputs_yaml["groups"]) == 64)

    def test_pair_count(self):
        "The number of pairs should be 64"

        for inputs_yaml in self.inputs_yaml_list:
            assert_true(len(inputs_yaml["pairs"]) == 64)

    def test_sample_count(self):
        "The number of samples should be 128"

        for inputs_yaml in self.inputs_yaml_list:
            assert_true(len(inputs_yaml["samples"]) == 128)


if __name__ == "__main__":

    my_test = TestUM()

    print my_test.inputs_yaml_list[0]["groups"]
