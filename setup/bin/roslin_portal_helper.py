import argparse, os, sys
from xlrd import open_workbook
import requests
import yaml
import tempfile
import json
import imp
import subprocess
import re
import time
import io
import genPortalUUID
import csv
import shutil
import glob
import logging

# create logger
logger = logging.getLogger("roslin_portal_helper")
logger.setLevel(logging.INFO)
# create logging file handler
log_file_handler = logging.FileHandler('roslin_portal_helper.log')
log_file_handler.setLevel(logging.INFO)
# create a logging format
log_formatter = logging.Formatter('%(asctime)s - %(message)s')
log_file_handler.setFormatter(log_formatter)
# add the handlers to the logger
logger.addHandler(log_file_handler)

def get_oncotree_info():
	oncotree = requests.get('http://oncotree.mskcc.org/oncotree/api/tumorTypes?flat=true&deprecated=false').json()
	oncotree_dict = {}
	for single_onco_info in oncotree['data']:
		oncotree_code = single_onco_info['code']
		oncotree_dict[oncotree_code] = single_onco_info
	return oncotree_dict

def generate_clinical_data(clinical_data_path,clinical_output_path,coverage_values):
	clinical_data = []
	clinical_data_file_body = ''
	clinical_data_file_header = '#SAMPLE_ID\tPATIENT_ID\tCOLLAB_ID\tSAMPLE_TYPE\tGENE_PANEL\tONCOTREE_CODE\tSAMPLE_CLASS\tSPECIMEN_PRESERVATION_TYPE\tTISSUE_SITE\tSAMPLE_COVERAGE\n#SAMPLE_ID\tPATIENT_ID\tCOLLAB_ID\tSAMPLE_TYPE\tGENE_PANEL\tONCOTREE_CODE\tSAMPLE_CLASS\tSPECIMEN_PRESERVATION_TYPE\tTISSUE_SITE\tSAMPLE COVERAGE\n#STRING\tSTRING\tSTRING\tSTRING\tSTRING\tSTRING\tSTRING\tSTRING\tSTRING\tNUMBER\n#1\t1\t1\t1\t1\t1\t1\t1\t1\t1\n'
	patient_data_file_body = ''
	patient_data_file_header = '#PATIENT_ID\tSEX\n#PATIENT_ID\tSEX\n#STRING\tSTRING\n#1\t1\n'
	sample_list = []
	patient_header_line = []
	patient_header = ''
	patient_data_dict = {}
	with open(clinical_data_path,'r') as input_file:
		header_line = input_file.readline().rstrip('\r\n').split('\t')
		sex_index = header_line.index('SEX')
		patient_id_index = header_line.index('PATIENT_ID')
		patient_header_value = header_line[patient_id_index]
		sex_header_value = header_line.pop(sex_index)
		patient_header_line.append(patient_header_value)
		patient_header_line.append(sex_header_value)
		header = '\t'.join(header_line)
		patient_header = '\t'.join(patient_header_line)
		for single_line in input_file:
			single_row_list = single_line.rstrip('\r\n').split('\t')
			patient_id_value = single_row_list[patient_id_index]
			sex_value = single_row_list.pop(sex_index)
			patient_data_dict[patient_id_value] = sex_value
			single_row = '\t'.join(single_row_list)
			clinical_data.append(single_row)
	clinical_data_file_header = clinical_data_file_header + header + '\tSAMPLE COVERAGE'
	patient_data_file_header = patient_data_file_header + patient_header
	for single_row in clinical_data:
		single_row_items = single_row.split('\t')
		sample_id_value = single_row_items[0]
		sample_list.append(sample_id_value)
		sample_coverage_value = coverage_values[sample_id_value]
		clinical_data_file_body = clinical_data_file_body + single_row+'\t'+sample_coverage_value+'\n'
	for single_patient in patient_data_dict:
		single_patient_row = single_patient+'\t'+patient_data_dict[single_patient]+'\n'
		patient_data_file_body = patient_data_file_body + single_patient_row
	clinical_data_file = clinical_data_file_header + '\n' + clinical_data_file_body
	patient_data_file = patient_data_file_header + '\n' + patient_data_file_body
	return {'patient_data_file':patient_data_file,'clinical_data_file':clinical_data_file,'sample_list':sample_list}

def generate_legacy_clinical_data(clinical_data_path,clinical_output_path,coverage_values,msi_scores):
	with open(clinical_data_path) as input_file, open(clinical_output_path,'w') as output_file:
		writer = csv.writer(output_file, lineterminator='\n',dialect='excel-tab')
		reader = csv.reader(input_file,dialect='excel-tab')
		clinical_data = []
		row = reader.next()
		row.append('SAMPLE_COVERAGE')
		row.append('MSI_SCORE')
		clinical_data.append(row)
		for row in reader:
			print row
			coverage_value = coverage_values[row[0]]
			msi_score = msi_scores[row[0]]
			row.append(coverage_value)
			row.append(msi_score)
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

def generate_maf_data(maf_directory,output_directory,maf_file_name,log_directory,script_path,pipeline_version_str):
	maf_files_query_all = glob.glob(os.path.join(maf_directory,'*.maf'))
	pipeline_version_str_arg = pipeline_version_str.replace(" ","_")
	maf_files_query_list = [ single_maf for single_maf in maf_files_query_all if ".vep." not in single_maf]
	maf_files_query = ' '.join(maf_files_query_list)
	combined_output = maf_file_name.replace('.txt','.combined.txt')
	output_path = os.path.join(output_directory,maf_file_name)
	combined_output_path = os.path.join(output_directory,combined_output)
	maf_header_err_log = os.path.join(log_directory,'maf_header_err.txt')
	maf_err_log = os.path.join(log_directory,'maf_err.txt')
	float_to_int_err_log = os.path.join(log_directory,'float_to_int_err.txt')
	regexp_string = "--regexp='^(Hugo|#)'"
	portal_float_to_int_script_path = os.path.join(script_path,'Roslin_Portal_Float_To_Int.py')

	retrieve_header_command = 'bsub -e '+maf_header_err_log+' "grep -h --regexp=^Hugo '+ maf_files_query + ' | head -n1 > ' + combined_output_path + '"'
	retrieve_data_command = 'bsub -e '+maf_err_log+' "grep -hEv '+ regexp_string + ' ' + maf_files_query + ' >> ' + combined_output_path + '"'
	convert_float_to_int_command = 'bsub -e '+float_to_int_err_log+' "python '+portal_float_to_int_script_path+' '+combined_output_path + ' ' + pipeline_version_str_arg + '"'

	maf_header_stdout = subprocess.check_output(retrieve_header_command,shell=True)
	header_command_id = re.findall("(\d{8})",maf_header_stdout)[0]
	wait_for_job_to_finish(header_command_id,'maf header copy')
	maf_data_stdout = subprocess.check_output(retrieve_data_command,shell=True)
	retrieve_data_command_id = re.findall("(\d{8})",maf_data_stdout)[0]
	wait_for_job_to_finish(retrieve_data_command_id,'maf data copy')
	convert_float_stdout = subprocess.check_output(convert_float_to_int_command,shell=True)
	convert_float_command_id = re.findall("(\d{8})",convert_float_stdout)[0]
	wait_for_job_to_finish(convert_float_command_id,'float conversion')

def generate_fusion_data(fusion_directory,output_directory,data_filename,log_directory,script_path):
	fusion_files_query = os.path.join(fusion_directory,'*.vep.portal.txt')
	combined_output = data_filename.replace('.txt','.combined.txt')
	output_path = os.path.join(output_directory,data_filename)
	combined_output_path = os.path.join(output_directory,combined_output)
	fusion_header_err_log = os.path.join(log_directory,'fusion_header_err.txt')
	fusion_err_log = os.path.join(log_directory,'fusion_err.txt')
	fusion_filter_err_log = os.path.join(log_directory,'fusion_filter_err.txt')
	fusion_filter_out_log = os.path.join(log_directory,'fusion_filter_out.txt')
	fussion_script_path = os.path.join(script_path,'fusion_filter.py')
	#create_file_command = 'touch '+output_path
	retrieve_header_command = 'bsub -e '+fusion_header_err_log+' "grep -h --regexp=^Hugo '+ fusion_files_query + ' | head -n1 > ' + combined_output_path + '"'
	retrieve_data_command = 'bsub -e '+fusion_err_log+' "grep -hEv --regexp=^Hugo '+ fusion_files_query + ' >> ' + combined_output_path + '"'
	filter_columns_command = 'bsub -e '+fusion_filter_err_log+' -o '+fusion_filter_out_log+' "python '+fussion_script_path+' '+combined_output_path + '"'
	fusion_header_stdout = subprocess.check_output(retrieve_header_command,shell=True)
	header_command_id = re.findall("(\d{8})",fusion_header_stdout)[0]
	wait_for_job_to_finish(header_command_id,'fusion header copy')
	fusion_data_stdout = subprocess.check_output(retrieve_data_command,shell=True)
	retrieve_data_command_id = re.findall("(\d{8})",fusion_data_stdout)[0]
	wait_for_job_to_finish(retrieve_data_command_id,'fusion data copy')
	fusion_filter_stdout = subprocess.check_output(filter_columns_command,shell=True)
	fusion_filter_command_id = re.findall("(\d{8})",fusion_filter_stdout)[0]
	wait_for_job_to_finish(fusion_filter_command_id,'fusion filter')

def generate_discrete_copy_number_data(data_directory,output_directory,data_filename,log_directory):
	discrete_copy_number_files_query = os.path.join(data_directory,'*_hisens.cncf.txt')
	combined_output = data_filename
	second_output = data_filename.replace('.txt','.scna.txt')
	output_path = os.path.join(output_directory,data_filename)
	combined_output_path = os.path.join(output_directory,combined_output)
	second_output_path = os.path.join(output_directory,second_output)
	discrete_copy_number_err_log = os.path.join(log_directory,'discrete_copy_number_err.txt')
	combine_data_command = 'bsub -e '+discrete_copy_number_err_log+' "cmo_facets --suite-version 1.5.6 geneLevel -f '+discrete_copy_number_files_query+' -m scna -o '+combined_output_path+'"'
	discrete_copy_number_data_stdout = subprocess.check_output(combine_data_command,shell=True)
	combine_data_command_id = re.findall("(\d{8})",discrete_copy_number_data_stdout)[0]
	wait_for_job_to_finish(combine_data_command_id,'Discrete Copy Number Data copy')
	os.remove(combined_output_path)
	os.rename(second_output_path,combined_output_path)


def generate_segmented_data(data_directory,output_directory,data_filename,log_directory):
	segmented_files_query = os.path.join(data_directory,'*_hisens.seg')
	combined_output = data_filename
	output_path = os.path.join(output_directory,data_filename)
	combined_output_path = os.path.join(output_directory,combined_output)
	segmented_header_err_log = os.path.join(log_directory,'segmented_header_err.txt')
	segmented_err_log = os.path.join(log_directory,'segmented_err.txt')
	retrieve_header_command = 'bsub -e '+segmented_header_err_log+' "grep -h --regexp=^ID '+ segmented_files_query + ' | head -n1 > ' + combined_output_path + '"'
	retrieve_data_command = 'bsub -e '+segmented_err_log+' "grep -hEv --regexp=^ID '+ segmented_files_query + ' >> ' + combined_output_path + '"'
	segmented_header_stdout = subprocess.check_output(retrieve_header_command,shell=True)
	header_command_id = re.findall("(\d{8})",segmented_header_stdout)[0]
	wait_for_job_to_finish(header_command_id,'segmented header copy')
	segmented_data_stdout = subprocess.check_output(retrieve_data_command,shell=True)
	retrieve_data_command_id = re.findall("(\d{8})",segmented_data_stdout)[0]
	wait_for_job_to_finish(retrieve_data_command_id,'segmented data copy')

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
	study_name = portal_config_data['ProjectTitle'] + ' ('+portal_config_data['ProjectID']+' '+pipeline_version_str+') '
	study_meta_data['type_of_cancer'] = portal_config_data['TumorType'].lower()
	study_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
	study_meta_data['name'] = study_name
	study_meta_data['short_name'] =  portal_config_data['ProjectID'] 
	study_meta_data['description'] = portal_config_data['ProjectDesc'].replace('\n', '')
	study_meta_data['groups'] = 'PRISM'
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

def generate_clinical_meta(portal_config_data, clinical_file_name):
	clinical_meta_data = {}
	clinical_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
	clinical_meta_data['genetic_alteration_type'] = 'CLINICAL'
	clinical_meta_data['datatype'] ='SAMPLE_ATTRIBUTES'
	clinical_meta_data['data_filename'] = clinical_file_name
	return clinical_meta_data

def generate_patient_meta(portal_config_data, patient_file_name):
	patient_meta_data = {}
	patient_meta_data['cancer_study_identifier'] = portal_config_data['stable_id']
	patient_meta_data['genetic_alteration_type'] = 'CLINICAL'
	patient_meta_data['datatype'] ='PATIENT_ATTRIBUTES'
	patient_meta_data['data_filename'] = patient_file_name
	return patient_meta_data

def wait_for_job_to_finish(bjob_id,name):
	job_string = name+' [' + bjob_id+']'
	logger.info("Monitoring "+job_string)
	bjob_command = "bjobs " + bjob_id + " | awk '{print $3}' | tail -1"
	# job_done = False  #ts
	job_done = True
	while not job_done:
		job_status = subprocess.check_output(bjob_command,shell=True).strip()
		logger.info("Status: "+job_status)
		status_string = ""
		if job_status == "DONE":
			job_done = True
			status_string = name + " is done"
		elif job_status == "PEND":
			status_string = name + " is pending"
		elif job_status == "RUN":
			status_string = name + " is running"
		elif job_status == 'EXIT':
			job_done = True
			status_string = name + " has exited"
		logger.info(status_string)
		time.sleep(10)

def check_if_IMPACT(request_file_path):
	Is_it_IMPACT = False
	with open(request_file_path) as request_file:
		for single_line in request_file:
			if "Assay:" in single_line and ("IMPACT" in single_line or "HemePACT" in single_line):
				Is_it_IMPACT = True
	return Is_it_IMPACT

if __name__ == '__main__':
	parser = argparse.ArgumentParser(add_help= True, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument('--clinical_data',required=True,help='The clinical file located with Roslin manifests')
	parser.add_argument('--sample_summary',required=True,help='The sample summary file generated from Roslin QC')
	parser.add_argument('--request_file',required=True, help='The request file for the roslin run')
	#parser.add_argument('--column_info',required=True,help='The yaml configuration file containing portal column information')
	parser.add_argument('--roslin_output',required=True, help='The stdout of the roslin run')
	#parser.add_argument('--portal_config',required=True,help='The roslin portal config file')
	parser.add_argument('--maf_directory',required=True,help='The directory containing the maf files')
	parser.add_argument('--facets_directory',required=True,help='The directory containing the facets files')
	parser.add_argument('--msi_directory',required=True,help='The directory containing files for msi files (will be inside analysis/msi/)')
	parser.add_argument('--output_directory',required=False,help='Set the ouput directory for portal files')
	parser.add_argument('--script_path',required=True,help='Path for the portal helper scripts')
	args = parser.parse_args()
	current_working_directory = os.getcwd()
	#args_abspath = {}
	#for single_arg in args:
	#	args_abspath[single_arg] = os.path.abspath(args[single_arg])
	project_id = ''
	#work_book = open_workbook(args.manifest_file)
	#sample_info = work_book.sheet_by_name('SampleInfo')
	Is_Project_IMPACT = check_if_IMPACT(args.request_file)

	# Read yaml portal config file
	#with open(args.column_info,'r') as column_info_file:
	#	column_info_data = yaml.load(column_info_file)

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
	log_directory = os.path.join(os.getcwd(),'portal-log',portal_config_data['ProjectID'])
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
	#	with io.StringIO(unicode(roslin_config_file_data,"utf-8")) as fixed_roslin_config_file:
	#		roslin_config_data = imp.load_source('data','roslin_config_data',fixed_roslin_config_file)

	# Read in msi scores
	msi_scores = {}
	for infile in glob.glob(os.path.join(args.msi_directory, '*.msi.txt')):
		rootname = infile.split('/')[-1].split('.')[0]
		with open(infile, 'r') as input_file:
			header = input_file.readline().strip('\r\n').split('\t')
			msiscore_position = header.index('%')
			csv_reader = csv.reader(input_file,delimiter='\t')
			for line in csv_reader:
				if msi_scores.has_key(rootname):
					pass
				else:
					msi_scores[rootname] = line[msiscore_position]

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
	portal_config_data['stable_id'] = stable_id

	# Set work directory space to tmp or a specified ouput path
	output_directory = None
	if not args.output_directory:
		output_directory = tempfile.mkdtemp()
	else:
		output_directory = args.output_directory

	clinical_data_path = os.path.join(output_directory,clinical_data_file)
	#clinical_data_dict = generate_clinical_data(args.clinical_data,clinical_data_path,coverage_values)
	#clinical_data = clinical_data_dict['clinical_data_file']
	#patient_data = clinical_data_dict['patient_data_file']
	#sample_list = clinical_data_dict['sample_list']
	generate_legacy_clinical_data(args.clinical_data,clinical_data_path,coverage_values,msi_scores)
	logger.info('Finished generating clinical data')
	sample_list = get_sample_list(args.clinical_data)
	generate_case_lists(portal_config_data,sample_list,output_directory)
	logger.info('Finished generating case lists')

	#with open(clinical_data_path,'w') as clinical_data_path_file:
	#	clinical_data_path_file.write(clinical_data)

	#clinical_config_data = column_info_data['Clinical']
	#patient_config_data = column_info_data['Patient']
	# Generate our files
	with open(args.roslin_output) as roslin_output_file:
		roslin_output_file.readline()
		roslin_output_file.readline()
		version_str = roslin_output_file.readline().rstrip('\r\n')

	study_meta = generate_study_meta(portal_config_data,version_str)
	logger.info('Finished generating study meta')
	mutation_meta = generate_mutation_meta(portal_config_data,maf_file_name)
	logger.info('Finished generating mutation meta')
	discrete_copy_number_meta = generate_discrete_copy_number_meta(portal_config_data,discrete_copy_number_file)
	logger.info('Finished generating discrete copy number meta')
	segmented_data_meta = generate_segmented_meta(portal_config_data,segmented_data_file)
	logger.info('Finished generating segmented meta')

	#clinical_meta = generate_clinical_meta(portal_config_data,clinical_data_file)
	#clinical_data = generate_clinical_data(sample_info,clinical_config_data)
	#patient_meta = generate_patient_meta(portal_config_data,patient_data_file)
	#patient_data = generate_patient_data(sample_info,patient_config_data)
	generate_maf_data(args.maf_directory,output_directory,maf_file_name,log_directory,args.script_path,version_str)
	logger.info('Finished generating maf data')
	generate_discrete_copy_number_data(args.facets_directory,output_directory,discrete_copy_number_file,log_directory)
	logger.info('Finished generating discrete copy number data')
	generate_segmented_data(args.facets_directory,output_directory,segmented_data_file,log_directory)
	logger.info('Finished generating segmented data')

	study_meta_path = os.path.join(output_directory,study_meta_file)
	#clinical_meta_path = os.path.join(output_directory,clinical_meta_file)
	mutation_meta_path = os.path.join(output_directory,mutation_meta_file)

	discrete_copy_number_meta_path = os.path.join(output_directory,discrete_copy_number_meta_file)
	segmented_data_meta_path = os.path.join(output_directory,segmented_data_meta_file)
	#clinical_data_path = os.path.join(output_directory,clinical_data_file)
	patient_meta_path = os.path.join(output_directory,patient_meta_file)
	patient_data_path = os.path.join(output_directory,patient_data_file)

	logger.info('Writing meta files')

	with open(study_meta_path,'w') as study_meta_path_file:
		yaml.dump(study_meta,study_meta_path_file,default_flow_style=False, width=float("inf"))

	with open(mutation_meta_path,'w') as mutation_meta_path_file:
		yaml.dump(mutation_meta,mutation_meta_path_file,default_flow_style=False, width=float("inf"))

	#with open(clinical_meta_path,'w') as clinical_meta_path_file:
	#	yaml.dump(clinical_meta,clinical_meta_path_file,default_flow_style=False, width=float("inf"))

	#with open(patient_meta_path,'w') as patient_meta_path_file:
	#	yaml.dump(patient_meta,patient_meta_path_file,default_flow_style=False, width=float("inf"))

	with open(discrete_copy_number_meta_path,'w') as discrete_copy_number_meta_path_file:
		yaml.dump(discrete_copy_number_meta,discrete_copy_number_meta_path_file,default_flow_style=False, width=float("inf"))

	with open(segmented_data_meta_path,'w') as segmented_data_meta_path_file:
		yaml.dump(segmented_data_meta,segmented_data_meta_path_file,default_flow_style=False, width=float("inf"))

	if Is_Project_IMPACT:
		fusion_meta = generate_fusion_meta(portal_config_data,fusion_file_name)
		logger.info('Finished generating fusion meta')
		generate_fusion_data(args.maf_directory,output_directory,fusion_file_name,log_directory,args.script_path)
		logger.info('Finished generating fusion data')
		fusion_meta_path = os.path.join(output_directory,fusion_meta_file)
		logger.info('Writing fusion meta')
		with open(fusion_meta_path,'w') as fusion_meta_path_file:
			yaml.dump(fusion_meta,fusion_meta_path_file,default_flow_style=False, width=float("inf"))
	#os.chdir(current_working_directory)

#	with open(patient_data_path,'w') as patient_data_path_file:
#		patient_data_path_file.write(patient_data)

