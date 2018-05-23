#!/usr/bin/env python

import sys, os, csv, re

input_file = sys.argv[1]
roslin_version_string = sys.argv[2]
analyst_file = sys.argv[3]
portal_file = sys.argv[4]
roslin_version_line = "#" + roslin_version_string.replace("_"," ") + "\n"

# ::TODO:: Analyst MAF should be made during workflow, and we only filter non-portal events here
with open(input_file,'rb') as input_maf, open(analyst_file,'wb') as analyst_maf, open(portal_file,'wb') as portal_maf:
    header = input_maf.readline().strip('\r\n').split('\t')
    header_line = '\t'.join(header) + '\n'
    analyst_maf.write(roslin_version_line)
    portal_maf.write(roslin_version_line)
    analyst_maf.write(header_line)
    portal_maf.write(header_line)
    gene_col = header.index('Hugo_Symbol')
    entrez_id_col = header.index('Entrez_Gene_Id')
    pos_col = header.index('Start_Position')
    hgvsc_col = header.index('HGVSc')
    mut_status_col = header.index('Mutation_Status')
    csq_col = header.index('Consequence')
    filter_col = header.index('FILTER')
    maf_reader = csv.reader(input_maf,delimiter='\t')
    for line in maf_reader:
        # Skip uncalled events from cmo_fillout and any that failed false-positive filters
        if line[mut_status_col] == 'None' or line[filter_col] != 'PASS':
            continue
        # Skip splice region variants in non-coding genes, or those that are >3bp into introns
        splice_dist = 0
        if re.match(r'splice_region_variant', line[csq_col]) is not None:
            if re.search(r'non_coding_', line[csq_col]) is not None:
                continue
            # Parse the complex HGVSc format to determine the distance from the splice junction
            m = re.match(r'[nc]\.\d+[-+](\d+)_\d+[-+](\d+)|[nc]\.\d+[-+](\d+)', line[hgvsc_col])
            if m is not None:
                # For indels, use the closest distance to the nearby splice junction
                splice_dist = min(int(d) for d in [x for x in m.group(1,2,3) if x is not None])
                if splice_dist > 3:
                    continue
        # Skip all non-coding events except interesting ones like TERT promoter mutations
        csq_keep = ['missense_', 'stop_', 'frameshift_', 'splice_', 'inframe_', 'protein_altering_',
            'start_', 'synonymous_', 'coding_sequence_', 'transcript_', 'exon_', 'initiator_codon_',
            'disruptive_inframe_', 'conservative_missense_', 'rare_amino_acid_', 'mature_miRNA_', 'TFBS_']
        if re.match(r'|'.join(csq_keep), line[csq_col]) is not None or (line[gene_col] == 'TERT' and int(line[pos_col]) >= 1295141 and int(line[pos_col]) <= 1295340):
            analyst_maf.write('\t'.join(line) + '\n')
            # The portal also skips silent muts, genes without Entrez IDs, and intronic splice region muts
            if re.match(r'synonymous_', line[csq_col]) is None and line[entrez_id_col] != 0 and splice_dist <= 2:
                portal_maf.write('\t'.join(line) + '\n')

# The concatenated MAF can be enormous, so cleanup after
os.remove(input_file)
