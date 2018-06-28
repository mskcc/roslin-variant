#!/usr/bin/env python

import sys, os, csv, re, requests

input_file = sys.argv[1]
output_file = sys.argv[2]
list_of_fusions_to_remove = []
fixed_file_content = []

# Fetch the latest list of known oncogenic fusions from OncoKB
# ::TODO:: We need a data freeze of this in the repo, or we fail at reproducibility
fusions = requests.get('http://oncokb.org/internal/api/v1/variants/lookup?variant=fusion').json()
oncokb_fusion = {}
for fusion in fusions:
    pair = re.sub(r'\s|Fusion[s]?|Intragenic', '', fusion['name'].encode('ascii','ignore'), flags=re.IGNORECASE)
    if pair:
        # Save GeneA-GeneB and GeneB-GeneA cuz they don't order genes alphabetically like Roslin
        pair_flipped = '-'.join(reversed(pair.split("-", 1)))
        oncokb_fusion[pair] = oncokb_fusion[pair_flipped] = 1

with open(input_file,'rb') as infile:
    header = infile.readline().strip('\r\n').split('\t')
    gene_position = header.index('Hugo_Symbol')
    Entrez_Gene_Id_position = header.index('Entrez_Gene_Id')
    Fusion_position = header.index('Fusion')
    csv_reader = csv.reader(infile,delimiter='\t')
    for line in csv_reader:
        gene = line[gene_position]
        entrez_id = int(line[Entrez_Gene_Id_position])
        fusion = line[Fusion_position]
        # Skip fusions with genes missing Entrez IDs, because the portal can't handle those
        # Skip fusions that have not been previously reported in OncoKB
        if entrez_id == 0 or not fusion or '-' not in fusion or fusion.replace(' fusion', '') not in oncokb_fusion:
            list_of_fusions_to_remove.append(fusion)
        new_line_values = line
        fixed_file_content.append(new_line_values)

with open(output_file,'wb') as outfile:
    header_line = '\t'.join(header) + '\n'
    outfile.write(header_line)
    for line in fixed_file_content:
        fusion = line[Fusion_position]
        if fusion in list_of_fusions_to_remove:
            continue
        new_line = '\t'.join(line) + '\n'
        outfile.write(new_line)

os.remove(input_file)
