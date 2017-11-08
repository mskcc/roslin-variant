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
import cmo
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
        #take all hyphens out, these will be word separators in fastq chunks
        #fuck hyphens, as well
        #like, seriously
        row['sample_id'] = row['sample_id'].replace("-", "_")
        new_row = copy.deepcopy(row)
        rg_id = row['sample_id'].replace("-","_") + new_row['library_suffix'].replace("-","_") + "-" + new_row['run_id'].replace("-","_")
        new_row['run_id']=new_row['run_id'].replace("-","_")
        #hyphens suck
        fastqs = sort_fastqs_into_dict(glob.glob(os.path.join(new_row['fastq_directory'], "*R[12]*.fastq.gz")))
        new_row['rg_id']= []
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
                mapping_dict[row['sample_id']]['rg_id'].append(row['sample_id'] + new_row['library_suffix'] + "-"+new_row['run_id'])
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
        if line.find("Assay:") ==0:
            (key, value) = line.strip().split(": ")
            assay = value
        if line.find("ProjectID") > -1:
            (key, value) = line.strip().split(": ")
            project = value
    return (assay, project)


def get_baits_and_targets(assay):
    # probably need similar rules for whatever "Exome" string is in rquest
    if assay.find("IMPACT410") > -1:
        assay = "IMPACT410_b37"
    if assay.find("IMPACT468") > -1:
        assay = "IMPACT468_b37"
    if assay.find("IMPACT341") > -1:
        assay = "IMPACT341_b37"


    if assay in cmo.util.targets:
        return {"bait_intervals": {"class": "File", "path": str(cmo.util.targets[assay]['baits_list'])},
                "target_intervals": {"class": "File", "path": str(cmo.util.targets[assay]['targets_list'])},
                "fp_intervals": {"class": "File", "path": str(cmo.util.targets[assay]['FP_intervals'])},
                "fp_genotypes": {"class": "File", "path": str(cmo.util.targets[assay]['FP_genotypes'])}}

    else:
        print >>sys.stderr, "Assay field in Request file not found in cmo_resources.json targets: %s" % assay
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
    parser.add_argument("-r", "--request", help="the request file", required=True)
    parser.add_argument("-o", "--output-directory", help="output_directory for pipeline (NOT CONFIG FILE)", required=True)
    parser.add_argument("-f", "--yaml-output-file", help="file to write yaml to", required=True)
    args = parser.parse_args()
    (assay, project_id) = parse_request_file(args.request)
    intervals = get_baits_and_targets(assay)
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
    rf = ["BadCigar"]
    genome = "GRCh37"

    files = {
        'mapping_file': {'class': 'File', 'path': os.path.realpath(args.mapping)},
        'pairing_file': {'class': 'File', 'path': os.path.realpath(args.pairing)},
        'grouping_file': {'class': 'File', 'path': os.path.realpath(args.grouping)},
        'request_file': {'class': 'File', 'path': os.path.realpath(args.request)},
        'hapmap': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/hapmap_3.3.b37.vcf'},
        'dbsnp': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/dbsnp_138.b37.excluding_sites_after_129.vcf'},
        'indels_1000g': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/Mills_and_1000G_gold_standard.indels.b37.vcf'},
        'snps_1000g': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/1000G_phase1.snps.high_confidence.b37.vcf'},
        'cosmic': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/CosmicCodingMuts_v67_b37_20131024__NDS.vcf'},
        'refseq': {'class': 'File', 'path': "/ifs/work/prism/chunj/test-data/ref/refGene_b37.sorted.txt"},
        'exac_filter': {'class': 'File', 'path': '/ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz'},
        'vep_data': '/ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86',
        'curated_bams': [
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M12-1892-N_bc10_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-44042-1-N_bc24_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-44503-N_bc39_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-43532-1-N_bc16_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M12-2615-N_bc12_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-44056-1-N_bc23_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-44315-1-N_bc30_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M11-3639-N_bc03_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-44538-N_bc36_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-43646-1-N_bc29_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-40685-N_bc34_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M12-0399-N_bc08_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-43697-1-N_bc33_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M14-8322-2-N_bc14_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-41382-1-N_bc17_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M14-7594-1-N_bc21_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M11-1637-N_bc11_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M13-1083-N_bc06_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M11-1089-N_bc04_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/M12-0994-N_bc05_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S12-18799-N_bc38_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-43894-1-N_bc32_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'},
            {'class': 'File', 'path': '/ifs/depot/resources/dmp/data/mskdata/std-normals-bam/VERSIONS/cv5/S14-44576-1-N_bc27_IMPACTv5-VAL-FFPECTRL2014_L000_mrg_cl_aln_srt_MD_IR_FX_BR.bam'}
        ],
        'ffpe_normal_bams': [
            {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ffpe/Proj_06049_Pool_indelRealigned_recal_s_UD_ffpepool1_N.bam'}
        ],
        'hotspot_list': {'class': 'File', 'path': '/ifs/work/prism/chunj/test-data/ref/hotspot-list-union-v1-v2.txt'},
        'ref_fasta': "/ifs/work/chunj/prism-proto/ifs/depot/assemblies/H.sapiens/b37/b37.fasta"
    }
    files.update(intervals)

    ofh = open(args.yaml_output_file, "wb")
    sample_list = list()
    #rudimentary data checking charris 9-6-2017
    fail = []
    for (counter, pair) in enumerate(pairing_dict, 0):
        if pair[0] not in mapping_dict.keys():
            print >>sys.stderr, "pair %s in pairing file has id not in mapping file: %s " % (str(pair), pair[0])
            fail.append(counter)
        elif pair[1] not in mapping_dict.keys():
            print >>sys.stderr, "pair %s in pairing file has id not in mapping file: %s " % (str(pair), pair[1])
            fail.append(counter)
    for group in grouping_dict.values():
        for sample in group:
            if  sample not in mapping_dict.keys():
                print >>sys.stderr, "grouping file has uses id %s, but this wasn't found in mapping file--REVIEW INPUTS--" % sample
                sys.exit(1)
    if fail:
        fail.reverse()
        for index_to_delete in fail:
            print >>sys.stderr, "PAIR HAS NA!!! -- Removing %s and %s as a pair in inputs.yaml" % (pairing_dict[index_to_delete-1][0], pairing_dict[index_to_delete][1])
            del pairing_dict[index_to_delete]





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
        "abra_scratch": "/scratch/",
        "genome": genome,
        "mutect_dcov": 50000,
        "mutect_rf": rf,
        "num_cpu_threads_per_data_thread": 6,
        "covariates": covariates,
        "emit_original_quals": True,
        "num_threads": 10,
        "tmp_dir": "/scratch",
        "project_prefix": project_id,
        "opt_dup_pix_dist": "2500"
    }
    out_dict.update({"runparams": params})
    ofh.write(yaml.dump(out_dict))
    ofh.close()
