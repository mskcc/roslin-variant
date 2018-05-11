import sys
import os
import csv

input_file = sys.argv[1]
roslin_version_string = [2]
roslin_version_line = "#VERSIONS: " + roslin_version_string.replace("_"," ")
fixed_output_file = input_file.replace('.combined.txt','.txt')

with open(input_file,'r') as maf_file, open(fixed_output_file,'w') as maf_file_fixed:
	header = maf_file.readline().strip('\r\n').split('\t')
	header_line = '\t'.join(header) + '\n'
	maf_file_fixed.write(roslin_version_line)
	maf_file_fixed.write(header_line)
	ref_position = header.index('n_ref_count')
	alt_position = header.index('n_alt_count')
	mutation_status_position = header.index('Mutation_Status')
	filter_position = header.index('FILTER')
	csv_reader = csv.reader(maf_file,delimiter='\t')
	for single_line in csv_reader:
		#line_values = single_line.strip('\r\n').split('\t')
		ref_value = single_line[ref_position]
		alt_value = single_line[alt_position]
		mutation_status_value = single_line[mutation_status_position]
		filter_value = single_line[filter_position]
		if mutation_status_value == 'None':
			continue
		if filter_value != 'PASS':
			continue
		new_line_values = single_line
		if ref_value != '':
			new_ref_value = int(float(single_line[ref_position]))
			new_line_values[ref_position] = str(new_ref_value)
		if alt_value != '':
			new_alt_value = int(float(single_line[alt_position]))
			new_line_values[alt_position] = str(new_alt_value)
		new_line = '\t'.join(new_line_values) + '\n'
		maf_file_fixed.write(new_line)
os.remove(input_file)

