#!/usr/bin/env python

import argparse, os, sys, requests, yaml, json, subprocess, re, time, io, csv, shutil, logging
from tempfile import mkdtemp
from datetime import date
from distutils.dir_util import copy_tree
import genPortalUUID

logger = logging.getLogger("roslin_analysis_helper")
logger.setLevel(logging.INFO)
log_file_handler = logging.FileHandler('roslin_analysis_helper.log')
log_file_handler.setLevel(logging.INFO)
log_formatter = logging.Formatter('%(asctime)s - %(message)s')
log_file_handler.setFormatter(log_formatter)

logger.addHandler(log_file_handler)

def get_oncotree_info():
    oncotree = requests.get('http://oncotree.mskcc.org/oncotree/api/tumorTypes?flat=true&deprecated=false').json()
    oncotree_dict = {}
    for single_onco_info in oncotree['data']:
        oncotree_code = single_onco_info['code']
        oncotree_dict[oncotree_code] = single_onco_info
    return oncotree_dict

def generate_legacy_clinical_data(clinical_data_path,clinical_output_path,coverage_values):
    with open(clinical_data_path) as input_file, open(clinical_output_path,'w') as output_file:
        writer = csv.writer(output_file, lineterminator='\n',dialect='excel-tab')
        reader = csv.reader(input_file,dialect='excel-tab')
        clinical_data = []
        row = reader.next()
        row.append('SAMPLE_COVERAGE')
        clinical_data.append(row)
        for row in reader:
            coverage_value = coverage_values[row[0]]
            row.append(coverage_value)
            clinical_data.append(row)
        writer.writerows(clinical_data)

def get_sample_list(clinical_data_path):
    sample_list = []
    with open(clinical_data_path) as input_file:
        reader = csv.reader(input_file, dialect='excel-tab')
        for row in reader:
            sample_list.append(row[0])
    sample_list.pop(0)
    return sample_list

def generate_maf_data(maf_directory,output_directory,maf_file_name,analysis_maf_file,log_directory,script_path,pipeline_version_str,is_impact):
    maf_files_query = os.path.join(maf_directory,'*.muts.maf')
    combined_output = maf_file_name.replace('.txt','.combined.txt')
    combined_output_file = os.path.join(output_directory,combined_output)
    pipeline_version_str_arg = pipeline_version_str.replace(' ','_')
    portal_file = os.path.join(output_directory,maf_file_name)
    maf_log = os.path.join(log_directory,'generate_maf.log')
    regexp_string = "--regexp='^(Hugo|#)'"
    maf_filter_script = os.path.join(script_path,'maf_filter.py')

    maf_command = ('bsub -q controlR -We 0:59 -oo ' + maf_log + ' "grep -h --regexp=^Hugo ' + maf_files_query + ' | head -n1 > ' + combined_output_file
        + '; grep -hEv ' + regexp_string + ' ' + maf_files_query + ' >> ' + combined_output_file
        + '; python ' + ' '.join([maf_filter_script, combined_output_file, pipeline_version_str_arg, str(is_impact), analysis_maf_file, portal_file]) + '"')
    bsub_stdout = subprocess.check_output(maf_command,shell=True)
    return re.findall(r'Job <(\d+)>',bsub_stdout)[0]

def generate_fusion_data(fusion_directory,output_directory,data_filename,log_directory,script_path):
    fusion_files_query = os.path.join(fusion_directory,'*.svs.pass.vep.portal.txt')
    combined_output = data_filename.replace('.txt','.combined.txt')
    combined_output_path = os.path.join(output_directory,combined_output)
    output_path = os.path.join(output_directory,data_filename)
    fusion_log = os.path.join(log_directory,'generate_fusion.log')
    fusion_filter_script = os.path.join(script_path,'fusion_filter.py')

    # This needs access to the internet because it queries the OncoKB API
    fusion_command = ('bsub -R select[internet] -We 0:59 -oo ' + fusion_log + ' "grep -h --regexp=^Hugo ' + fusion_files_query + ' | head -n1 > ' + combined_output_path
        + '; grep -hv --regexp=^Hugo ' + fusion_files_query + ' >> ' + combined_output_path
        + '; python ' + fusion_filter_script + ' ' + combined_output_path + ' ' + output_path + '"')
    bsub_stdout = subprocess.check_output(fusion_command,shell=True)
    return re.findall(r'Job <(\d+)>',bsub_stdout)[0]

def generate_discrete_copy_number_data(data_directory,output_directory,data_filename,gene_cna_file,log_directory):
    discrete_copy_number_files_query = os.path.join(data_directory,'*_hisens.cncf.txt')
    output_path = os.path.join(output_directory,data_filename)
    discrete_copy_number_log = os.path.join(log_directory,'generate_discrete_copy_number.log')
    scna_output_path = output_path.replace('.txt','.scna.txt')

    cna_command = ('bsub -q controlR -We 0:59 -oo ' + discrete_copy_number_log + ' "cmo_facets --suite-version 1.5.6 geneLevel -f '
        + discrete_copy_number_files_query + ' -m scna -o ' + output_path + '; mv ' + output_path + ' ' + gene_cna_file
        + '; mv ' + scna_output_path + ' ' + output_path + '"')
    bsub_stdout = subprocess.check_output(cna_command,shell=True)
    return re.findall(r'Job <(\d+)>',bsub_stdout)[0]

def generate_segmented_copy_number_data(data_directory,output_directory,data_filename,analysis_seg_file,log_directory):
    segmented_files_query = os.path.join(data_directory,'*_hisens.seg')
    output_path = os.path.join(output_directory,data_filename)
    segmented_log = os.path.join(log_directory,'generate_segmented_copy_number.log')

    # ::TODO:: Using a weird awk here to reduce log-ratio significant digits. Do it in facets.
    seg_command = ('bsub -q controlR -We 0:59 -oo ' + segmented_log + ' "grep -h --regexp=^ID ' + segmented_files_query + ' | head -n1 > ' + output_path
        + '; grep -hv --regexp=^ID ' + segmented_files_query + ' | awk \'OFS=\\"\\t\\" {\$6=sprintf(\\"%.4f\\",\$6); print}\' >> ' + output_path
        + '; cp ' + output_path + ' ' + analysis_seg_file + '"')
    bsub_stdout = subprocess.check_output(seg_command,shell=True)
    return re.findall(r'Job <(\d+)>',bsub_stdout)[0]

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

# ::TODO:: Remove dependency on LSF somehow, possibly by just running everything baremetal
def wait_for_jobs_to_finish(bjob_ids,name):
    job_string = name + ' [' + ','.join(bjob_ids) + ']'
    logger.info("Monitoring " + job_string)
    bjob_command = "bjobs " + ' '.join(bjob_ids) + " | awk '{printf $3}'"
    prev_job_status = ''
    while True:
        job_status = subprocess.check_output(bjob_command,shell=True).strip()
        if 'PEND' in job_status:
            logger.info(name + " pending") if prev_job_status != job_status else None
            time.sleep(8)
        elif 'RUN' in job_status:
            logger.info(name + " running") if prev_job_status != job_status else None
            time.sleep(6)
        elif 'EXIT' in job_status:
            logger.warning(name + " exit with error")
            return 1
        elif 'DONE' in job_status:
            logger.info(name + " done")
            return 0
        else:
            logger.warning(name + " status unknown")
            return 2
        prev_job_status = job_status

def check_if_impact(request_file_path):
    is_impact = False
    with open(request_file_path) as request_file:
        for single_line in request_file:
            if "Assay:" in single_line and ("IMPACT" in single_line or "HemePACT" in single_line):
                is_impact = True
    return is_impact

def create_meta_clinical_files_new_format(datatype, filepath, filename, study_id):
    with open(filepath, 'wb') as output_file:
        output_file.write('cancer_study_identifier: %s\n' % study_id)
        output_file.write('genetic_alteration_type: CLINICAL\n')
        output_file.write('datatype: %s\n' % datatype)
        output_file.write('data_filename: %s\n' % filename)

def create_data_clinical_files_new_format(data_clinical_file):
    samples_file_txt = ""
    patients_file_txt = ""

    with open(data_clinical_file, 'rb') as f:
        reader = csv.DictReader(f, delimiter='\t')
        data = list(reader)
        header = data[0].keys()
        samples_header = get_samples_header(header)
        patients_header = get_patients_header(header)
        data_attr = set_attributes(header)
        samples_file_txt = generate_file_txt(data, data_attr, samples_header)
        patients_file_txt = generate_patient_file_txt(data, data_attr, patients_header)

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

if __name__ == '__main__':
    parser = argparse.ArgumentParser(add_help= True, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--clinical_data',required=True,help='The clinical file located with Roslin manifests')
    parser.add_argument('--sample_summary',required=True,help='The sample summary file generated from Roslin QC')
    parser.add_argument('--request_file',required=True, help='The request file for the roslin run')
    parser.add_argument('--roslin_output',required=True, help='The stdout of the roslin run')
    parser.add_argument('--maf_directory',required=True,help='The directory containing the maf files')
    parser.add_argument('--facets_directory',required=True,help='The directory containing the facets files')
    parser.add_argument('--output_directory',required=False,help='Set the output directory for portal files')
    parser.add_argument('--script_path',required=True,help='Path for the portal helper scripts')
    parser.add_argument('--disable_portal_repo_update', default=False, action='store_true', help='If not updating cbioportal, skips submitting request to update the Mercurial repo.')
    args = parser.parse_args()
    current_working_directory = os.getcwd()
    roslin_resources_path = os.path.join(args.script_path,'roslin_resources.json')
    with open(roslin_resources_path) as roslin_resources_json:
        roslin_resources_data = json.load(roslin_resources_json)
    mercurial_path = None
    if "portal" in roslin_resources_data["config"]:
        importer_path = roslin_resources_data["config"]["portal"]["importer"]
        mercurial_path = roslin_resources_data["config"]["portal"]["path"]
        sys.path.append(importer_path)
        import validateData
    else:
        logger.warning("Portal validator/repo configuration not set in roslin_resources.json")
    project_is_impact = check_if_impact(args.request_file)
    # Get roslin config
    with open(args.request_file,'r') as portal_config_file:
        portal_config_data = {}
        single_value = ''
        single_key = ''
        for single_line in portal_config_file:
            stripped_single_line = single_line.strip("\n\r")
            split_stripped_single_line = stripped_single_line.split(':')
            if ':' in single_line:
                if single_key:
                    portal_config_data[single_key] = single_value
                    single_key = None
                single_key = split_stripped_single_line[0]
                single_value = split_stripped_single_line[1].strip()
            else:
                single_value = single_value + stripped_single_line
            #if stripped_single_line.contains(':'):
                #new_value = single_value.replace('"','')
                #portal_config_data[single_key] = new_value
                #single_value = ''
                #single_key = ''
        portal_config_data[single_key] = single_value
    log_directory = os.path.join(os.getcwd(),'analysis-log',portal_config_data['ProjectID'])
    if os.path.exists(log_directory):
        shutil.rmtree(log_directory)
    os.makedirs(log_directory)
    #os.chdir(log_directory)

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

    analysis_dir = os.path.abspath(os.path.join(output_directory,os.pardir,'analysis'))
    if not os.path.exists(analysis_dir):
        os.makedirs(analysis_dir)
    analysis_maf_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.muts.maf')
    analysis_gene_cna_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.gene.cna.txt')
    analysis_arm_cna_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.arm.cna.txt')
    analysis_seg_file = os.path.join(analysis_dir, portal_config_data['ProjectID'] + '.seg.cna.txt')

    clinical_data_path = os.path.join(output_directory,clinical_data_file)
    generate_legacy_clinical_data(args.clinical_data,clinical_data_path,coverage_values)
    # writing new format of data clinical files using legacy data in 'clinical_data_path'
    data_clinical_sample_txt, data_clinical_patient_txt = create_data_clinical_files_new_format(clinical_data_path)
    clinical_data_samples_output_path = os.path.join(output_directory, clinical_data_samples_file)
    clinical_data_patients_output_path = os.path.join(output_directory, clinical_data_patients_file)
    with open(clinical_data_samples_output_path, 'wb') as out:
        out.write(data_clinical_sample_txt)
    with open(clinical_data_patients_output_path, 'wb') as out:
        out.write(data_clinical_patient_txt)
    logger.info('Finished generating clinical data, including in the new format')
    logger.info('Removing legacy data_clinical.txt file.')
    os.remove(clinical_data_path)

    sample_list = get_sample_list(args.clinical_data)
    generate_case_lists(portal_config_data,sample_list,output_directory)
    logger.info('Finished generating case lists')

    # Extract the roslin version from the stdout log file
    with open(args.roslin_output) as roslin_output_file:
        roslin_output_file.readline()
        roslin_output_file.readline()
        version_str = re.findall(r'^VERSIONS: (.*)$',roslin_output_file.readline())[0].rstrip('\r\n')

    study_meta = generate_study_meta(portal_config_data,version_str)
    logger.info('Finished generating study meta')
    mutation_meta = generate_mutation_meta(portal_config_data,maf_file_name)
    logger.info('Finished generating mutation meta')
    discrete_copy_number_meta = generate_discrete_copy_number_meta(portal_config_data,discrete_copy_number_file)
    logger.info('Finished generating discrete copy number meta')
    segmented_data_meta = generate_segmented_meta(portal_config_data,segmented_data_file)
    logger.info('Finished generating segmented meta')

    job_ids = []
    job_ids.append(generate_maf_data(args.maf_directory,output_directory,maf_file_name,analysis_maf_file,log_directory,args.script_path,version_str,project_is_impact))
    logger.info('Submitted job to generate maf data')
    job_ids.append(generate_discrete_copy_number_data(args.facets_directory,output_directory,discrete_copy_number_file,analysis_gene_cna_file,log_directory))
    logger.info('Submitted job to generate discrete copy number data')
    job_ids.append(generate_segmented_copy_number_data(args.facets_directory,output_directory,segmented_data_file,analysis_seg_file,log_directory))
    logger.info('Submitted job to generate segmented copy number data')

    study_meta_path = os.path.join(output_directory,study_meta_file)
    clinical_meta_samples_path = os.path.join(output_directory, clinical_meta_samples_file)
    clinical_meta_patients_path = os.path.join(output_directory, clinical_meta_patients_file)
    mutation_meta_path = os.path.join(output_directory,mutation_meta_file)

    discrete_copy_number_meta_path = os.path.join(output_directory,discrete_copy_number_meta_file)
    segmented_data_meta_path = os.path.join(output_directory,segmented_data_meta_file)

    logger.info('Writing meta files')

    with open(study_meta_path,'w') as study_meta_path_file:
        yaml.dump(study_meta,study_meta_path_file,default_flow_style=False,width=float("inf"))

    with open(mutation_meta_path,'w') as mutation_meta_path_file:
        yaml.dump(mutation_meta,mutation_meta_path_file,default_flow_style=False,width=float("inf"))

    create_meta_clinical_files_new_format("SAMPLE_ATTRIBUTES", clinical_meta_samples_path, clinical_data_samples_file, stable_id)
    create_meta_clinical_files_new_format("PATIENT_ATTRIBUTES", clinical_meta_patients_path, clinical_data_patients_file, stable_id)

    with open(discrete_copy_number_meta_path,'w') as discrete_copy_number_meta_path_file:
        yaml.dump(discrete_copy_number_meta,discrete_copy_number_meta_path_file,default_flow_style=False,width=float("inf"))

    with open(segmented_data_meta_path,'w') as segmented_data_meta_path_file:
        yaml.dump(segmented_data_meta,segmented_data_meta_path_file,default_flow_style=False,width=float("inf"))

    if project_is_impact:
        fusion_meta = generate_fusion_meta(portal_config_data,fusion_file_name)
        logger.info('Finished generating fusion meta')
        job_ids.append(generate_fusion_data(args.maf_directory,output_directory,fusion_file_name,log_directory,args.script_path))
        logger.info('Submitted job to generate fusion data')
        fusion_meta_path = os.path.join(output_directory,fusion_meta_file)
        logger.info('Writing fusion meta file')
        with open(fusion_meta_path,'w') as fusion_meta_path_file:
            yaml.dump(fusion_meta,fusion_meta_path_file,default_flow_style=False,width=float("inf"))

    # Now wait for any of the jobs submitted earlier to complete
    if wait_for_jobs_to_finish(job_ids, 'Data generation jobs') != 0:
        logger.error('One or more of the analysis/portal jobs failed.')
        sys.exit(1)

    try:
        validation_exit_status = validate_portal_data(output_directory)
        logger.info("Portal validator exit status: %i" % validation_exit_status)
        if validation_exit_status == 0 or validation_exit_status == 3:
            logger.info('Portal files are valid for upload.')
            if args.disable_portal_repo_update:
                logger.info("Skipping update of portal files in mercurial repo")
            else:
                project_id = portal_config_data['ProjectID']
                copy_to_location = make_dirs_from_stable_id(mercurial_path, stable_id, project_id)
                copy_tree(output_directory, copy_to_location)
                logger.info("Copied portal files to %s" % copy_to_location)
        else:
            logger.error('Portal files are invalid; they will not be uploaded.')
            sys.exit(2)
    finally:
        logging.shutdown()
        del logging._handlerList[:]  # workaround for harmless exceptions on exit
