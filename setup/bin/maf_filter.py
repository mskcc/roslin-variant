#!/usr/bin/env python

import sys, os, csv, re

input_file = sys.argv[1]
roslin_version_string = sys.argv[2]
is_impact = True if sys.argv[3]=='True' else False
analyst_file = sys.argv[4]
portal_file = sys.argv[5]
roslin_version_line = "# Versions: " + roslin_version_string.replace('_',' ') + "\n"

# Analysis fillout maf file
analyst_fillout_file = re.sub(r'.muts.maf$', r'.muts.fillout.maf', analyst_file)

# Read input maf file
dict_analyst_kept = dict()
dict_fillout = dict()
dict_portal_kept = dict()
analyst_header = ''
portal_header = ''

with open(input_file,'rb') as input_maf:
    header = input_maf.readline().strip('\r\n').split('\t')
    # Skip all comment lines, and assume that the first line after them is the header
    while header[0].startswith("#"):
        header = input_maf.readline().strip('\r\n').split('\t')
    # The analyst MAF needs all the same columns as the input MAF (from vcf2maf, ngs-filters, etc.)
    analyst_header = '\t'.join(header) + '\n'
    # The portal MAF can be minimized since Genome Nexus re-annotates it when HGVSp_Short column is missing
    header[header.index('HGVSp_Short')] = 'Amino_Acid_Change'
    portal_header = '\t'.join(header[0:45]) + '\n'
    gene_col = header.index('Hugo_Symbol')
    entrez_id_col = header.index('Entrez_Gene_Id')
    chrom_col = header.index('Chromosome')
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
    set_col = header.index('set')
    variant_type = header.index('Variant_Type')
    fillout_tad_col = header.index('fillout_t_alt')
    fillout_tdp_col = header.index('fillout_t_depth')
    maf_reader = csv.reader(input_maf,delimiter='\t')
    for line in maf_reader:
        event_type = line[variant_type]
        tdp = int(line[tdp_col])
        tad = int(line[tad_col])
        if event_type == "SNP":
            tdp = int(line[fillout_tdp_col])
            tad = int(line[fillout_tad_col])
        # check if it is removed by one or more ccs filters and nothing else
        only_ccs_filters = True
        filters = re.split(';|,', line[filter_col])
        for filter in filters:
            if filter != "mq55" and filter != "nm2" and filter != "asb" and filter != "nad3":
                only_ccs_filters = False
                break
        arr_key = [line[chrom_col], line[pos_col], line[ref_col], line[alt_col]]
        key = '\t'.join(arr_key)
        # Store all fillout lines first
        # Skip any that failed false-positive filters, except common_variant and Skip all events reported uniquely by Pindel
        if line[mut_status_col] == 'None':
            dict_fillout.setdefault(key, []).append('\t'.join(line))
        elif (line[filter_col] == 'PASS' or line[filter_col] == 'common_variant' or (is_impact and only_ccs_filters)) and line[set_col] != 'Pindel':
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
                # For IMPACT data, apply the MSK-IMPACT depth/allele-count/VAF/indel-length cutoffs and skip reporting MT mutations because that is not targeted
                tumor_vaf = float(tad) / float(tdp) if tdp != 0 else 0
                if is_impact and ((tdp < 20 or tad < 8 or tumor_vaf < 0.02 or (line[hotspot_col] == 'FALSE' and (tad < 10 or tumor_vaf < 0.05))) or line[chrom_col] == 'MT'):
                    continue
                # analyst_maf.write('\t'.join(line) + '\n')
                dict_analyst_kept.setdefault(key, []).append('\t'.join(line))
                # The portal also skips silent muts, genes without Entrez IDs, and intronic events
                if re.match(r'synonymous_|stop_retained_', line[csq_col]) is None and line[entrez_id_col] != 0 and splice_dist <= 2:
                    # portal_maf.write('\t'.join(line[0:45]) + '\n')
                    dict_portal_kept.setdefault(key, []).append('\t'.join(line[0:45]))

# Keep fillout lines (Mutation_Status==None) in portal/data_mutations_extended.txt and also a new analysis file with extension analysis/*.muts.fillout.maf.
# write into analysis files
with open(analyst_file,'wb') as analyst_maf, open(analyst_fillout_file,'wb') as analyst_fillout_maf:
    analyst_maf.write(roslin_version_line)
    analyst_maf.write(analyst_header)
    analyst_fillout_maf.write(roslin_version_line)
    analyst_fillout_maf.write(analyst_header)
    for key, values in dict_analyst_kept.items():
        # write events first
        for value in values:
            analyst_maf.write(value + '\n')
            analyst_fillout_maf.write(value + '\n')
        # write fillout if available
        if key in dict_fillout:
            for fillout in dict_fillout[key]:
                analyst_fillout_maf.write(fillout + '\n')

# write into portal file
with open(portal_file,'wb') as portal_maf:
    portal_maf.write(roslin_version_line)
    portal_maf.write(portal_header)
    for key, values in dict_portal_kept.items():
        # write events first
        for value in values:
            portal_maf.write(value + '\n')
        # write fillout if available
        if key in dict_fillout:
            for fillout in dict_fillout[key]:
                portal_fillout = fillout.split('\t')
                portal_maf.write('\t'.join(portal_fillout[0:45]) + '\n')

# The concatenated MAF can be enormous, so cleanup after
os.remove(input_file)