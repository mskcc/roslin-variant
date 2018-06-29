#!/usr/bin/env python

import sys, os, csv, re

input_file = sys.argv[1]
roslin_version_string = sys.argv[2]
is_impact = bool(sys.argv[3])
analyst_file = sys.argv[4]
portal_file = sys.argv[5]
roslin_version_line = "# Versions: " + roslin_version_string.replace('_',' ') + "\n"

with open(input_file,'rb') as input_maf, open(analyst_file,'wb') as analyst_maf, open(portal_file,'wb') as portal_maf:
    header = input_maf.readline().strip('\r\n').split('\t')
    analyst_maf.write(roslin_version_line)
    portal_maf.write(roslin_version_line)
    analyst_maf.write('\t'.join(header) + '\n')
    # Rename HGVSp_Short to Amino_Acid_Change, so the portal will re-annotate with Genome Nexus
    header[header.index('HGVSp_Short')] = 'Amino_Acid_Change'
    # For the portal, provide only basic MAF columns plus read depths and allele counts
    portal_maf.write('\t'.join(header[0:45]) + '\n')
    gene_col = header.index('Hugo_Symbol')
    entrez_id_col = header.index('Entrez_Gene_Id')
    pos_col = header.index('Start_Position')
    ref_col = header.index('Reference_Allele')
    alt_col = header.index('Tumor_Seq_Allele2')
    hgvsc_col = header.index('HGVSc')
    mut_status_col = header.index('Mutation_Status')
    csq_col = header.index('Consequence')
    filter_col = header.index('FILTER')
    hotspot_col = header.index('hotspot_whitelist')
    tad_col = header.index('t_alt_count')
    tdp_col = header.index('t_depth')
    maf_reader = csv.reader(input_maf,delimiter='\t')
    for line in maf_reader:
        # Skip uncalled events from cmo_fillout and any that failed false-positive filters
        if line[mut_status_col] == 'None' or line[filter_col] != 'PASS':
            continue
        # Skip events larger than 50bp with VAF<20%, some samples appear enriched for these
        var_length = len(line[ref_col]) if len(line[ref_col]) > len(line[alt_col]) else len(line[alt_col])
        tumor_vaf = float(line[tad_col]) / float(line[tdp_col]) if line[tdp_col] else 0
        if var_length > 50 and tumor_vaf < 0.2:
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
            # For IMPACT data, apply the MSK-IMPACT depth/allele-count/VAF/indel-length cutoffs
            if is_impact and (int(line[tdp_col]) < 20 or int(line[tad_col]) < 8 or tumor_vaf < 0.02 or var_length >= 30 or (line[hotspot_col] == 'FALSE' and (int(line[tad_col]) < 10 or tumor_vaf < 0.05))):
                continue
            analyst_maf.write('\t'.join(line) + '\n')
            # The portal also skips silent muts, genes without Entrez IDs, and intronic events
            if re.match(r'synonymous_|stop_retained_', line[csq_col]) is None and line[entrez_id_col] != 0 and splice_dist <= 2:
                portal_maf.write('\t'.join(line[0:45]) + '\n')

# The concatenated MAF can be enormous, so cleanup after
os.remove(input_file)
