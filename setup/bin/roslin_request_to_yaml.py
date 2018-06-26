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
import json
import subprocess
from collections import defaultdict

mapping_headers = ["library_suffix", "sample_id", "run_id", "fastq_directory", "runtype"]
pairing_headers = ['normal_id', 'tumor_id']
grouping_headers = ['sample_id', 'group_id']
new_yaml_object = []

def read_pipeline_settings(pipeline_name_version):
    "read the Roslin Pipeline settings"
    settings_path = os.path.join(os.environ.get("ROSLIN_CORE_CONFIG_PATH"), pipeline_name_version, "settings.sh")
    command = ['bash', '-c', 'source {} && env'.format(settings_path)]
    proc = subprocess.Popen(command, stdout=subprocess.PIPE)
    source_env = {}
    for line in proc.stdout:
        (key, _, value) = line.partition("=")
        source_env[key] = value.rstrip()
    proc.communicate()
    return source_env

def parse_mapping_file(mfile):
    mapping_dict = dict()
    fh = open(mfile, "r")
    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=mapping_headers)
    for row in csvreader:
        #take all hyphens out, these will be word separators in fastq chunks
        row['sample_id'] = row['sample_id'].replace("-", "_")
        new_row = copy.deepcopy(row)
        rg_id = row['sample_id'].replace("-","_") + new_row['library_suffix'].replace("-","_") + "-" + new_row['run_id'].replace("-","_")
        new_row['run_id'] = new_row['run_id'].replace("-","_")
        #hyphens suck
        fastqs = sort_fastqs_into_dict(glob.glob(os.path.join(new_row['fastq_directory'], "*R[12]*.fastq.gz")))
        new_row['rg_id'] = []
        for fastq in fastqs['R1']:
            new_row['rg_id'].append(rg_id)
        if row['sample_id'] in mapping_dict:
            #this means multiple runs were used on the sample, two or more lines appear in mapping.txt for that sample
            #FIXME do this merge better
            mapping_dict[row['sample_id']]['fastqs']['R1']= mapping_dict[row['sample_id']]['fastqs']['R1'] + fastqs['R1']
            mapping_dict[row['sample_id']]['fastqs']['R2']= mapping_dict[row['sample_id']]['fastqs']['R2'] + fastqs['R2']
            #append this so when we have a big list of bullshit, we can hoepfully sort out
            #the types of bullshit that are suited for each other
            for fastq in fastqs['R1']:
                mapping_dict[row['sample_id']]['rg_id'].append(row['sample_id'] + new_row['library_suffix'] + "-" + new_row['run_id'])
        else:
            new_row['fastqs'] = fastqs
            mapping_dict[row['sample_id']] = new_row

    return mapping_dict


def parse_pairing_file(pfile):
    pairing = list()
    fh = open(pfile, "r")
    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=pairing_headers)
    for row in csvreader:
        pairing.append([row['tumor_id'].replace("-","_"), row['normal_id'].replace("-","_")])
    return pairing


def parse_grouping_file(gfile):
    grouping_dict = dict()
    fh = open(gfile, "r")
    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=grouping_headers)
    for row in csvreader:
        if row['group_id'] not in grouping_dict:
            grouping_dict[row['group_id']] = list()
        grouping_dict[row['group_id']].append(row['sample_id'].replace("-","_"))
    return grouping_dict


def parse_request_file(rfile):
    stream = open(rfile, "r")
    # this format looks like yaml, but sometimes has trailling garbage, so we cant use yaml parser.
    # thumbs up
    assay = None
    project = None

    while(1):
        line = stream.readline()
        if not line:
            break
        if line.find("Assay:") == 0:
            (key, value) = line.strip().split(":")
            assay = value.strip()
        if line.find("ProjectID:") > -1:
            (key, value) = line.strip().split(":")
            project = value.strip()
    return (assay, project)


def get_curated_bams(assay,REQUEST_FILES):
    # Default to AgilentExon_51MB_b37_v3 BAMs. Use IMPACT410 BAMs for all IMPACT/HemePACT projects
    json_curated_bams = REQUEST_FILES['curated_bams']['AgilentExon_51MB_b37_v3']
    if assay.find("IMPACT") > -1 or assay.find("HemePACT") > -1:
        json_curated_bams = REQUEST_FILES['curated_bams']['IMPACT410_b37']
    array = []
    for bam in json_curated_bams:
        array.append({'class': 'File', 'path': str(bam)})

    return array


def get_baits_and_targets(assay,ROSLIN_RESOURCES):
    # probably need similar rules for whatever "Exome" string is in rquest
    targets = ROSLIN_RESOURCES['targets']

    if assay.find("IMPACT410") > -1:
        assay = "IMPACT410_b37"
    if assay.find("IMPACT468") > -1:
        assay = "IMPACT468_b37"
    if assay.find("IMPACT341") > -1:
        assay = "IMPACT341_b37"
    if assay.find("IDT_Exome_v1_FP") > -1:
        assay = "IDT_Exome_v1_FP_b37"
    if assay.find("IMPACT468+08390") > -1:
        assay = "IMPACT468_08390"

    if assay in targets:
        return {"bait_intervals": {"class": "File", "path": str(targets[assay]['baits_list'])},
                "target_intervals": {"class": "File", "path": str(targets[assay]['targets_list'])},
                "fp_intervals": {"class": "File", "path": str(targets[assay]['FP_intervals'])},
                "fp_genotypes": {"class": "File", "path": str(targets[assay]['FP_genotypes'])},
		"conpair_markers": {"class": "File", "path": str(targets[assay]['conpair_markers'])},
		"conpair_markers_bed": {"class": "File", "path": str(targets[assay]['conpair_markers_bed'])}
		}
    else:
        print >>sys.stderr, "ERROR: Targets for Assay not found in roslin_resources.json: %s" % assay
        sys.exit(1)


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
            print >>sys.stderr, "ERROR: Can't find filename parts (Sample/Barcode, R1/2, group) for this fastq: %s" % file
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
                    paired_by_sample[read].append(os.path.abspath(sorted[sample][readset][read]))
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
    parser.add_argument("-r", "--request", help="the request file", required=True)
    parser.add_argument("-o", "--output-directory", help="output_directory for pipeline (NOT CONFIG FILE)", required=True)
    parser.add_argument("-f", "--yaml-output-file", help="file to write yaml to", required=True)
    parser.add_argument("--pipeline-name-version",action="store",dest="pipeline_name_version",help="Pipeline name/version (e.g. variant/1.0.0)",required=True)
    args = parser.parse_args()
    pipeline_settings = read_pipeline_settings(args.pipeline_name_version)
    ROSLIN_PATH = pipeline_settings['ROSLIN_PIPELINE_BIN_PATH']
    ROSLIN_RESOURCES = json.load(open(ROSLIN_PATH + os.sep + "scripts" + os.sep + "roslin_resources.json", 'r'))
    REQUEST_FILES = ROSLIN_RESOURCES["request_files"]
    (assay, project_id) = parse_request_file(args.request)
    intervals = get_baits_and_targets(assay,ROSLIN_RESOURCES)
    curated_bams = get_curated_bams(assay,REQUEST_FILES)
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
    covariates = ['CycleCovariate', 'ContextCovariate', 'ReadGroupCovariate', 'QualityScoreCovariate']
    rf = ["BadCigar"]
    genome = "GRCh37"
    delly_type = [ "DUP", "DEL", "INV", "INS", "BND" ]

    files = {
        'mapping_file': {'class': 'File', 'path': os.path.realpath(args.mapping)},
        'pairing_file': {'class': 'File', 'path': os.path.realpath(args.pairing)},
        'grouping_file': {'class': 'File', 'path': os.path.realpath(args.grouping)},
        'request_file': {'class': 'File', 'path': os.path.realpath(args.request)},
        'hapmap': {'class': 'File', 'path': str(REQUEST_FILES['hapmap'])}, 
        'dbsnp': {'class': 'File', 'path': str(REQUEST_FILES['dbsnp'])},
        'indels_1000g': {'class': 'File', 'path': str(REQUEST_FILES['indels_1000g'])}, 
        'snps_1000g': {'class': 'File', 'path': str(REQUEST_FILES['snps_1000g'])},
        'cosmic': {'class': 'File', 'path': str(REQUEST_FILES['cosmic'])},
        'refseq': {'class': 'File', 'path': str(REQUEST_FILES['refseq'])},
        'exac_filter': {'class': 'File', 'path': str(REQUEST_FILES['exac_filter'])},
        'vep_data': str(REQUEST_FILES['vep_data']),
        'curated_bams': curated_bams,
        'hotspot_list': {'class': 'File', 'path': str(REQUEST_FILES['hotspot_list'])},
        'hotspot_vcf': {'class': 'File', 'path': str(REQUEST_FILES['hotspot_vcf'])},
        'ref_fasta':  str(REQUEST_FILES['ref_fasta'])
    }
    files.update(intervals)

    sample_list = list()

    # do some checks for missing sample IDs
    fail = 0
    list_of_pair_samples = []
    for pair in pairing_dict:
        if pair[0] not in mapping_dict.keys():
            print >>sys.stderr, "pair %s in pairing file has id not in mapping file: %s" % (str(pair), pair[0])
            fail = 1
        if pair[1] not in mapping_dict.keys():
            print >>sys.stderr, "pair %s in pairing file has id not in mapping file: %s" % (str(pair), pair[1])
            fail = 1
        list_of_pair_samples.append(pair[0])
        list_of_pair_samples.append(pair[1])
    for group in grouping_dict.values():
        for sample in group:
            if sample not in mapping_dict.keys():
                print >>sys.stderr, "grouping file has id %s, but this wasn't found in mapping file" % sample
                fail = 1
            if sample not in list_of_pair_samples:
                print >>sys.stderr, "grouping file has id %s, but this wasn't found in pairing file" % sample
                sys.exit(1)

    if fail:
        print >>sys.stderr, "ERROR: Pairing/grouping files have sample IDs not found in mapping file. Please review."
        sys.exit(1)

    for sample_id, sample in mapping_dict.items():
        new_sample_object = dict()
        new_sample_object['adapter'] = adapter_one_string
        new_sample_object['adapter2'] = adapter_two_string
        new_sample_object['R1'] = sample['fastqs']['R1']
        new_sample_object['R2'] = sample['fastqs']['R2']
        new_sample_object['LB'] = sample_id + sample['library_suffix']
        new_sample_object['RG_ID'] = [ x + sample['runtype'] for x in sample['rg_id'] ]
        new_sample_object['PU'] = sample['rg_id']
        new_sample_object['ID'] = sample_id
        new_sample_object['PL'] = "Illumina"
        new_sample_object['CN'] = "MSKCC"
        new_sample_object['bwa_output'] = sample['sample_id'] + ".bam"
        sample_list.append(new_sample_object)
    out_dict = {
        "samples": sample_list,
        "pairs": pairing_dict,
        "groups": grouping_dict.values(),
        "db_files": files,
    }
    params = {
        "abra_scratch": "/scratch/roslin/",
        "genome": genome,
        "mutect_dcov": 50000,
        "mutect_rf": rf,
        "num_cpu_threads_per_data_thread": 6,
        "covariates": covariates,
        "emit_original_quals": True,
        "num_threads": 10,
        "tmp_dir": "/scratch/roslin/",
        "project_prefix": project_id,
        "opt_dup_pix_dist": "2500",
        "delly_type": delly_type
    }
    out_dict.update({"runparams": params})
    ofh = open(args.yaml_output_file, "wb")
    ofh.write(yaml.dump(out_dict))
    ofh.close()
