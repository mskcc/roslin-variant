#!/usr/bin/env python

import sys
import os
import re
import argparse
import yaml
import copy
import csv
import glob
import uuid
from collections import defaultdict

mapping_headers = ["library_suffix", "sample_id", "run_id", "fastq_directory", "runtype"]
pairing_headers = ['normal_id', 'tumor_id']
grouping_headers = ['sample_id', 'group_id']
new_yaml_object = []


def parse_mapping_file(mfile):
    mapping_dict = dict()
    fh = open(mfile, "r")
    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=mapping_headers)
    for row in csvreader:
        new_row = copy.deepcopy(row)
        new_row['rg_id'] = row['sample_id'] + new_row['library_suffix'] + new_row['run_id']
        fastqs = sort_fastqs_into_dict(glob.glob(os.path.join(new_row['fastq_directory'], "*R[12]*.fastq.gz")))
        new_row['fastqs'] = fastqs
        mapping_dict[row['sample_id']] = new_row
    return mapping_dict


def parse_pairing_file(pfile):
    pairing = list()
    fh = open(pfile, "r")
    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=pairing_headers)
    for row in csvreader:
        pairing.append([row['tumor_id'], row['normal_id']])
    return pairing


def parse_grouping_file(gfile):
    grouping_dict = dict()
    fh = open(gfile, "r")
    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=grouping_headers)
    for row in csvreader:
        if row['group_id'] not in grouping_dict:
            grouping_dict[row['group_id']] = list()
        grouping_dict[row['group_id']].append(row['sample_id'])
    return grouping_dict


def sort_fastqs_into_dict(files):
    sorted = dict()
    readgroup_tags = dict()
    paired_by_sample = {"R1": list(), "R2": list()}
    for file in files:
        base = os.path.basename(file)
        m = re.search("(?P<sample>[^_]+)_?(?P<barcode>\S+)?_?(?P<flowcell>\S+)?_(?P<lane>\S+)_(?P<read>R[12])_(?P<set>\d\d\d).fastq.gz", base)
        if not m:
            m = re.search("(?P<sample>[^_]+)_(?P<barcode>\S+)_(?P<flowcell>\S+)_(?P<lane>\S+)_(?P<set>\d\d\d).(?P<read>R[12]).fastq.gz", base)
        if not m or not (m.group('sample') and m.group('read') and m.group('set')):
            # FIXME LOGGING instead of CRITICAL fail?
            print >>sys.stderr, "Can't find filename parts (Sample/Barcode, R1/2, group) for this fastq: %s" % file
            sys.exit(1)
        # fastq file large sample and barcode prefix
        readset = "_".join([m.group('sample') + m.group('lane') + m.group('set')])
        if (m.group('flowcell') != None):
            readset = "_".join([m.group('sample') + m.group('lane') + m.group('flowcell') + m.group('set')])
        if m.group('sample') not in sorted:
            sorted[m.group('sample')] = dict()
        if readset not in sorted[m.group('sample')]:
            sorted[m.group('sample')][readset] = dict()
        sorted[m.group('sample')][readset][m.group('read')] = file
    for sample in sorted:
        for readset in sorted[sample]:
            for read in ["R1", "R2"]:
                try:
                    paired_by_sample[read].append({"class": "File", "path": sorted[sample][readset][read]})
                except:
                    print >>sys.stderr, "cant find %s for %s" % (read, readset)
                    print >>sys.stderr, "aligning as single end"
                    paired_by_sample[read].append(None)
    return paired_by_sample

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="convert current project files to yaml input")
    parser.add_argument("-m", "--mapping", help="the mapping file", required=True)
    parser.add_argument("-p", "--pairing", help="the pairing file", required=True)
    parser.add_argument("-g", "--grouping", help="the grouping file", required=True)
    parser.add_argument("-o", "--output-directory", help="output_directory for pipeline (NOT CONFIG FILE)", required=True)
    parser.add_argument("-f", "--yaml-output-file", help="file to write yaml to", required=True)
    args = parser.parse_args()
    mapping_dict = parse_mapping_file(args.mapping)
    pairing_dict = parse_pairing_file(args.pairing)
    grouping_dict = parse_grouping_file(args.grouping)
    output_yaml = dict()
    output_yaml['samples'] = mapping_dict
    output_yaml['pairs'] = pairing_dict
    output_yaml['groups'] = grouping_dict
    # print yaml.dump(output_yaml, default_flow_style=False)
    out_dir = list()
    adapter_one_string = "AGATCGGAAGAGCACACGTCTGAACTCCAGTCACATGAGCATCTCGTATGCCGTCTTCTGCTTG"
    adapter_two_string = "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT"
    adapter = list()
    adapter2 = list()
    fastq1 = list()
    fastq2 = list()
    LB = list()
    PL = list()
    PU = list()
    SM = list()
    CN = list()
    ID = list()
    bwa_out_bam = list()
    rg_out_bam = list()
    md_out_bam = list()
    md_metrics = list()
    tmp_dir = list()
    tmp_dir_constant = "/ifs/work/scratch"
    covariates = ['CycleCovariate', 'ContextCovariate', 'ReadGroupCovariate', 'QualityScoreCovariate']
    sid_rf = ["BadCigar", "DuplicateRead", "FailsVendorQualityCheck", "NotPrimaryAlignment", "BadMate", "MappingQualityUnavailable", "UnmappedRead", "MappingQuality"]
    rf = ["BadCigar"]
    genome = "GRCh37"
    files = {
        'hapmap': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/hapmap_3.3.b37.vcf'},
        'dbsnp': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/dbsnp_138.b37.excluding_sites_after_129.vcf'},
        'indels_1000g': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/Mills_and_1000G_gold_standard.indels.b37.vcf'},
        'snps_1000g': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/1000G_phase1.snps.high_confidence.b37.vcf'},
        'cosmic': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/CosmicCodingMuts_v67_b37_20131024__NDS.vcf'},
        'refseq': {'class': 'File', 'path': "/ifs/work/prism/chunj/test-data/ref/refGene_b37.sorted.txt"}
    }

    ofh = open(args.yaml_output_file, "wb")
    sample_list = list()
    for sample_id, sample in mapping_dict.items():
        new_sample_object = dict()
        new_sample_object['adapter'] = adapter_one_string
        new_sample_object['adapter2'] = adapter_two_string
        new_sample_object['R1'] = sample['fastqs']['R1']
        new_sample_object['R2'] = sample['fastqs']['R2']
        new_sample_object['LB'] = sample['rg_id'] + sample['library_suffix']
        new_sample_object['RG_ID'] = sample['rg_id'] + sample['runtype']
        new_sample_object['PU'] = sample['rg_id']
        new_sample_object['ID'] = sample_id
        new_sample_object['PL'] = "Illumina"
        new_sample_object['CN'] = "MSKCC"
        new_sample_object['bwa_output'] = sample['sample_id'] + ".bam"
        sample_list.append(new_sample_object)
    out_dict = {"samples": sample_list,
                "pairs": pairing_dict,
                "groups": grouping_dict.values(),
                "db_files": files,
                }
    params = {

        "abra_scratch": "/scratch/",
        "genome": genome,
        "sid_rf": sid_rf,
        "mutect_dcov": 50000,
        "mutect_rf": rf,
        "num_cpu_threads_per_data_thread": 6,
        "covariates": covariates,
        "emit_original_quals": True,
        "num_threads": 10,
        "intervals": '1',
        "tmp_dir": "/scratch"
    }
    out_dict.update({"runparams": params})
    ofh.write(yaml.dump(out_dict))
    ofh.close()
