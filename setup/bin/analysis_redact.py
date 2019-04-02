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
import copy
import logging

logger = logging.getLogger("analysis_redact")
logger.setLevel(logging.INFO)
log_file_handler = logging.FileHandler('analysis_redact.log')
log_file_handler.setLevel(logging.INFO)
log_formatter = logging.Formatter('%(asctime)s - %(message)s')
log_file_handler.setFormatter(log_formatter)

logger.addHandler(log_file_handler)

def log_removal(element_id):
	logger.info('REMOVING: '+ element_id)

def log_modify(element_id):
	logger.info('MODIFYING: ' +element_id)

def process_request_file(reader,redact_config):
	num_samples_to_remove = len(redact_config)
	redact_data = ''
	for single_line in reader:
		if 'NumberOfSamples' in single_line:
			line_elements = single_line.strip('\r\n').split(' ')
			numberOfSamples = int(line_elements[1])
			modiedNumberOfSamples = numberOfSamples - num_samples_to_remove
			redact_data = redact_data + line_elements[0] + " " + str(modiedNumberOfSamples) + '\n'
			log_modify('NumberOfSamples '+line_elements[1])
		else:
			redact_data = redact_data + single_line
	return redact_data

def process_combine_request_file(reader_file1,reader_file2):
	file_data = ''
	for single_line in reader_file2:
		if 'NumberOfSamples' in single_line:
			line_elements = single_line.strip('\r\n').split(' ')
			numberOfSamples = int(line_elements[1])
	for single_line in reader_file1:
		if 'NumberOfSamples' in single_line:
			line_elements = single_line.strip('\r\n').split(' ')
			numberOfSamples = numberOfSamples + int(line_elements[1])
			file_data = file_data + line_elements[0] + " " + str(numberOfSamples) + '\n'
		else:
			file_data = file_data + single_line
	return file_data

def process_pairing_file(reader,redact_config):
	samples_to_remove = redact_config
	redact_data = ''
	for single_line in reader:
		line_elements = single_line.strip('\r\n').split('\t')
		new_line = []
		if line_elements[0] in samples_to_remove or line_elements[1] in samples_to_remove:
			log_removal('Pair ' + '\t'.join(line_elements))
			continue		
		redact_data = redact_data + single_line
	return redact_data

def process_combine_file(reader_file1,reader_file2):
	file_data = ''
	for single_line in reader_file1:
		file_data = file_data + single_line
	for single_line in reader_file2:
		file_data = file_data + single_line
	return file_data

def process_combine_file_headers(reader_file1,reader_file2,number_of_header_rows):
	current_row = 0
	while current_row < number_of_header_rows:
		reader_file2.next()
		current_row = current_row + 1
	combined_file_data = process_combine_file(reader_file1,reader_file2)
	return combined_file_data

def process_csv_file(csv_reader,redact_config,headers):	
	redacted_data = ''
	row_index = 0
	for single_row in csv_reader:
		for single_redact in redact_config:
			skip_row = True
			for single_key in single_redact:
				key_position = headers.index(single_key)
				if single_row[key_position] != single_redact[single_key]:
					skip_row = False
					break
			if skip_row == True and len(single_redact) != 0:
				log_removal('Row ' +str(row_index))
				break				
		if not skip_row:
			redacted_data = redacted_data + '\t'.join(single_row) + '\n'
		row_index = row_index + 1
	return redacted_data

def process_table_file(csv_reader,redact_config):
	redacted_data = ''
	redact_column = []
	redact_row = []
	redact_modify = []
	headers = csv_reader.next()
	original_headers = copy.copy(headers)	
	for single_redact in redact_config:
		if len(single_redact) == 1:
			if 'column' in single_redact:
				single_redact_col = single_redact['column']
				if single_redact_col in original_headers:
					redact_column.append(original_headers.index(single_redact_col))
			elif 'row' in single_redact:
				redact_row.append(single_redact['row'])
		else:
			redact_modify.append(single_redact)
	for single_col in redact_column:
		headers[single_col] = ''
		log_removal('Col '+ str(single_col))
	redacted_data = '\t'.join(headers) + '\n'
	for single_row in csv_reader:
		rowId = single_row[0]
		if rowId in redact_row:
			log_removal('Row '+ str(rowId))
			continue
		for single_redact in redact_modify:
			single_redact_row = single_redact['row']
			single_redact_col = single_redact['column']
			redact_replacement = single_redact['replaceWith']			
			if rowId == single_redact_row:
				colPosition = original_headers.index(single_redact_col)
				single_row[colPosition] = redact_replacement
				log_modify('Row '+ str(single_redact_row) + ' Col '+ str(single_redact_col))
		for single_col in redact_column:
			single_row[single_col] = ''
		redacted_data = redacted_data + '\t'.join(single_row) + '\n'
	return redacted_data


def process_table_file_cna(csv_reader, redact_config):
	redacted_data = ''
	redact_column = []
	redact_row = []
	redact_modify = []
	headers = csv_reader.next()
	original_headers = copy.copy(headers)
	for single_redact in redact_config:
		if len(single_redact) == 1:
			if 'column' in single_redact:
				single_redact_col = single_redact['column']
				if single_redact_col in original_headers:
					redact_column.append(original_headers.index(single_redact_col))
			elif 'row' in single_redact:
				redact_row.append(single_redact['row'])
		else:
			redact_modify.append(single_redact)
	for single_col in redact_column:
		headers[single_col] = 'REDACT_ME_NOW'
		log_removal('Col ' + str(single_col))
	newheaders = []
	for item in headers:
		if 'REDACT_ME_NOW' in item:
			pass
		else:
			newheaders.append(item)
	redacted_data = '\t'.join(newheaders) + '\n'
	for single_row in csv_reader:
		rowId = single_row[0]
		if rowId in redact_row:
			log_removal('Row ' + str(rowId))
			continue
		for single_redact in redact_modify:
			single_redact_row = single_redact['row']
			single_redact_col = single_redact['column']
			redact_replacement = single_redact['replaceWith']
			if rowId == single_redact_row:
				colPosition = original_headers.index(single_redact_col)
				single_row[colPosition] = redact_replacement
				log_modify('Row ' + str(single_redact_row) + ' Col ' + str(single_redact_col))
		for single_col in redact_column:
			single_row[single_col] = 'REDACT_ME_NOW'
		newrow = []
		for item in single_row:
			if 'REDACT_ME_NOW' in item:
				pass
			else:
				newrow.append(item)
		redacted_data = redacted_data + '\t'.join(newrow) + '\n'
	return redacted_data


def process_combine_table_file(csv_reader_file_1,csv_reader_file_2):
	file_data = ''
	for single_row_file_1 in csv_reader_file_1:
		single_row_file_2 = csv_reader_file_2.next()
		single_line = single_row_file_1 + single_row_file_2[1::]
		file_data = file_data + '\t'.join(single_line) + '\n'
	return file_data

def process_case_list(reader,redact_config):
	samples_to_remove = redact_config
	redacted_data = ''
	for single_line in reader:
		if 'case_list_ids:' in single_line:
			sample_list = single_line.strip('\r\n').split()
			for single_sample in samples_to_remove:
				if single_sample in sample_list:
					sample_list.remove(single_sample)
					log_removal('Sample ' +single_sample)
			case_list_ids_line = '\t'.join(sample_list) + '\n'
			redacted_data = redacted_data + case_list_ids_line
		else:
			redacted_data = redacted_data + single_line
	return redacted_data

def process_combine_case_list(reader_file1,reader_file2):
	file_data = ''
	for single_line in reader_file2:
		if 'case_list_ids:' in single_line:
			sample_list = single_line.strip('\r\n').split()
	for single_line in reader_file1:
		if 'case_list_ids:' in single_line:
			sample_list = sample_list + single_line.strip('\r\n').split()[1::]
			case_list_ids_line = sample_list
			file_data = file_data + '\t'.join(case_list_ids_line) + '\n'
		else:
			file_data = file_data + single_line		
	return file_data


def process_group_redaction(clinical_file_path, pairing_file_path, redact_data):
	sample_dict = {}
	pair_list = []
	patient_dict = {}
	samples_to_remove = []	
	replaced_samples = {}
	removed_samples = []
	removed_patients = []
	removed_pairs = []
	keep_sample_list = []
	if pairing_file_path != None:
		with open(pairing_file_path,'r') as pairing_file:
			pairing_reader = csv.reader(pairing_file,delimiter='\t')
			pair_number = 0
			for single_pair in pairing_reader:
				if single_pair[0] not in sample_dict:
					sample_dict[single_pair[0]] = {'Normal':True,'PairList':[pair_number]}
				else:
					sample_dict[single_pair[0]]['PairList'].append(pair_number)
				if single_pair[1] not in sample_dict:
					sample_dict[single_pair[1]] = {'Normal':False,'PairList':[pair_number]}
				else:
					sample_dict[single_pair[1]]['PairList'].append(pair_number)		
				pair_list.append(single_pair)
				pair_number = pair_number + 1
	else:
		logger.error('Pairing file is required when redacting samples')
		sys.exit(2)
	if clinical_file_path != None:
		with open(clinical_file_path,'r') as clinical_file:
			clinical_reader = csv.reader(clinical_file,delimiter='\t')
			headers = clinical_reader.next()
			sample_id_position = headers.index("SAMPLE_ID")
			patient_id_position = headers.index("PATIENT_ID")
			for single_row in clinical_reader:
				sample_id = single_row[sample_id_position]
				patient_id = single_row[patient_id_position]
				single_sample_dict = sample_dict[sample_id]
				if 'Patient' not in sample_dict[sample_id]:
					sample_dict[sample_id]['Patient'] = patient_id
					if patient_id in patient_dict:
						patient_dict[patient_id].append(sample_id)
					else:
						patient_dict[patient_id] = [sample_id]
				for single_pair in single_sample_dict['PairList']:					
					samples = pair_list[single_pair]
					for single_sample in samples:
						if 'Patient' not in sample_dict[single_sample]:
							sample_dict[single_sample]['Patient'] = patient_id
							if patient_id in patient_dict:
								patient_dict[patient_id].append(sample_id)
							else:
								patient_dict[patient_id] = [sample_id]
	else:
		if 'patients' in redact_data:
			logger.error('Clinical data file is required when redacting patients')
			sys.exit(2)
	for single_sample_name in redact_data['samples']:
		single_sample = redact_data['samples'][single_sample_name]
		if single_sample['action'] == 'remove_pair':
			if single_sample_name not in sample_dict:
				logger.error('Sample ' + single_sample_name +' not in the pairing file')
				sys.exit(2)
			paired_sample_list = sample_dict[single_sample_name]['PairList']
			for single_pair in paired_sample_list:
				for single_pair_sample in pair_list[single_pair]:
					removed_samples.append(single_pair_sample)
					removed_pairs.append(single_pair)		
		elif single_sample['action'] == 'replace':
			if single_sample_name in replaced_samples:
				logger.error('Sample '+single_sample_name+' specified more than once to be replaced')
				sys.exit(2)
			if single_sample_name in removed_samples:
				logger.error('Sample '+single_sample_name+' cannot be removed and replaced. Please specify one action.')
				sys.exit(2)
			replaced_samples[single_sample_name] = single_sample['replaceWith']
	if 'patients' in redact_data:
		removed_patients = redact_data['patients']
		for single_patient in redact_data['patients']:
			for single_patient_sample in patient_dict[single_patient]:
				paired_sample_list = sample_dict[single_patient_sample]['PairList']
				for single_pair in paired_sample_list:
					for single_pair_sample in pair_list[single_pair]:
						removed_samples.append(single_pair_sample)
						removed_pairs.append(single_pair)				
	removed_samples = list(set(removed_samples))
	for single_sample in removed_samples:
		pair_list_num = 0
		keep_sample = False
		while pair_list_num < len(pair_list):
			#if pair_list_num in removed_pairs:
			#	pair_list_num = pair_list_num + 1
			#	continue
			if single_sample in pair_list[pair_list_num]:
				for single_pair_sample in pair_list[pair_list_num]:
					if single_pair_sample not in removed_samples:
						keep_sample = True
			pair_list_num = pair_list_num + 1
		if keep_sample:
			keep_sample_list.append(single_sample)
	for single_sample in keep_sample_list:
		removed_samples.remove(single_sample)
	redact_data['sample_data'] = sample_dict
	redact_data['removed_samples'] = removed_samples
	redact_data['replaced_samples'] = replaced_samples
	redact_data['removed_patients'] = removed_patients
	return redact_data

def process_replaced_samples(redacted_file,redact_data):
	if 'replaced_samples' in redact_data:
		for single_sample in redact_data['replaced_samples']:
			replaced_with_sample = redact_data['replaced_samples'][single_sample]
			redacted_file = redacted_file.replace(single_sample,replaced_with_sample)
	return redacted_file

def redact_case_list(original_file,redacted_file,redact_data):
	logger.info('---- Working on Case List file: ' + os.path.basename(redacted_file.name) +' ----')
	redact_config = []
	if 'removed_samples' in redact_data:
		redact_config = redact_data['removed_samples']
	redacted_file_int = process_case_list(original_file,redact_config)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_case_list(file_1,file_2,combined_file):
	logger.info('---- Combining Case List Files ----')
	combined_file_data = process_combine_case_list(file_1,file_2)
	combined_file.write(combined_file_data)

def redact_clinical(original_file,redacted_file,redact_data):
	logger.info('---- Working on Clinical file ----')
	if 'clinical' not in redact_data:
		redact_data['clinical'] = []
	redact_config = redact_data['clinical']
	if 'removed_samples' in redact_data:
		for single_sample in redact_data['removed_samples']:
			redact_config.append({"row":single_sample})
	csv_reader = csv.reader(original_file,delimiter='\t')
	redacted_file_data = process_table_file(csv_reader,redact_config)
	redacted_file.write(redacted_file_data)

def combine_clinical(file_1,file_2,combined_file):
	logger.info('---- Combining Clinical Files ----')	
	combined_file_data = process_combine_file_headers(file_1,file_2,5)
	combined_file.write(combined_file_data)

def combine_legacy_clinical(file_1,file_2,combined_file):
	logger.info('---- Combining Legacy Clinical Files ----')
	combined_file_data = process_combine_file_headers(file_1,file_2,1)
	combined_file.write(combined_file_data)

def redact_patient(original_file,redacted_file,redact_data):
	logger.info('---- Working on Patient file ----')
	if 'patient' not in redact_data:
		redact_data['patient'] = []
	redact_config = redact_data['patient']
	csv_reader = csv.reader(original_file,delimiter='\t')
	redacted_file_data = process_table_file(csv_reader,redact_config)
	redacted_file.write(redacted_file_data)

def combine_patient(file_1,file_2,combined_file):
	logger.info('---- Combining Patient files ----')
	combined_file_data = process_combine_file_headers(file_1,file_2,5)
	combined_file.write(combined_file_data)

def redact_request(original_file,redacted_file,redact_data):
	logger.info('---- Working on Request file ----')
	redact_config = []
	if 'removed_samples' in redact_data:
		redact_config = redact_data['removed_samples']
	redacted_file_int = process_request_file(original_file,redact_config)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_request(file_1,file_2, combined_file):
	logger.info('---- Combining Request files ----')
	combined_file_data = process_combine_request_file(file_1,file_2)
	combined_file.write(combined_file_data)

def redact_pairing(original_file,redacted_file,redact_data):
	logger.info('---- Working on Pairing file ----')
	redact_config = []
	if 'removed_samples' in redact_data:
		for single_sample in redact_data['removed_samples']:
			redact_config.append(single_sample)
	redacted_file_int = process_pairing_file(original_file,redact_config)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_pairing(file_1,file_2, combined_file):
	logger.info('---- Combining Pairing files ----')
	combined_file_data = process_combine_file(file_1,file_2)
	combined_file.write(combined_file_data)

def redact_grouping(original_file, redacted_file, redact_data):
	logger.info('---- Working on Grouping file ----')
	redact_config = []
	if 'removed_samples' in redact_data:
		for single_sample in redact_data['removed_samples']:
			redact_config.append({"row":single_sample})
	csv_reader = csv.reader(original_file,delimiter='\t')
	redacted_file_int = process_table_file(csv_reader,redact_config)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_grouping(file_1,file_2, combined_file):
	logger.info('---- Combining Grouping file ----')
	combined_file_data = process_combine_file(file_1, file_2)
	combined_file.write(combined_file_data)

def redact_mutation(original_file,redacted_file,redact_data):
	logger.info('---- Working on Mutation file ----')
	roslin_version = original_file.readline()
	redacted_file.write(roslin_version)
	if 'mutation' not in redact_data:
		redact_data['mutation'] = []
	redact_config = redact_data['mutation']
	if 'removed_samples' in redact_data:
		sample_data = redact_data['sample_data']
		for single_sample in redact_data['removed_samples']:
			sample_is_normal = sample_data[single_sample]['Normal']
			if not sample_is_normal:
				redact_config.append({"Tumor_Sample_Barcode":single_sample})
			else:
				redact_config.append({"Matched_Norm_Sample_Barcode":single_sample})
	csv_reader = csv.reader(original_file,delimiter='\t')
	headers = csv_reader.next()
	header_line = '\t'.join(headers) + '\n'
	redacted_file.write(header_line)
	redacted_file_int = process_csv_file(csv_reader,redact_config,headers)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_mutation(file_1,file_2, combined_file):
	logger.info('---- Combining Mutation file ----')
	combined_file_data = process_combine_file_headers(file_1,file_2,2)
	combined_file.write(combined_file_data)

def redact_fusions(original_file,redacted_file,redact_data):
	logger.info('---- Working on Fusion file ----')
	redact_config = []
	if 'fusion' not in redact_data:
		redact_data['fusion'] = []	
	redact_config = redact_data['fusion']	
	if 'removed_samples' in redact_data:
		sample_data = redact_data['sample_data']
		for single_sample in redact_data['removed_samples']:
			sample_is_normal = sample_data[single_sample]['Normal']
			if not sample_is_normal:
				redact_config.append({"Tumor_Sample_Barcode":single_sample})	
	csv_reader = csv.reader(original_file,delimiter='\t')
	headers = csv_reader.next()
	header_line = '\t'.join(headers) + '\n'
	redacted_file.write(header_line)
	redacted_file_int = process_csv_file(csv_reader,redact_config,headers)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_fusions(file_1,file_2, combined_file):
	logger.info('---- Combining Fusion file ----')
	combined_file_data = process_combine_file_headers(file_1,file_2,1)
	combined_file.write(combined_file_data)

def redact_CNA(original_file,redacted_file,redact_data):
	logger.info('---- Working on CNA file ----')
	if 'CNA' not in redact_data:
		redact_data['CNA'] = []
	redact_config = redact_data['CNA']
	if 'removed_samples' in redact_data:
		for single_sample in redact_data['removed_samples']:
			redact_config.append({"column":single_sample})
	csv_reader = csv.reader(original_file,delimiter='\t')	
	redacted_file_int = process_table_file_cna(csv_reader,redact_config)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data) 
	redacted_file.write(redacted_file_data)

def combine_CNA(file_1,file_2, combined_file):
	logger.info('---- Combining CNA file ----')
	csv_reader_file_1 = csv.reader(file_1,delimiter='\t')
	csv_reader_file_2 = csv.reader(file_2,delimiter='\t')
	combined_file_data = process_combine_table_file(csv_reader_file_1,csv_reader_file_2)
	combined_file.write(combined_file_data)

def redact_seg(original_file,redacted_file,redact_data):
	logger.info('---- Working on Seg file ----')
	if 'seg' not in redact_data:
		redact_data['seg'] = []
	redact_config = redact_data['seg']
	if 'removed_samples' in redact_data:
		for single_sample in redact_data['removed_samples']:
			redact_config.append({"ID":single_sample})
	csv_reader = csv.reader(original_file,delimiter='\t')
	headers = csv_reader.next()
	header_line = '\t'.join(headers) + '\n'
	redacted_file.write(header_line)
	redacted_file_int = process_csv_file(csv_reader,redact_config,headers)
	redacted_file_data = process_replaced_samples(redacted_file_int,redact_data)
	redacted_file.write(redacted_file_data)

def combine_seg(file_1,file_2, combined_file):
	logger.info('---- Combining Seg file ----')
	combined_file_data = process_combine_file_headers(file_1,file_2,1)
	combined_file.write(combined_file_data)


def redactFile(input_file,redact_file,redact_function,pairing_file,clinical_file):
	backup_file = input_file+'_back_redact'
	with open(redact_file) as redact_file_data:
		redact_data = json.load(redact_file_data)
	if 'samples' in redact_data:
		if len(redact_data['samples']) > 0:
			new_redact_data = process_group_redaction(clinical_file,pairing_file,redact_data)
	elif 'patient' in redact_data:
		if len(redact_data['patient']) > 0:
			new_redact_data = process_group_redaction(clinical_file,pairing_file,redact_data)
	else:
		new_redact_data = redact_data
	os.rename(input_file,backup_file)
	with open(backup_file,'r') as original_file, open(input_file,'w') as redacted_file:
		redact_function(original_file,redacted_file,new_redact_data)
	os.remove(backup_file)

def combineFile(file_1,file_2,combine_function):
	backup_file = file_1 + '_back_combine'
	os.rename(file_1,backup_file)
	with open(backup_file,'r') as first_file, open(file_2,'r') as second_file, open(file_1,'w') as combined_file:
		combine_function(first_file,second_file,combined_file)
	os.remove(backup_file)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(add_help=True, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--input_file',required=True,help='The input file to have elements redacted')
    parser.add_argument('--file_type',required=True,help='The type of file provided',choices=['mutation','fusion','CNA','seg','clinical','clinical-legacy','patient','case_list','request','pairing','grouping'])
    parser.add_argument('--combine_with',required=False,help='The file to combine with the input file')
    parser.add_argument('--redact_conf',required=True,help='The configuration file for the redactions needed')
    parser.add_argument('--pairing_file', required=False,help='The pairing file for this project')
    parser.add_argument('--clinical_file', required=False,help='The clinical file for this project')
    args = parser.parse_args()
    redact_function_mapping = {'mutation':redact_mutation,'fusion':redact_fusions,'CNA':redact_CNA,'seg':redact_seg,'clinical':redact_clinical,'clinical-legacy':redact_clinical,'patient':redact_patient,'case_list':redact_case_list,'request':redact_request,'pairing':redact_pairing,'grouping':redact_grouping}
    combine_function_mapping = {'mutation':combine_mutation,'fusion':combine_fusions,'CNA':combine_CNA,'seg':combine_seg,'clinical':combine_clinical,'clinical-legacy':combine_legacy_clinical,'patient':combine_patient,'case_list':combine_case_list,'request':combine_request,'pairing':combine_pairing,'grouping':combine_grouping}
    if args.combine_with is not None:
    	combineFile(args.input_file,args.combine_with,combine_function_mapping[args.file_type])
    redactFile(args.input_file,args.redact_conf,redact_function_mapping[args.file_type],args.pairing_file,args.clinical_file) 
