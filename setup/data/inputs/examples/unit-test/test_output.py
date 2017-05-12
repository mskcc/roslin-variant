#!/usr/bin/python

import json
import re
from nose.tools import assert_equals
from nose.tools import assert_true
from nose.tools import nottest


def read_result(filename):
    "this returns JSON"

    with open(filename, 'r') as file_in:
        contents = file_in.read()
        match = re.search(
            "---> PRISM JOB UUID = .*?\n(.*?)<--- PRISM JOB UUID", contents, re.DOTALL)
        # print match
        if match:
            result = json.loads(match.group(1))
            return result
        else:
            return None


def test_samtools_checksum():
    "samtools.sam2bam should return generate the correct output"

    result = read_result('./outputs/samtools-sam2bam.txt')

    assert_equals(result['bam']['basename'], 'sample.bam')
    assert_equals(result['bam']['checksum'],
                  'sha1$ff575d96fdad1e1769425687997d155e1775a9d9')
    assert_equals(result['bam']['class'], 'File')


def test_gatk_FindCoveredIntervals():
    "gatk.findCoveredIntervals should generate the correct output"

    result = read_result('./outputs/cmo-gatk.FindCoveredIntervals.txt')

    assert_equals(result['fci_list']['basename'], 'intervals.list')
    assert_equals(result['fci_list']['checksum'],
                  'sha1$bf0fad5c4a0bb7f387eca7f4fea57deb34812a18')
    assert_equals(result['fci_list']['class'], 'File')


def test_abra():
    "abra should generate the correct output"

    result = read_result('./outputs/cmo-abra.txt')

    assert_equals(len(result['out']), 2)
    assert_equals(result['out'][0]['checksum'],
                  'sha1$d35d2a2c4251f48cde89cc9c21328ac0360cc142')
    assert_equals(result['out'][0]['basename'], 'sample1.abra.bam')
    assert_equals(result['out'][0]['class'], 'File')
    assert_equals(result['out'][1]['checksum'],
                  'sha1$d35d2a2c4251f48cde89cc9c21328ac0360cc142')
    assert_equals(result['out'][1]['basename'], 'sample2.abra.bam')
    assert_equals(result['out'][1]['class'], 'File')


def test_bwa_mem():
    "bwa mem should generate the correct output"

    result = read_result('./outputs/cmo-bwa-mem.txt')

    assert_equals(result['bam']['checksum'],
                  'sha1$e775a05c99c5a0fe8b5d864ea3ad1cfc0c7e4fd1')
    assert_equals(result['bam']['basename'], 'P1.bam')
    assert_equals(result['bam']['class'], 'File')


def test_gatk_SomaticIndelDetector():
    "gatk.somaticIndelDetector should generate the correct output"

    result = read_result('./outputs/cmo-gatk.SomaticIndelDetector.txt')

    assert_true('output' in result)
    assert_equals(result['output']['basename'], 'P1_ADDRG_MD.abra.fmi.printreads.sid.vcf')
    assert_equals(result['output']['class'], 'File')


def test_list2bed():
    "list2bed should generate the correct output"

    result = read_result('./outputs/cmo-list2bed.txt')

    assert_true('output_file' in result)
    assert_equals(result['output_file']['basename'], 'intervals.bed')
    assert_equals(result['output_file']['class'], 'File')


def test_mutect():
    "mutect should generate the correct output"

    result = read_result('./outputs/cmo-mutect.txt')

    assert_true('output' in result)
    assert_equals(result['output']['basename'],
                  'P1_ADDRG_MD.abra.fmi.printreads.mutect.vcf')
    assert_equals(result['output']['class'], 'File')


def test_picard_AddOrReplaceReadGroups():
    "picard.addOrReplaceReadGroups should generate the correct output"

    result = read_result('./outputs/cmo-picard.AddOrReplaceReadGroups.txt')

    assert_true('bam' in result)
    assert_equals(result['bam']['basename'], 'P-0000377-T02-IM3_ARRDRG.bam')
    assert_equals(result['bam']['class'], 'File')

    assert_true('bai' in result)
    assert_equals(result['bai']['basename'], 'P-0000377-T02-IM3_ARRDRG.bai')
    assert_equals(result['bai']['class'], 'File')


def test_picard_MarkDuplicates():
    "picard.markDuplicates should generate the correct output"

    result = read_result('./outputs/cmo-picard.MarkDuplicates.txt')

    assert_true('bam' in result)
    assert_equals(result['bam']['basename'],
                  'P-0000377-T02-IM3_ARRDRG_MD.bam')
    assert_equals(result['bam']['class'], 'File')

    assert_true('mdmetrics' in result)
    assert_equals(result['mdmetrics']['basename'],
                  'P-0000377-T02-IM3_ARRDRG_MD.metrics')
    assert_equals(result['mdmetrics']['class'], 'File')

    assert_true('bai' in result)


def test_pindel():
    "pindel should generate the correct output"

    result = read_result('./outputs/cmo-pindel.txt')

    assert_true('output' in result)
    assert_equals(result['output']['basename'], 'Tumor.pindel.vcf')
    assert_equals(result['output']['class'], 'File')


def test_trimgalore():
    "trimgalore should generate the correct output"

    result = read_result('./outputs/cmo-trimgalore.txt')

    assert_true('clfastq1' in result)
    assert_equals(result['clfastq1']['basename'], 'P1_R1_cl.fastq.gz')
    assert_equals(result['clfastq1']['class'], 'File')

    assert_true('clfastq2' in result)
    assert_equals(result['clfastq2']['basename'], 'P1_R2_cl.fastq.gz')
    assert_equals(result['clfastq2']['class'], 'File')

    assert_true('clstats1' in result)
    assert_equals(result['clstats1']['basename'], 'P1_R1_cl.stats')
    assert_equals(result['clstats1']['class'], 'File')

    assert_true('clstats2' in result)
    assert_equals(result['clstats2']['basename'], 'P1_R2_cl.stats')
    assert_equals(result['clstats2']['class'], 'File')


def test_bsub_of_prism_runner():
    "bsubsing prism runner should still generate the correct output"

    result = read_result('./outputs/bsub-of-prism-runner.txt')

    assert_true('bam' in result)
    assert_equals(result['bam']['basename'], 'sample.bam')
    assert_equals(result['bam']['class'], 'File')


def test_basic_filtering_mutect():
    "basic-filtering.mutect should generate the correct output"

    result = read_result('./outputs/basic-filtering.mutect.txt')

    assert_equals(result['vcf']['checksum'],
                  'sha1$1ca8e5fa22988db78f2fdd2cffca154932da6e86')
    assert_equals(result['vcf']['basename'],
                  'PoolTumor2-T_bc52_muTect_1.1.4_STDfilter.vcf')
    assert_equals(result['vcf']['class'], 'File')

    assert_equals(result['txt']['checksum'],
                  'sha1$8bc71f6ccd9f5c313b2fbecfe38e1fd4bdc569d0')
    assert_equals(result['txt']['basename'],
                  'PoolTumor2-T_bc52_muTect_1.1.4_STDfilter.txt')
    assert_equals(result['txt']['class'], 'File')


def test_basic_filtering_pindel():
    "basic-filtering.pindel should generate the correct output"

    result = read_result('./outputs/basic-filtering.pindel.txt')

    assert_equals(result['vcf']['checksum'],
                  'sha1$fcbe028337d133c104ebe8787cc77f8b13132a79')
    assert_equals(result['vcf']['basename'],
                  'PoolTumor2-T_bc52_PINDEL_0.2.5a7_STDfilter.vcf')
    assert_equals(result['vcf']['class'], 'File')

    assert_equals(result['txt']['checksum'],
                  'sha1$2cd5b6a127e498d97a545507d705994849be56fb')
    assert_equals(result['txt']['basename'],
                  'PoolTumor2-T_bc52_PINDEL_0.2.5a7_STDfilter.txt')
    assert_equals(result['txt']['class'], 'File')


def test_basic_filtering_sid():
    "basic-filtering.somaticIndelDetector should generate the correct output"

    result = read_result('./outputs/basic-filtering.somaticIndelDetector.txt')

    assert_equals(result['vcf']['checksum'],
                  'sha1$7c2e797e60a173502c1957432ea4c333b34702cf')
    assert_equals(result['vcf'][
                  'basename'], 'PoolTumor2-T_bc52_SomaticIndelDetector_2.3-9_STDfilter.vcf')
    assert_equals(result['vcf']['class'], 'File')

    assert_equals(result['txt']['checksum'],
                  'sha1$aef5bc3352f0faac35ee92985424f70e10980e08')
    assert_equals(result['txt'][
                  'basename'], 'PoolTumor2-T_bc52_SomaticIndelDetector_2.3-9_STDfilter.txt')
    assert_equals(result['txt']['class'], 'File')


@nottest
def test_basic_filtering_vardict():
    "basic-filtering.vardict should generate the correct output"

    result = read_result('./outputs/basic-filtering.vardict.txt')

    assert_equals(result['vcf']['checksum'],
                  'sha1$5236ed4eb3c1e5b04b8d2599df6d2dab0675d466')
    assert_equals(result['vcf'][
                  'basename'], 'PoolTumor2-T_bc52_Vardict_2.3-9_STDfilter.vcf')
    assert_equals(result['vcf']['class'], 'File')

    assert_equals(result['txt']['checksum'],
                  'sha1$5c10fbc3c2054b1ca4a1ebf289ea79a3c5f124f6')
    assert_equals(result['txt'][
                  'basename'], 'PoolTumor2-T_bc52_VarDict_1.4.6_STDfilter.txt')
    assert_equals(result['txt']['class'], 'File')


def test_bcftools_norm_mutect():
    "bcftools.norm.mutect should generate the correct output"

    result = read_result('./outputs/cmo-bcftools.norm.mutect.txt')

    assert_equals(result['vcf']['basename'], 'mutect-norm.vcf')
    assert_equals(result['vcf']['class'], 'File')


def test_bcftools_norm_pindel():
    "bcftools.norm.pindel should generate the correct output"

    result = read_result('./outputs/cmo-bcftools.norm.pindel.txt')

    assert_equals(result['vcf']['basename'], 'pindel-norm.vcf')
    assert_equals(result['vcf']['class'], 'File')


def test_bcftools_norm_vardict():
    "bcftools.norm.vardict should generate the correct output"

    result = read_result('./outputs/cmo-bcftools.norm.vardict.txt')

    assert_equals(result['vcf']['basename'], 'vardict-norm.vcf')
    assert_equals(result['vcf']['class'], 'File')


def test_bcftools_norm_sid():
    "bcftools.norm.somaticIndelDetector should generate the correct output"

    result = read_result('./outputs/cmo-bcftools.norm.somaticIndelDetector.txt')

    assert_equals(result['vcf']['basename'], 'sid-norm.vcf')
    assert_equals(result['vcf']['class'], 'File')


def test_gatk_CombineVariants():
    "gatk.combineVariants should generate the correct output"

    result = read_result('./outputs/cmo-gatk.CombineVariants.txt')

    assert_equals(result['out_vcf']['basename'], 'PoolTumor2-T_bc52_combined_variants.vcf')
    assert_equals(result['out_vcf']['class'], 'File')


def test_env():
    "env should generate env.txt"

    result = read_result('./outputs/env.txt')

    assert_equals(result['output']['basename'], 'env.txt')
    assert_equals(result['output']['class'], 'File')


def test_module_1():
    "module 1"

    result = read_result('./outputs/module-1.txt')

    # absolute minimum
    assert_true('clstats1' in result)
    assert_true('clstats2' in result)
    assert_true('bam' in result)
    assert_true('bai' in result)
    assert_true('md_metrics' in result)


def test_module_2():
    "module 2"

    result = read_result('./outputs/module-2.txt')

    # absolute minimum
    assert_true('covint_list' in result)
    assert_equals(result['covint_list']['basename'], 'intervals.list')

    assert_equals(len(result['bams']), 2)
    assert_equals(result['bams'][0]['basename'],
                  'P2_ADDRG_MD.abra.fmi.printreads.bam')
    assert_equals(result['bams'][1]['basename'],
                  'P1_ADDRG_MD.abra.fmi.printreads.bam')
    assert_equals(result['bams'][0]['class'], 'File')
    assert_equals(result['bams'][1]['class'], 'File')


def test_module_3():
    "module 3"

    result = read_result('./outputs/module-3.txt')

    # absolute minimum
    assert_true('mutect_vcf' in result)
    assert_true('somaticindeldetector_vcf' in result)
    assert_true('somaticindeldetector_verbose_vcf' in result)
    assert_true('vardict_vcf' in result)
