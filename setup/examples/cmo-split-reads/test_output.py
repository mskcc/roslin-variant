#!/usr/bin/python

import json
import re
import os
from nose.tools import assert_equals
from nose.tools import assert_true, assert_false
from nose.tools import nottest


def read_result(filename):
    "this returns JSON"

    with open(filename, 'r') as file_in:
        contents = file_in.read()
        return json.loads(contents)


def test_chunks1():
    "chunks1 should have only R1"

    result = read_result('./outputs/output-meta.json')

    # absolute minimum test
    for chunk in result['chunks1']:
        assert_true("_R1_" in chunk['basename'])
        assert_false("_R2_" in chunk['basename'])
        assert_true(chunk['size'] > 0)
        assert_equals(chunk['class'], 'File')


def test_chunks2():
    "chunks2 should have only R2"

    result = read_result('./outputs/output-meta.json')

    # absolute minimum test
    for chunk in result['chunks2']:
        assert_true("_R2_" in chunk['basename'])
        assert_false("_R1_" in chunk['basename'])
        assert_true(chunk['size'] > 0)
        assert_equals(chunk['class'], 'File')
