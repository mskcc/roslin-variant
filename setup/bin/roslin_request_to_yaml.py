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
    with open(mfile, "r") as fh:
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
    with open(pfile, "r") as fh:
        csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=pairing_headers)
        for row in csvreader:
            pairing.append([row['tumor_id'].replace("-","_"), row['normal_id'].replace("-","_")])

    return pairing


def parse_grouping_file(gfile):
    grouping_dict = dict()
    with open(gfile, "r") as fh:
        csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=grouping_headers)
        for row in csvreader:
            if row['group_id'] not in grouping_dict:
                grouping_dict[row['group_id']] = list()
            grouping_dict[row['group_id']].append(row['sample_id'].replace("-","_"))

    return grouping_dict


def parse_request_file(rfile):
    request_info = {'Assay': None,'ProjectID': None,'ProjectTitle': None,'ProjectDesc': None,'PI': None, 'TumorType': None}

    with open(rfile, "r") as stream:
        while True:
            line = stream.readline()
            if not line:
                break
            for single_key in request_info:
                if line.find(single_key) > -1:
                    (key, value) = line.strip().split(":")
                    request_info[single_key] = value.strip()
    return request_info


def get_curated_bams(assay,REQUEST_FILES):
    # Default to IMPACT468 BAMs for all projects except Agilent/IDTdna Exomes
    json_curated_bams = REQUEST_FILES['curated_bams']['IMPACT468_b37']
    if assay.find("AgilentExon_51MB_b37_v3") > -1 or assay.find("Agilent_v4_51MB_Human") > -1:
        json_curated_bams = REQUEST_FILES['curated_bams']['AgilentExon_51MB_b37_v3']
    elif assay.find("IDT_Exome_v1_FP") > -1:
        json_curated_bams = REQUEST_FILES['curated_bams']['IDT_Exome_v1_FP_b37']
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
                "fp_genotypes": {"class": "File", "path": str(targets[assay]['FP_genotypes'])}
    }
    else:
        print >>sys.stderr, "ERROR: Targets for Assay not found in roslin_resources.json: %s" % assay
        sys.exit(1)

def get_facets_cval(assay):
    if assay.find("IMPACT") > -1 or assay.find("HemePACT") > -1:
        return 50
    return 100

def get_facets_pcval(assay):
    if assay.find("IMPACT") > -1 or assay.find("HemePACT") > -1:
        return 100
    return 500

def get_complex_nn(assay):
    if assay.find("IMPACT") > -1 or assay.find("HemePACT") > -1:
        return 0.2
    return 0.1

def get_complex_tn(assay):
    if assay.find("IMPACT") > -1 or assay.find("HemePACT") > -1:
        return 0.5
    return 0.2

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

def calculate_abra_ram_size(grouping_dict):
    group_larger_than_three_exists = False
    for group in grouping_dict:
        if len(grouping_dict[group]) > 3:
            group_larger_than_three_exists = True
    if group_larger_than_three_exists:
        return 512000
    return 36000

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="convert current project files to yaml input")
    parser.add_argument("-m", "--mapping", help="the mapping file", required=True)
    parser.add_argument("-p", "--pairing", help="the pairing file", required=True)
    parser.add_argument("-g", "--grouping", help="the grouping file", required=True)
    parser.add_argument("-r", "--request", help="the request file", required=True)
    parser.add_argument("-f", "--yaml-output-file", help="file to write yaml to", required=True)
    parser.add_argument("--pipeline-name-version",action="store",dest="pipeline_name_version",help="Pipeline name/version (e.g. variant/2.5.0)",required=True)
    parser.add_argument("--clinical", help="the clinical data file", required=False)
    args = parser.parse_args()
    pipeline_settings = read_pipeline_settings(args.pipeline_name_version)
    if args.clinical:
        if os.path.exists(args.clinical):
            with open(args.clinical, 'rb') as clinical_data_file:
                clinical_reader = csv.DictReader(clinical_data_file, dialect='excel-tab')
                clinical_data = list(clinical_reader)
        else:
            print >>sys.stderr, "ERROR: Cound not find %s" % args.clinical
    ROSLIN_PATH = pipeline_settings['ROSLIN_PIPELINE_BIN_PATH']
    scripts_bin = "/usr/bin"
    qcpdf_jar_path = os.path.join("/usr/bin", "QCPDF.jar")
    roslin_resource_path = ROSLIN_PATH + os.sep + "scripts" + os.sep + "roslin_resources.json"
    with open(roslin_resource_path, 'r') as roslin_resource_file:
        ROSLIN_RESOURCES = json.load(roslin_resource_file)
    REQUEST_FILES = ROSLIN_RESOURCES["request_files"]
    request_info = parse_request_file(args.request)
    assay = request_info['Assay']
    project_id = request_info['ProjectID']
    intervals = get_baits_and_targets(assay,ROSLIN_RESOURCES)
    gatk_jar_path = str(ROSLIN_RESOURCES["programs"]["gatk"]["default"])
    curated_bams = get_curated_bams(assay,REQUEST_FILES)
    mapping_dict = parse_mapping_file(args.mapping)
    pairing_dict = parse_pairing_file(args.pairing)
    grouping_dict = parse_grouping_file(args.grouping)
    abra_ram_min = calculate_abra_ram_size(grouping_dict)
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
    facets_cval = get_facets_cval(assay)
    facets_pcval = get_facets_pcval(assay)
    complex_nn = get_complex_nn(assay)
    complex_tn = get_complex_tn(assay)
    temp_dir = "/scratch"
    if os.environ['TMPDIR']:
        temp_dir = os.environ['TMPDIR']

    files = {
        'mapping_file': {'class': 'File', 'path': os.path.realpath(args.mapping)},
        'pairing_file': {'class': 'File', 'path': os.path.realpath(args.pairing)},
        'grouping_file': {'class': 'File', 'path': os.path.realpath(args.grouping)},
        'request_file': {'class': 'File', 'path': os.path.realpath(args.request)},
        'refseq': {'class': 'File', 'path': str(REQUEST_FILES['refseq'])},
        'vep_data': str(REQUEST_FILES['vep_data']),
        'hotspot_list': str(REQUEST_FILES['hotspot_list']),
        'hotspot_list_maf': {'class': 'File', 'path': str(REQUEST_FILES['hotspot_list_maf'])},
        'hotspot_vcf': str(REQUEST_FILES['hotspot_vcf']),
        'facets_snps': str(ROSLIN_RESOURCES['genomes'][genome]['facets_snps']),
        'custom_enst': str(REQUEST_FILES['custom_enst']),
        'vep_path': str(REQUEST_FILES['vep_path']),
        'ref_fasta':  str(REQUEST_FILES['ref_fasta']),
        'conpair_markers': str(REQUEST_FILES['conpair_markers']),
        'conpair_markers_bed': str(REQUEST_FILES['conpair_markers_bed'])
    }

    files.update(intervals)

    sample_dict = {}
    pair_list = []

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
        sample_dict[sample_id] = new_sample_object

    for pair in pairing_dict:
        first_pair_id = pair[0]
        first_pair_obj = sample_dict[first_pair_id]
        second_pair_id = pair[1]
        second_pair_obj = sample_dict[second_pair_id]
        single_pair = [first_pair_obj,second_pair_obj]
        pair_list.append(single_pair)

    out_dict = {
        "pairs": pair_list,
        "groups": grouping_dict.values(),
        "curated_bams": curated_bams,
        "hapmap": {'class': 'File', 'path': str(REQUEST_FILES['hapmap'])},
        "dbsnp": {'class': 'File', 'path': str(REQUEST_FILES['dbsnp'])},
        "indels_1000g": {'class': 'File', 'path': str(REQUEST_FILES['indels_1000g'])},
        "snps_1000g": {'class': 'File', 'path': str(REQUEST_FILES['snps_1000g'])},
        "cosmic": {'class': 'File', 'path': str(REQUEST_FILES['cosmic'])},
        'exac_filter': {'class': 'File', 'path': str(REQUEST_FILES['exac_filter'])},
        "db_files": files
    }
    params = {
        "abra_scratch": temp_dir,
        "abra_ram_min": abra_ram_min,
        "genome": genome,
        "intervals": ROSLIN_RESOURCES['genomes'][genome]['intervals'],
        "mutect_dcov": 50000,
        "mutect_rf": rf,
        "num_cpu_threads_per_data_thread": 6,
        "covariates": covariates,
        "emit_original_quals": True,
        "num_threads": 10,
        "tmp_dir": temp_dir,
        "project_prefix": project_id,
        "opt_dup_pix_dist": "2500",
        "delly_type": delly_type,
        "facets_cval": facets_cval,
        "facets_pcval": facets_pcval,
        "complex_nn": complex_nn,
        "complex_tn": complex_tn,
        "scripts_bin": scripts_bin,
        "gatk_jar_path": gatk_jar_path
    }
    out_dict.update({"runparams": params})
    out_dict.update({"meta": request_info})
    if args.clinical:
        out_dict['meta'].update({"clinical_data": clinical_data})
    with open(args.yaml_output_file, "wb") as ofh:
        ofh.write(yaml.dump(out_dict))