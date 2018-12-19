#!/usr/bin/env bash

# For a given sample-level unfiltered MAF, locate the raw VCFs, redo all filters, vcf2maf, and fillout.
# Then overwrite the input MAF. A backup of it will be created, unless a backup already exists.

usage()
{
cat << EOF

USAGE: $(basename $0) [options]

OPTIONS:

   -m      A Roslin muts.maf to overwrite e.g. /ifs/res/pi/Proj_07951_Y.1cddcc24-c335-11e8-8a68-645106ef9e4c/maf/s_C_1NPV4P_M001_d.s_C_1NPV4P_N001_d.muts.maf (A backup will be created)
   -h      Show help and usage

EOF
}

unset maf
while getopts "m:h" OPTION
do
    case $OPTION in
        m) maf=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z ${maf} ]
then echo ERROR: An input MAF must be specified; usage; exit 1
elif [ ! -s ${maf} ]
then echo ERROR: Input MAF is either empty or does not exist: ${maf}; usage; exit 1
fi

# Use the MAF name to figure out tumor/normal sample IDs, and base directory of Roslin results
tum=$(basename ${maf} | cut -f1 -d.)
nrm=$(basename ${maf} | cut -f2 -d.)
dir=$(dirname $(dirname ${maf}))

# Specify tools/data we will need
ref_fasta="/ifs/depot/pi/resources/genomes/GRCh37/fasta/b37.fasta"
vcf_filter="/opt/common/CentOS_6-dev/basicfiltering/v0.2.1/runScript.sh"
hotspot_vcf="/opt/common/CentOS_6-dev/basicfiltering/v0.2.1/data/hotspot-list-union-v1-v2.vcf"
bcftools="/opt/common/CentOS_6-dev/bcftools/bcftools-1.3.1/bcftools"
vcf2maf="/ifs/work/pi/cmo_package_archive/1.9.10/bin/cmo_vcf2maf --version 1.6.15 --vep-release 86"
rm_vars="/opt/common/CentOS_6-dev/python/python-2.7.10/bin/python /opt/common/CentOS_6-dev/remove_variants/v0.1.1/remove_variants.py"
fillout="/ifs/work/pi/cmo_package_archive/1.9.10/bin/cmo_fillout --version 1.2.2"
pon_bam_root="/ifs/work/pi/resources/curated_bams"
maf_filter="/opt/common/CentOS_6-dev/python/python-2.7.10/bin/python /opt/common/CentOS_6-dev/ngs-filters/v1.3/run_ngs-filters.py"
hotspot_txt="/opt/common/CentOS_6-dev/ngs-filters/v1.3/data/hotspot-list-union-v1-v2.txt"

# Locate the VCFs for all callers and the additional TXT file for MuTect
mutect_txt=${dir}/vcf/${tum}*${nrm}*.mutect.txt
mutect_vcf=${dir}/vcf/${tum}*${nrm}*.mutect.vcf
pindel_vcf=${dir}/vcf/${tum}*${nrm}*.pindel.vcf
vardict_vcf=${dir}/vcf/${tum}*${nrm}*.vardict.vcf
if [[ -s ${mutect_txt} && -s ${mutect_vcf} && -s ${pindel_vcf} && -s ${vardict_vcf} ]]
then echo STATUS: ${tum}/${nrm}: Filtering per-caller VCFs using basicfiltering
else echo ERROR: ${tum}/${nrm}: Unable to find necessary files at: ${dir}/vcf; exit 1
fi

# Run the appropriate basicfiltering script for each variant caller's VCF
${vcf_filter} mutect --inputVcf ${mutect_vcf} --inputTxt ${mutect_txt} --tsampleName ${tum} --refFasta ${ref_fasta} --hotspotVcf ${hotspot_vcf} --outDir ${dir}/vcf
${vcf_filter} pindel --inputVcf ${pindel_vcf} --tsampleName ${tum} --refFasta ${ref_fasta} --hotspotVcf ${hotspot_vcf} --outDir ${dir}/vcf
${vcf_filter} vardict --inputVcf ${vardict_vcf} --tsampleName ${tum} --refFasta ${ref_fasta} --hotspotVcf ${hotspot_vcf} --outDir ${dir}/vcf
rm -f ${dir}/vcf/${tum}*${nrm}*.{mutect,pindel,vardict}_STDfilter.{txt,vcf}

mutect_vcf_gz=${dir}/vcf/${tum}*${nrm}*.mutect_STDfilter.norm.vcf.gz
pindel_vcf_gz=${dir}/vcf/${tum}*${nrm}*.pindel_STDfilter.norm.vcf.gz
vardict_vcf_gz=${dir}/vcf/${tum}*${nrm}*.vardict_STDfilter.norm.vcf.gz
if [[ -s ${mutect_vcf_gz} && -s ${pindel_vcf_gz} && -s ${vardict_vcf_gz} ]]
then echo STATUS: ${tum}/${nrm}: Merging filtered VCFs using bcftools concat
else echo ERROR: ${tum}/${nrm}: Filtering per-caller VCFs using basicfiltering; exit 1
fi

# Run bcftools concat to merge and deduplicate events from multiple variant callers
concat_vcf=${dir}/vcf/${tum}.${nrm}.combined-variants.vcf
${bcftools} concat --allow-overlaps --rm-dups all --output ${concat_vcf} ${vardict_vcf_gz} ${mutect_vcf_gz} ${pindel_vcf_gz}

if [ -s ${concat_vcf} ]
then echo STATUS: ${tum}/${nrm}: Converting merged VCF into MAF using vcf2maf
else echo ERROR: ${tum}/${nrm}: Merging filtered VCFs using bcftools concat; exit 1
fi

# Run vcf2maf on the merged VCF to generate an annotated MAF format file
concat_maf=${dir}/maf/${tum}.${nrm}.combined-variants.vep.maf
${vcf2maf} --input-vcf ${concat_vcf} --tumor-id ${tum} --vcf-tumor-id ${tum} --normal-id ${nrm} --vcf-normal-id ${nrm} --ncbi-build GRCh37 --ref-fasta ${ref_fasta} --retain-info set,TYPE,FAILURE_REASON --output-maf ${concat_maf}

if [ -s ${concat_maf} ]
then echo STATUS: ${tum}/${nrm}: Removing variants that overlap larger events
else echo ERROR: ${tum}/${nrm}: Converting merged VCF into MAF using vcf2maf; exit 1
fi

# Remove variants that overlap larger or complex events
rm_var_maf=${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.maf
${rm_vars} --input-maf ${concat_maf} --output-maf ${rm_var_maf}

if [ -s ${rm_var_maf} ]
then echo STATUS: ${tum}/${nrm}: Running fillout on all samples cohort-wide
else echo ERROR: ${tum}/${nrm}: Removing variants that overlap larger events; exit 1
fi

# For each BAM, make sure we have a .bam.bai for users of tools based on older samtools
bams=${dir}/bam/*.bam
for bam in bams
do
    if [ -s ${bam%.bam}.bai && ! -s ${bam}.bai ]
    then cp ${bam%.bam}.bai ${bam}.bai
    fi
done

# Run fillout to backfill readcounts for events across all BAMs in the cohort
fillout_maf=${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.fillout.portal.maf
${fillout} --genome GRCh37 --format 1 --n_threads 4 --maf ${rm_var_maf} --output ${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.fillout --portal-output ${fillout_maf} --bams ${bams}

if [ -s ${fillout_maf} ]
then echo STATUS: ${tum}/${nrm}: Running fillout on panel-of-normals
else echo ERROR: ${tum}/${nrm}: Running fillout on all samples cohort-wide; exit 1
fi

# Run fillout to backfill readcounts for events across the curated panel-of-normals (PoN)
pon_fillout=${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.curated.fillout
assay=$(grep Assay: ${dir}/inputs/*_request.txt | cut -f2 -d' ')
pon_bams=${pon_bam_root}/${assay}/*.bam
${fillout} --genome GRCh37 --format 1 --n_threads 4 --maf ${fillout_maf} --output ${pon_fillout} --portal-output /dev/null --bams ${pon_bams}

if [ -s ${pon_fillout} ]
then echo STATUS: ${tum}/${nrm}: Running ngs-filters to add filter tags to MAF
else echo ERROR: ${tum}/${nrm}: Running fillout on panel-of-normals; exit 1
fi

# Backup the input MAF, but don't overwrite an existing backup
if [ ! -s ${maf}.bkp ]
then mv ${maf} ${maf}.bkp
fi

# Run ngs-filters to add more FILTER tags to the MAF, most importantly the PoN filter
${maf_filter} --input-maf ${fillout_maf} --output-maf ${maf} --normal-panel-maf ${pon_fillout} --input-hotspot ${hotspot_txt}

if [ -s ${maf} ]
then echo STATUS: ${tum}/${nrm}: Completed redoing filters and replaced MAF
else echo ERROR: ${tum}/${nrm}: Running ngs-filters to add filter tags to MAF; exit 1
fi

# Cleanup files we don't want to keep
rm -f ${dir}/maf/${tum}.${nrm}.combined-variants.vep.*
