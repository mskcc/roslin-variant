#!/usr/bin/env python3

import sys, os, csv, re, requests

input_file = sys.argv[1]
output_file = sys.argv[2]
list_of_fusions_to_remove = []
fixed_file_content = []

# Fetch all fusions reported in clinic by DMP (Department of Molecular Pathology) at MSKCC
dmp_fusion = {}
with open(os.path.join(os.path.dirname(sys.argv[0]), 'known_fusions_at_mskcc.txt'),'rb') as fusions:
    for pair in fusions:
        pair = pair.strip('\r\n')
        dmp_fusion[pair] = 1

with open(input_file,'rb') as infile:
    header = infile.readline().decode().strip('\r\n').split('\t')
    gene_position = header.index('Hugo_Symbol')
    Entrez_Gene_Id_position = header.index('Entrez_Gene_Id')
    Fusion_position = header.index('Fusion')
    csv_reader = csv.reader(infile,delimiter='\t')
    for line in csv_reader:
        gene = line[gene_position]
        entrez_id = int(line[Entrez_Gene_Id_position])
        fusion = line[Fusion_position]
        # Skip fusions with genes missing Entrez IDs, because the portal can't handle those
        # Skip fusions that have not been previously reported by DMP at MSKCC
        if entrez_id == 0 or not fusion or '-' not in fusion or fusion.replace(' fusion', '') not in dmp_fusion:
            list_of_fusions_to_remove.append(fusion)
        new_line_values = line
        fixed_file_content.append(new_line_values)

with open(output_file,'wb') as outfile:
    header_line = '\t'.join(header) + '\n'
    outfile.write(header_line.encode())
    for line in fixed_file_content:
        fusion = line[Fusion_position]
        if fusion in list_of_fusions_to_remove:
            continue
        new_line = '\t'.join(line) + '\n'
        outfile.write(new_line)

os.remove(input_file)
