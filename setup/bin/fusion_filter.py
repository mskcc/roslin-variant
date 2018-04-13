import sys
import os
import csv

input_file = sys.argv[1]
fixed_output_file = input_file.replace('.combined.txt','.txt')
list_of_fusions_to_remove = []
maf_file_fixed_body = []
with open(input_file,'r') as maf_file:
	header = maf_file.readline().strip('\r\n').split('\t')
	Entrez_Gene_Id_position = header.index('Entrez_Gene_Id')
	Fusion_position = header.index('Fusion')
	csv_reader = csv.reader(maf_file,delimiter='\t')
	for single_line in csv_reader:
		Entrez_Gene_Id_value = int(single_line[Entrez_Gene_Id_position])
		Fusion_value = single_line[Fusion_position]
		if Entrez_Gene_Id_value <= 0:
			list_of_fusions_to_remove.append(Fusion_value)
		new_line_values = single_line
		maf_file_fixed_body.append(new_line_values)

with open(fixed_output_file,'w') as maf_file_fixed:
	header_line = '\t'.join(header) + '\n'
	maf_file_fixed.write(header_line)
	for single_line in maf_file_fixed_body:
		Fusion_value = single_line[Fusion_position]
		if Fusion_value in list_of_fusions_to_remove:
			print "----removing line----"
			print single_line
			continue
		new_line = '\t'.join(single_line) + '\n'
		maf_file_fixed.write(new_line)

os.remove(input_file)

