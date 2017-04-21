#!/usr/bin/python

import json
import re
from nose.tools import assert_equals


def read_result(filename):
    """
    this returns JSON
    """

    with open(filename, 'r') as file_in:
        contents = file_in.read()
        match = re.search(
            "---> PRISM JOB UUID = [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}(.*?)<--- PRISM JOB UUID", contents, re.DOTALL)
        # print match
        if match:
            result = json.loads(match.group(1))
            return result
        else:
            return None


def test_samtools_checksum():
    """
    samtools.sam2bam should return generate the correct output
    """

    result = read_result('results.samtools-sam2bam.txt')
    assert_equals(result['bam']['basename'], 'sample.bam')
    assert_equals(result['bam']['checksum'],
                  'sha1$ff575d96fdad1e1769425687997d155e1775a9d9')
    assert_equals(result['bam']['class'], 'File')


def test_gatk_FindCoveredIntervals():
    """
    gatk.FindCoveredIntervals should generate the correct output
    """

    result = read_result('results.cmo-gatk.FindCoveredIntervals.txt')
    assert_equals(result['fci_list']['basename'], 'intervals.list')
    assert_equals(result['fci_list']['checksum'],
                  'sha1$bf0fad5c4a0bb7f387eca7f4fea57deb34812a18')
    assert_equals(result['fci_list']['class'], 'File')


def test_abra():
    """
    abra should generate the correct output
    """

    result = read_result('results.cmo-abra.txt')
    assert len(result['out']) == 2
    assert_equals(result['out'][0]['checksum'],
                  'sha1$d35d2a2c4251f48cde89cc9c21328ac0360cc142')
    assert_equals(result['out'][0]['basename'], 'sample1.abra.bam')
    assert_equals(result['out'][0]['class'], 'File')
    assert_equals(result['out'][1]['checksum'],
                  'sha1$d35d2a2c4251f48cde89cc9c21328ac0360cc142')
    assert_equals(result['out'][1]['basename'], 'sample2.abra.bam')
    assert_equals(result['out'][1]['class'], 'File')


def test_bwa_mem():
    """
    bwa mem should generate the correct output
    """

    result = read_result('results.cmo-bwa-mem.txt')
    assert_equals(result['bam']['checksum'],
                  'sha1$e775a05c99c5a0fe8b5d864ea3ad1cfc0c7e4fd1')
    assert_equals(result['bam']['basename'], 'P1.bam')
    assert_equals(result['bam']['class'], 'File')


def test_gatk_SomaticIndelDetector():
    pass


def test_list2bed():
    pass


def test_mutect():
    pass


def test_picard_AddOrReplaceReadGroups():
    pass


def test_picard_MarkDuplicates():
    pass


def test_pindel():
    pass


def test_trimgalore():
    pass


def test_env():
    pass


def test_module_1():
    pass


def test_module_2():
    pass
