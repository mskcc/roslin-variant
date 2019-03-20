#!/usr/bin/env python

import argparse, os, sys, yaml, json, re, time, io, csv, shutil, logging
from subprocess import Popen, PIPE
from tempfile import mkdtemp
from datetime import date
from distutils.dir_util import copy_tree
import genPortalUUID
import traceback
import copy


logger = logging.getLogger("roslin_analysis_helper")
old_jobs_folder = "oldJobs"

def generate_legacy_clinical_data(clinical_data,coverage_values):
    for single_row in clinical_data:
        sample_id = single_row['SAMPLE_ID']
        coverage_value = coverage_values[sample_id]
        single_row['SAMPLE_COVERAGE'] = coverage_value
    return clinical_data


def get_sample_list(clinical_data):
    sample_list = []
    for single_row in clinical_data:
        sample_list.append(single_row['SAMPLE_ID'])
    return sample_list

def run_command_list(command_list,name):
    command_num = 1
    for single_command in command_list:
        single_command_name = name + '_' + str(command_num)
        run_job(single_command,True,single_command_name)
        command_num = command_num + 1

def generate_maf_data(maf_directory,output_directory,maf_file_name,analysis_mut_file,log_directory,script_path,pipeline_version_str,is_impact):
    maf_files_query = os.path.join(maf_directory,'*.muts.maf')
    combined_output = maf_file_name.replace('.txt','.combined.txt')
    combined_output_file = os.path.join(output_directory,combined_output)
    pipeline_version_str_arg = pipeline_version_str.replace(' ','_')
    portal_file = os.path.join(output_directory,maf_file_name)
    regexp_string = "--regexp='^(Hugo|#)'"
    maf_filter_script = os.path.join(script_path,'maf_filter.py')
    tmp_combined_output_file = combined_output_file + ".tmp"
    maf_command_list = []
    maf_command_list.append('grep -h --regexp=^Hugo ' + maf_files_query + ' > ' + tmp_combined_output_file)
    maf_command_list.append('head -n1 ' + tmp_combined_output_file + ' > ' + combined_output_file)
    maf_command_list.append('rm ' + tmp_combined_output_file)
    maf_command_list.append('grep -hEv ' + regexp_string + ' ' + maf_files_query + ' >> ' + combined_output_file)
    maf_command_list.append('python ' + ' '.join([maf_filter_script, combined_output_file, pipeline_version_str_arg, str(is_impact), analysis_mut_file, portal_file]))
    run_command_list(maf_command_list,'generate_maf')

def generate_fusion_data(fusion_directory,output_directory,data_filename,log_directory,script_path):
    fusion_files_query = os.path.join(fusion_directory,'*.svs.pass.vep.portal.txt')
    combined_output = data_filename.replace('.txt','.combined.txt')
    combined_output_path = os.path.join(output_directory,combined_output)
    output_path = os.path.join(output_directory,data_filename)
    fusion_filter_script = os.path.join(script_path,'fusion_filter.py')
    tmp_combined_output_file = combined_output_path + ".tmp"
    fusion_command_list = []
    fusion_command_list.append('grep -h --regexp=^Hugo ' + fusion_files_query + ' > ' + tmp_combined_output_file)
    fusion_command_list.append('head -n1 ' + tmp_combined_output_file + ' > ' + combined_output_path)
    fusion_command_list.append('rm ' + tmp_combined_output_file)
    fusion_command_list.append('grep -hv --regexp=^Hugo ' + fusion_files_query + ' >> ' + combined_output_path)
    fusion_command_list.append('python ' + fusion_filter_script + ' ' + combined_output_path + ' ' + output_path)
    run_command_list(fusion_command_list,'generate_fusion')

def assay_matcher(assay):
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
    return assay

def generate_discrete_copy_number_data(data_directory,output_directory,data_filename,gene_cna_file,assay,log_directory):
    discrete_copy_number_files_query = os.path.join(data_directory,'*_hisens.cncf.txt')
    output_path = os.path.join(output_directory,data_filename)
    scna_output_path = output_path.replace('.txt','.scna.txt')
    extra_arg = ''
    if "ROSLIN_PIPELINE_BIN_PATH" in os.environ:
        roslin_resources_path = os.path.join(os.environ["ROSLIN_PIPELINE_BIN_PATH"],'scripts','roslin_resources.json')
        os.environ['CMO_RESOURCE_CONFIG'] = roslin_resources_path
        with open(roslin_resources_path) as roslin_resources_file:
            roslin_resources_data = json.load(roslin_resources_file)
            targets = roslin_resources_data['targets']
            if assay not in targets:
                assay = assay_matcher(assay)
            interval_list = targets[assay]['targets_list']
            extra_arg = '--targetFile '+ interval_list
    cna_command_list = []
    cna_command_list.append('tool.sh --tool facets --version 1.5.6 --language_version default --language python --cmd geneLevel ' + extra_arg + ' -f ' + discrete_copy_number_files_query + ' -m scna -o ' + output_path)
    cna_command_list.append('mv ' + output_path + ' ' + gene_cna_file)
    cna_command_list.append('mv ' + scna_output_path + ' ' + output_path)
    run_command_list(cna_command_list,'generate_discrete_copy_number')

def generate_segmented_copy_number_data(data_directory,output_directory,data_filename,analysis_seg_file,log_directory):
    segmented_files_query = os.path.join(data_directory,'*_hisens.seg')
    combined_output_path = os.path.join(output_directory,data_filename)
    tmp_combined_output_file = combined_output_path + ".tmp"
    # ::TODO:: Using a weird awk here to reduce log-ratio significant digits. Do it in facets.
    seg_command_list = []
    seg_command_list.append('grep -h --regexp=^ID ' + segmented_files_query + ' > ' + tmp_combined_output_file)
    seg_command_list.append('head -n1 ' + tmp_combined_output_file + ' > ' + combined_output_path)
    seg_command_list.append('grep -hv --regexp=^ID ' + segmented_files_query + ' | awk \'OFS="\t" {$6=sprintf("%.4f",$6); print}\' >> ' + combined_output_path)
    seg_command_list.append('cp ' + combined_output_path + ' ' + analysis_seg_file)
    run_command_list(seg_command_list,'generate_segmented_copy_number')

def create_case_list_file(cases_path,cases_data):
    with open(cases_path,'w') as cases_file:
        for single_category in cases_data:
            single_line = single_category+': '+cases_data[single_category]+ '\n'
            cases_file.write(single_line)

def generate_case_lists(portal_config_data,sample_list,output_directory):
    list_of_samples_str = '\t'.join(sample_list)
    cases_all_data = {}
    cases_cnaseq_data = {}
    cases_cna_data = {}
    cases_sequenced_data = {}
    cases_all_data['cancer_study_identifier'] = portal_config_data['stable_id']
    cases_all_data['stable_id'] = portal_config_data['stable_id'] + "_all"
    cases_all_data['case_list_category'] = "all_cases_in_study"
    cases_all_data['case_list_name'] = "All Tumors"
    cases_all_data['case_list_description'] = "All tumor samples"
    cases_all_data['case_list_ids'] = list_of_samples_str
    cases_cnaseq_data['cancer_study_identifier'] = portal_config_data['stable_id']
    cases_cnaseq_data['stable_id'] = portal_config_data['stable_id'] + "_cnaseq"
    cases_cnaseq_data['case_list_category'] = "all_cases_with_mutation_and_cna_data"
    cases_cnaseq_data['case_list_name'] = "Tumors with sequencing and CNA data"
    cases_cnaseq_data['case_list_description'] = "All tumor samples that have CNA and sequencing data"
    cases_cnaseq_data['case_list_ids'] = list_of_samples_str
    cases_cna_data['cancer_study_identifier'] = portal_config_data['stable_id']
    cases_cna_data['stable_id'] = portal_config_data['stable_id'] + "_cna"
    cases_cna_data['case_list_category'] = "all_cases_with_cna_data"
    cases_cna_data['case_list_name'] = "Tumors CNA"
    cases_cna_data['case_list_description'] = "All tumors with CNA data"
    cases_cna_data['case_list_ids'] = list_of_samples_str
    cases_sequenced_data['cancer_study_identifier'] = portal_config_data['stable_id']
    cases_sequenced_data['stable_id'] = portal_config_data['stable_id'] + "_sequenced"
    cases_sequenced_data['case_list_category'] = "all_cases_with_mutation_data"
    cases_sequenced_data['case_list_name'] = "Sequenced Tumors"
    cases_sequenced_data['case_list_description'] = "All sequenced tumors"
    cases_sequenced_data['case_list_ids'] = list_of_samples_str
    case_lists_dir = os.path.join(output_directory,'case_lists')
    if not os.path.exists(case_lists_dir):
        os.makedirs(case_lists_dir)
    cases_all_path = os.path.join(case_lists_dir,'cases_all.txt')
    cases_cnaseq_path = os.path.join(case_lists_dir,'cases_cnaseq.txt')
    cases_cna_path = os.path.join(case_lists_dir,'cases_cna.txt')
    cases_sequenced_path = os.path.join(case_lists_dir,'cases_sequenced.txt')
    create_case_list_file(cases_all_path,cases_all_data)
    create_case_list_file(cases_cnaseq_path,cases_cnaseq_data)
    create_case_list_file(cases_cna_path,cases_cna_data)
    create_case_list_file(cases_sequenced_path,cases_sequenced_data)

def generate_segmented_meta(portal_config_data, data_filename):
    segmented_meta_data = {}
    segmented_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
    segmented_meta_data['genetic_alteration_type'] = 'COPY_NUMBER_ALTERATION'
    segmented_meta_data['datatype'] = 'SEG'
    segmented_meta_data['description'] = 'Segmented Data'
    segmented_meta_data['reference_genome_id'] = 'hg19'
    segmented_meta_data['data_filename'] = data_filename
    return segmented_meta_data

def generate_study_meta(portal_config_data,pipeline_version_str):
    study_meta_data = {}
    study_meta_data['type_of_cancer'] = portal_config_data['TumorType'].lower()
    study_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
    study_meta_data['name'] = portal_config_data['ProjectTitle'] + ' (' + portal_config_data['ProjectID'] + ') [' + pipeline_version_str + ', ' + str(date.today()) + ']'
    study_meta_data['short_name'] =  portal_config_data['ProjectID']
    study_meta_data['description'] = portal_config_data['ProjectDesc'].replace('\n', '')
    study_meta_data['groups'] = 'PRISM;COMPONC;VIALEA' # These groups can access everything
    # Find the PI that funded this project, and make sure their group has access too
    if 'PI' in portal_config_data and portal_config_data['PI'] is not 'NA':
        study_meta_data['groups'] += ';' + portal_config_data['PI'].upper().replace(" ", "")
    #study_meta_data['add_global_case_list'] = True
    return study_meta_data

def generate_discrete_copy_number_meta(portal_config_data, data_filename):
    discrete_copy_number_meta_data = {}
    discrete_copy_number_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
    discrete_copy_number_meta_data['genetic_alteration_type'] = 'COPY_NUMBER_ALTERATION'
    discrete_copy_number_meta_data['datatype'] = 'DISCRETE'
    discrete_copy_number_meta_data['stable_id'] = 'cna'
    discrete_copy_number_meta_data['show_profile_in_analysis_tab'] = True
    discrete_copy_number_meta_data['profile_name'] = 'Discrete Copy Number Data'
    discrete_copy_number_meta_data['profile_description'] = 'Discrete Copy Number Data'
    #discrete_copy_number_meta_data['description'] = 'copy_number Data'
    discrete_copy_number_meta_data['data_filename'] = data_filename
    return discrete_copy_number_meta_data

def generate_mutation_meta(portal_config_data,maf_file_name):
    mutation_meta_data = {}
    mutation_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
    mutation_meta_data['genetic_alteration_type'] = 'MUTATION_EXTENDED'
    mutation_meta_data['datatype'] = 'MAF'
    mutation_meta_data['stable_id'] = 'mutations'
    mutation_meta_data['show_profile_in_analysis_tab'] = True
    mutation_meta_data['profile_description'] = 'Mutation data'
    mutation_meta_data['profile_name'] = 'Mutations'
    mutation_meta_data['data_filename'] = maf_file_name
    return mutation_meta_data

def generate_fusion_meta(portal_config_data,data_filename):
    fusion_meta_data = {}
    fusion_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
    fusion_meta_data['genetic_alteration_type'] = 'FUSION'
    fusion_meta_data['datatype'] = 'FUSION'
    fusion_meta_data['stable_id'] = 'fusion'
    fusion_meta_data['show_profile_in_analysis_tab'] = True
    fusion_meta_data['profile_description'] = 'Fusion data'
    fusion_meta_data['profile_name'] = 'Fusions'
    fusion_meta_data['data_filename'] = data_filename
    return fusion_meta_data

def run_job(command, shell, name):
    logger.info("Running job "+ name)
    logger.debug("Command: "+command)
    output_message = ""
    error_message = ""
    try:
        single_process = Popen(command, stdout=PIPE,stderr=PIPE, shell=shell)
        stdout, stderr = single_process.communicate()
        errorcode = single_process.returncode
        if stdout:
            output_message = "----- log stdout -----\n {}".format(stdout)
        if stderr:
            error_message = "----- log stderr -----\n {}".format(stderr)
        if errorcode != 0:
            error_message = error_message + "\nJob ( {} ) Failed, errorcode: {}".format(name,str(errorcode))
        else:
            output_message = output_message + "\nJob ( {} ) Done".format(name)
    except:
        error_message = error_message + "\nJob ( {} ) Failed. Exception:\n{}".format(name,traceback.format_exc())
    if output_message:
        logger.info(output_message)
    if error_message:
        logger.info(error_message)

def get_meta_info(input_yaml):
    meta_info = {}
    with open(input_yaml) as input_yaml_file:
        meta_info = yaml.safe_load(input_yaml_file)['meta']
    return meta_info

def check_if_impact(assay):
    is_impact = False
    if assay:
        if "IMPACT" in assay or "HemePACT" in assay:
            is_impact = True
    return is_impact

def create_meta_clinical_files_new_format(datatype, filepath, filename, study_id):
    with open(filepath, 'wb') as output_file:
        output_file.write('cancer_study_identifier: %s\n' % study_id)
        output_file.write('genetic_alteration_type: CLINICAL\n')
        output_file.write('datatype: %s\n' % datatype)
        output_file.write('data_filename: %s\n' % filename)

def create_data_clinical_files_new_format(clinical_data):
    samples_file_txt = ""
    patients_file_txt = ""
    header = clinical_data[0].keys()
    samples_header = get_samples_header(header)
    patients_header = get_patients_header(header)
    data_attr = set_attributes(header)
    samples_file_txt = generate_file_txt(clinical_data, data_attr, samples_header)
    patients_file_txt = generate_patient_file_txt(clinical_data, data_attr, patients_header)

    return samples_file_txt, patients_file_txt

def get_samples_header(header):
    temp_header = set(header)
    for element in get_patients_header(header):
        temp_header.discard(element)
    samples_header = ["SAMPLE_ID", "PATIENT_ID"]
    for header in temp_header:
        if header not in samples_header and header != None:
            samples_header.append(header)
    return samples_header

def get_patients_header(header):
    return {"PATIENT_ID", "SEX"} #to do AGE and other additional patient-specific fields

def set_attributes(data):
    d = dict()
    # ::TODO:: This is a rough place for these; should move somewhere later
    NUMBER_DATATYPE = set()
    NUMBER_DATATYPE.add('SAMPLE_COVERAGE')
    ZERO_PRIORITY = set()
    ZERO_PRIORITY.add('COLLAB_ID')

    for key in data:
        d[key] = dict()
        d[key]["desc"] = key
        d[key]["datatype"] = "NUMBER" if key in NUMBER_DATATYPE else "STRING"
        d[key]["priority"] = "0" if key in ZERO_PRIORITY else "1"
    return d

# Convert this stuff into an object later, because this is MESSY AS HELL
def generate_file_txt(data, attr, header):
    order = list()
    row1 = "#"
    row2 = "#"
    row3 = "#"
    row4 = "#"

    row2_values = list()
    row3_values = list()
    row4_values = list()

    for heading in header:
        order.append(heading)
        row2_values.append(attr[heading]['desc'])
        row3_values.append(attr[heading]['datatype'])
        row4_values.append(attr[heading]['priority'])

    row1 = "#" + "\t".join(order) + "\n"
    row2 = "#" + "\t".join(row2_values) + "\n"
    row3 = "#" + "\t".join(row3_values) + "\n"
    row4 = "#" + "\t".join(row4_values) + "\n"

    metadata = row1 + row2 + row3 + row4

    data_str = "\t".join(order) + "\n"
    for row in data:
        temp_list = list()
        for heading in order:
            row_value = row[heading].strip()
            temp_list.append(row_value)
        data_str += "\t".join(temp_list) + "\n"

    file_txt = metadata + data_str
    return file_txt

def generate_patient_file_txt(data, attr, header):
    order = list()
    row1 = "#"
    row2 = "#"
    row3 = "#"
    row4 = "#"

    row2_values = list()
    row3_values = list()
    row4_values = list()

    for heading in header:
        order.append(heading)
        row2_values.append(attr[heading]['desc'])
        row3_values.append(attr[heading]['datatype'])
        row4_values.append(attr[heading]['priority'])

    row1 = "#" + "\t".join(order) + "\n"
    row2 = "#" + "\t".join(row2_values) + "\n"
    row3 = "#" + "\t".join(row3_values) + "\n"
    row4 = "#" + "\t".join(row4_values) + "\n"

    metadata = row1 + row2 + row3 + row4

    data_str = "\t".join(order) + "\n"
    uniqlist = []
    newdata = []
    for row in data:
        if row['PATIENT_ID'] in uniqlist:
            pass
        else:
            uniqlist.append(row['PATIENT_ID'])
            newdata.append(row)
    for row in newdata:
        temp_list = list()
        for heading in order:
            row_value = row[heading].strip()
            temp_list.append(row_value)
        data_str += "\t".join(temp_list) + "\n"

    file_txt = metadata + data_str
    return file_txt

# Replicate parameters expected by cBioPortal validator subroutine, and call it
def validate_portal_data(portal_output_directory):
    logger.info('---------- Running portal validator ----------')
    validator_args = argparse.Namespace(
        study_directory=portal_output_directory,
        no_portal_checks=True,
        url_server=None,
        portal_info_dir=None,
        html_table=None,
        portal_properties=None,
        error_file=None,
        verbose=None,
        relaxed_clinical_definitions=None
    )
    # ::TODO:: The stdout from the validator itself needs to be captured and saved somewhere
    exit_status = validateData.main_validate(validator_args)
    return exit_status

def make_dirs_from_stable_id(mercurial_path, stable_id, project_name):
    subdirs = stable_id.split("_")
    first_dir = subdirs[1]
    second_dir = subdirs[2]
    # Ideally we want to remove the Proj_ prefix, but need to add a 'p' prefix instead so that we
    # hide it from BIC's scripts that look for duplicate projects uploaded to the mercurial repo
    project_name = re.sub(r'^Proj_', 'p', project_name)
    full_path = os.path.join(mercurial_path, first_dir, second_dir, project_name)
    logger.info("Creating directories in mercurial repo: %s" % full_path)
    return full_path

def find_unique_name_in_dir(root_name,directory):
    current_num = 1
    found_unique_name = False
    unique_name = ""
    new_name = root_name
    while not found_unique_name:
        current_path = os.path.join(directory,new_name)
        if os.path.exists(current_path):
            new_name = root_name + str(current_num)
            current_num = current_num + 1
        else:
            found_unique_name = True
            unique_name = new_name
    return new_name



if __name__ == '__main__':
    parser = argparse.ArgumentParser(add_help= True, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--inputs',required=True, help='The path to your input yaml file')
    parser.add_argument('--maf_directory',required=True,help='The directory containing the maf files')
    parser.add_argument('--facets_directory',required=True,help='The directory containing the facets files')
    parser.add_argument('--results_directory',required=False,help='The result directory for roslin run')
    parser.add_argument('--log_directory',required=False,help='Set the log directory')
    parser.add_argument('--output_directory',required=False,help='Output directory for analysis result')
    parser.add_argument('--sample_summary',required=False,help='The sample summary file generated from Roslin QC')
    parser.add_argument('--clinical_data',required=False,help='The clinical file located with Roslin manifests')
    parser.add_argument('--debug',action="store_true",required=False, help="Run the analysis helper in debug mode")
    args = parser.parse_args()
    script_path = os.path.dirname(os.path.realpath(__file__))
    current_working_directory = os.getcwd()
    log_directory = current_working_directory
    if args.log_directory:
        log_directory = parser.log_directory
    # handle duplicate logs
    log_file_path = os.path.join(log_directory,'roslin_analysis_helper.log')
    if os.path.exists(log_file_path):
        log_error_folder = os.path.join(log_directory,old_jobs_folder)
        if not os.path.exists(log_error_folder):
            os.mkdir(log_error_folder)
        archive_log = find_unique_name_in_dir(log_file_path,log_error_folder)
        log_failed = os.path.join(log_error_folder,archive_log)
        shutil.move(log_file_path,log_failed)
    logger.propagate = False
    log_file_handler = logging.FileHandler(log_file_path)
    log_stream_handler = logging.StreamHandler()
    if args.debug:
        logger.setLevel(logging.DEBUG)
        log_file_handler.setLevel(logging.DEBUG)
        log_stream_handler.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
        log_file_handler.setLevel(logging.INFO)
        log_stream_handler.setLevel(logging.INFO)
    log_formatter = logging.Formatter('%(asctime)s - %(message)s')
    log_file_handler.setFormatter(log_formatter)
    log_stream_handler.setFormatter(log_formatter)
    logger.addHandler(log_file_handler)
    logger.addHandler(log_stream_handler)

    if args.clinical_data and not args.sample_summary:
        logger.error("You need to specify the sample_summary when using clinical data")

    portal_config_data = get_meta_info(args.inputs)
    assay = portal_config_data['Assay']
    project_is_impact = check_if_impact(assay)
    clinical_data = None

    if args.clinical_data:
        with open(args.clinical_data, 'rb') as clinical_data_file:
            clinical_reader = csv.DictReader(clinical_data_file, dialect='excel-tab')
            clinical_data = list(clinical_reader)
    else:
        clinical_data = portal_config_data['clinical_data']

    logger.info('---------- Creating Portal files for project: '+portal_config_data['ProjectID'] + ' ----------')

    # Read the Sample Summary
    coverage_values = {}
    with open(args.sample_summary,'r') as input_file:
        header = input_file.readline().strip('\r\n').split('\t')
        coverage_position = header.index('Coverage')
        sample_position = header.index('Sample')
        csv_reader = csv.reader(input_file,delimiter='\t')
        for single_line in csv_reader:
            coverage_value = single_line[coverage_position]
            sample_value = single_line[sample_position]
            if coverage_value != '':
                if sample_value in coverage_values:
                    raise Exception("Duplicate coverages on sample " + sample_value + " of " + coverage_values[sample_value] + " and " + coverage_value)
                coverage_values[sample_value] = coverage_value

    stable_id = genPortalUUID.generateIGOBasedPortalUUID(portal_config_data['ProjectID'])[1]
    maf_file_name =  'data_mutations_extended.txt'
    fusion_file_name = 'data_fusions.txt'
    discrete_copy_number_file = 'data_CNA.txt'
    segmented_data_file = stable_id + '_data_cna_hg19.seg'
    clinical_data_file = 'data_clinical.txt'
    patient_data_file = 'data_patient.txt'
    discrete_copy_number_meta_file = 'meta_CNA.txt'
    segmented_data_meta_file = stable_id + '_meta_cna_hg19_seg.txt'
    study_meta_file = 'meta_study.txt'
    clinical_meta_file = 'meta_clinical.txt'
    patient_meta_file = 'meta_patient.txt'
    mutation_meta_file = 'meta_mutations_extended.txt'
    fusion_meta_file = 'meta_fusions.txt'
    clinical_meta_samples_file = 'meta_clinical_sample.txt'
    clinical_meta_patients_file = 'meta_clinical_patient.txt'
    clinical_data_samples_file = 'data_clinical_sample.txt'
    clinical_data_patients_file = 'data_clinical_patient.txt'
    portal_config_data['stable_id'] = stable_id

    # Set work directory space to tmp or a specified ouput path
    output_directory = None
    if not args.output_directory:
        output_directory = mkdtemp()
    else:
        output_directory = args.output_directory

    output_directory = os.path.abspath(output_directory)

    if os.path.exists(output_directory):
        logger.info('Removing output directory: ' + str(output_directory))
        shutil.rmtree(output_directory)
        os.makedirs(output_directory)

    analysis_dir = os.path.abspath(os.path.join(output_directory,'analysis'))
    if not os.path.exists(analysis_dir):
        os.makedirs(analysis_dir)
    analysis_mut_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.muts.maf')
    analysis_sv_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.svs.maf')
    analysis_gene_cna_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.gene.cna.txt')
    analysis_arm_cna_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.arm.cna.txt')
    analysis_seg_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.seg.cna.txt')

    if clinical_data:
        legacy_clinical_data = generate_legacy_clinical_data(clinical_data,coverage_values)
        # writing new format of data clinical files using legacy data in 'clinical_data_path'
        data_clinical_sample_txt, data_clinical_patient_txt = create_data_clinical_files_new_format(legacy_clinical_data)
        clinical_data_samples_output_path = os.path.join(output_directory, clinical_data_samples_file)
        clinical_data_patients_output_path = os.path.join(output_directory, clinical_data_patients_file)
        with open(clinical_data_samples_output_path, 'wb') as out:
            out.write(data_clinical_sample_txt)
        with open(clinical_data_patients_output_path, 'wb') as out:
            out.write(data_clinical_patient_txt)
        logger.info('Finished generating clinical data, including in the new format')
        logger.info('Removing legacy data_clinical.txt file.')
        sample_list = get_sample_list(clinical_data)
        generate_case_lists(portal_config_data,sample_list,output_directory)
        logger.info('Finished generating case lists')

    results_log_folder = os.path.join(args.results_directory,'log')
    version_str = None
    workflow_params_file_path = os.path.join(results_log_folder,"workflow_params.json")
    if os.path.exists(workflow_params_file_path):
        with open(workflow_params_file_path,'r') as workflow_params_file:
            workflow_params = json.load(workflow_params_file)
            version_str = workflow_params['version_str']
    else:
        logger.error("Could not find the submission file: "+submission_file_path)

    study_meta = generate_study_meta(portal_config_data,version_str)
    logger.info('Finished generating study meta')
    mutation_meta = generate_mutation_meta(portal_config_data,maf_file_name)
    logger.info('Finished generating mutation meta')
    discrete_copy_number_meta = generate_discrete_copy_number_meta(portal_config_data,discrete_copy_number_file)
    logger.info('Finished generating discrete copy number meta')
    segmented_data_meta = generate_segmented_meta(portal_config_data,segmented_data_file)
    logger.info('Finished generating segmented meta')

    logger.info('Submitting job to generate maf data')
    generate_maf_data(args.maf_directory,output_directory,maf_file_name,analysis_mut_file,log_directory,script_path,version_str,project_is_impact)
    logger.info('Submitting job to generate discrete copy number data')
    generate_discrete_copy_number_data(args.facets_directory,output_directory,discrete_copy_number_file,analysis_gene_cna_file,assay,log_directory)
    logger.info('Submitting job to generate segmented copy number data')
    generate_segmented_copy_number_data(args.facets_directory,output_directory,segmented_data_file,analysis_seg_file,log_directory)

    if clinical_data:
        clinical_meta_samples_path = os.path.join(output_directory, clinical_meta_samples_file)
        clinical_meta_patients_path = os.path.join(output_directory, clinical_meta_patients_file)

    study_meta_path = os.path.join(output_directory,study_meta_file)
    mutation_meta_path = os.path.join(output_directory,mutation_meta_file)

    discrete_copy_number_meta_path = os.path.join(output_directory,discrete_copy_number_meta_file)
    segmented_data_meta_path = os.path.join(output_directory,segmented_data_meta_file)

    logger.info('Writing meta files')

    with open(study_meta_path,'w') as study_meta_path_file:
        yaml.dump(study_meta,study_meta_path_file,default_flow_style=False,width=float("inf"))

    with open(mutation_meta_path,'w') as mutation_meta_path_file:
        yaml.dump(mutation_meta,mutation_meta_path_file,default_flow_style=False,width=float("inf"))

    if clinical_data:
        create_meta_clinical_files_new_format("SAMPLE_ATTRIBUTES", clinical_meta_samples_path, clinical_data_samples_file, stable_id)
        create_meta_clinical_files_new_format("PATIENT_ATTRIBUTES", clinical_meta_patients_path, clinical_data_patients_file, stable_id)

    with open(discrete_copy_number_meta_path,'w') as discrete_copy_number_meta_path_file:
        yaml.dump(discrete_copy_number_meta,discrete_copy_number_meta_path_file,default_flow_style=False,width=float("inf"))

    with open(segmented_data_meta_path,'w') as segmented_data_meta_path_file:
        yaml.dump(segmented_data_meta,segmented_data_meta_path_file,default_flow_style=False,width=float("inf"))

    if project_is_impact:
        fusion_meta = generate_fusion_meta(portal_config_data,fusion_file_name)
        logger.info('Finished generating fusion meta')
        logger.info('Submitting job to generate fusion data')
        generate_fusion_data(args.maf_directory,output_directory,fusion_file_name,log_directory,script_path)
        fusion_meta_path = os.path.join(output_directory,fusion_meta_file)
        logger.info('Writing fusion meta file')
        with open(fusion_meta_path,'w') as fusion_meta_path_file:
            yaml.dump(fusion_meta,fusion_meta_path_file,default_flow_style=False,width=float("inf"))