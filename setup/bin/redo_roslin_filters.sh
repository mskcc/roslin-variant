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
fi

# Use the MAF name to figure out tumor/normal sample IDs, and base directory of Roslin results
tum=$(basename ${maf} | cut -f1 -d.)
nrm=$(basename ${maf} | cut -f2 -d.)
dir=$(dirname $(dirname ${maf}))

# Specify tools/data we will need
ref_fasta="/ifs/depot/pi/resources/genomes/GRCh37/fasta/b37.fasta"
vcf_filter="/opt/common/CentOS_6-dev/python/python-2.7.10/bin/python /opt/common/CentOS_6-dev/basicfiltering/v0.3"
hotspot_vcf="/opt/common/CentOS_6-dev/basicfiltering/v0.3/data/hotspot-list-union-v1-v2.vcf"
hotspot_txt="/opt/common/CentOS_6-dev/ngs-filters/v1.4/data/hotspot-list-union-v1-v2.txt"
bcftools="/opt/common/CentOS_6-dev/bcftools/bcftools-1.9/bcftools"
tabix="/opt/common/CentOS_6-dev/htslib/v1.9/tabix"
vcf2maf="/opt/common/CentOS_6-dev/perl/perl-5.22.0/bin/perl /opt/common/CentOS_6-dev/vcf2maf/v1.6.17/vcf2maf.pl"
vep_path="/opt/common/CentOS_6-dev/vep/v86"
vep_data="/opt/common/CentOS_6-dev/vep/cache"
vep_isoforms="/opt/common/CentOS_6-dev/vcf2maf/v1.6.17/data/isoform_overrides_at_mskcc"
filter_vcf="/opt/common/CentOS_6-dev/vep/cache/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz"
rm_vars="/opt/common/CentOS_6-dev/python/python-2.7.10/bin/python /opt/common/CentOS_6-dev/remove_variants/v0.1.1/remove_variants.py"
fillout="/ifs/work/pi/roslin-cmo/1.9.11/cmo/bin/cmo_fillout --version 1.2.2"
pon_bam_root="/ifs/work/pi/resources/curated_bams"
maf_filter="/opt/common/CentOS_6-dev/python/python-2.7.10/bin/python /opt/common/CentOS_6-dev/ngs-filters/v1.4/run_ngs-filters.py"

# Locate the VCFs for all callers, the additional TXT file for MuTect, and the tumor/normal BAM files
mutect_txt=`ls ${dir}/vcf/${tum}*${nrm}*.mutect.txt`
mutect_vcf=`ls ${dir}/vcf/${tum}*${nrm}*.mutect.vcf`
vardict_vcf=`ls ${dir}/vcf/${tum}*${nrm}*.vardict.vcf`
tum_bam=`ls ${dir}/bam/${tum}*.bam`
nrm_bam=`ls ${dir}/bam/${nrm}*.bam`
if [ -s ${mutect_txt} ] && [ -s ${mutect_vcf} ] && [ -s ${vardict_vcf} ] && [ -s ${tum_bam} ] && [ -s ${nrm_bam} ]
then echo STATUS: ${tum}/${nrm}: Filtering per-caller VCFs using basicfiltering
else echo ERROR: ${tum}/${nrm}: Unable to find input VCFs or BAMs at: ${dir}; exit 1
fi

# Run the CPX filter with more lenient cutoffs in IMPACT/HemePACT projects
complex_nn=0.1; complex_tn=0.2
assay=$(grep Assay: ${dir}/inputs/*_request.txt | cut -f2 -d' ')
if [[ ${assay} =~ "IMPACT" || ${assay} =~ "HemePACT" ]]
then complex_nn=0.2; complex_tn=0.5
fi
echo "STATUS: Using filter_complex.py parameters, complex_nn/complex_tn: $complex_nn/$complex_tn"

# Run the appropriate basicfiltering script for each variant caller's VCF
vardict_cpx_vcf=${vardict_vcf%.vardict.vcf}.cpx.vardict.vcf
${vcf_filter}/filter_mutect.py --inputVcf ${mutect_vcf} --inputTxt ${mutect_txt} --tsampleName ${tum} --refFasta ${ref_fasta} --hotspotVcf ${hotspot_vcf} --outDir ${dir}/vcf
${vcf_filter}/filter_complex.py -tn ${complex_tn} -nn ${complex_nn} --input-vcf ${vardict_vcf} --tumor-id ${tum} --tumor-bam ${tum_bam} --normal-bam ${nrm_bam} --output-vcf ${vardict_cpx_vcf}
${vcf_filter}/filter_vardict.py --inputVcf ${vardict_cpx_vcf} --tsampleName ${tum} --refFasta ${ref_fasta} --hotspotVcf ${hotspot_vcf} --outDir ${dir}/vcf
rm -f ${dir}/vcf/${tum}*${nrm}*.{mutect,vardict}_STDfilter.{txt,vcf} ${vardict_cpx_vcf}*

mutect_vcf_gz=${dir}/vcf/${tum}*${nrm}*.mutect_STDfilter.norm.vcf.gz
vardict_vcf_gz=${dir}/vcf/${tum}*${nrm}*.vardict_STDfilter.norm.vcf.gz
if [ -s ${mutect_vcf_gz} ] && [ -s ${vardict_vcf_gz} ]
then echo STATUS: ${tum}/${nrm}: Merging filtered VCFs using bcftools concat
else echo ERROR: ${tum}/${nrm}: Failed to filter per-caller VCFs using basicfiltering; exit 1
fi

# Run bcftools concat to merge and deduplicate events from multiple variant callers
concat_vcf_gz=${dir}/vcf/${tum}.${nrm}.combined-variants.vcf.gz
${bcftools} concat --allow-overlaps --rm-dups all --output-type z --output ${concat_vcf_gz} ${vardict_vcf_gz} ${mutect_vcf_gz}
${tabix} -p vcf ${concat_vcf_gz}

if [ -s ${concat_vcf_gz} ]
then echo STATUS: ${tum}/${nrm}: Tag MuTect calls using bcftools annotate
else echo ERROR: ${tum}/${nrm}: Failed to merge filtered VCFs using bcftools concat; exit 1
fi

# Run bcftools annotations to add 'MuTect' if the event called by both VarDict and MuTect
anno_vcf=${dir}/vcf/${tum}.${nrm}.combined-variants.anno.vcf
${bcftools} annotate --annotations ${mutect_vcf_gz} --columns INFO/FAILURE_REASON --mark-sites '+set=MuTect' --output ${anno_vcf} ${concat_vcf_gz}
rm -f ${concat_vcf_gz} ${concat_vcf_gz}.tbi

if [ -s ${anno_vcf} ]
then echo STATUS: ${tum}/${nrm}: Converting merged VCF into MAF using vcf2maf
else echo ERROR: ${tum}/${nrm}: Failed to tag MuTect calls using bcftools annotate; exit 1
fi

# Run vcf2maf on the merged VCF to generate an annotated MAF format file
concat_maf=${dir}/maf/${tum}.${nrm}.combined-variants.vep.maf
${vcf2maf} --input-vcf ${anno_vcf} --tumor-id ${tum} --vcf-tumor-id ${tum} --normal-id ${nrm} --vcf-normal-id ${nrm} --ncbi-build GRCh37 --ref-fasta ${ref_fasta} --retain-info set,TYPE,FAILURE_REASON,MSI,MSILEN,SSF,LSEQ,RSEQ,STATUS,VSB --retain-fmt QUAL,BIAS,HIAF,PMEAN,PSTD,ALD,RD,NM,MQ,IS --vep-forks 8 --vep-path ${vep_path} --vep-data ${vep_data} --output-maf ${concat_maf} --filter-vcf ${filter_vcf} --custom-enst ${vep_isoforms}
rm -f ${anno_vcf%.vcf}.vep.vcf

if [ -s ${concat_maf} ]
then echo STATUS: ${tum}/${nrm}: Removing variants that overlap larger events
else echo ERROR: ${tum}/${nrm}: Failed to convert merged VCF into MAF using vcf2maf; exit 1
fi

# Remove variants that overlap larger or complex events
rm_var_maf=${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.maf
${rm_vars} --input-maf ${concat_maf} --output-maf ${rm_var_maf}

if [ -s ${rm_var_maf} ]
then echo STATUS: ${tum}/${nrm}: Running fillout to gather aligner-based readcounts
else echo ERROR: ${tum}/${nrm}: Failed to remove variants that overlap larger events; exit 1
fi

# For each BAM, make sure we have a .bam.bai for users of tools based on older samtools
bams=${dir}/bam/*.bam
for bam in bams
do
    if [ -s ${bam%.bam}.bai ] && [ ! -s ${bam}.bai ]
    then cp ${bam%.bam}.bai ${bam}.bai
    fi
done

# Locate the pairing file from the inputs folder
pairing=${dir}/inputs/*_sample_pairing.txt

# Run fillout to backfill readcounts for events across just the TN-pair of BAMs
fillout_maf=${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.fillout.portal.maf
${fillout} --genome GRCh37 --format 1 --n_threads 8 --maf ${rm_var_maf} --output ${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.fillout --portal-output ${fillout_maf} --bams ${tum_bam} ${nrm_bam} --pairing-file ${pairing}

if [ -s ${fillout_maf} ]
then echo STATUS: ${tum}/${nrm}: Running fillout on panel-of-normals
else echo ERROR: ${tum}/${nrm}: Failed to run fillout to gather aligner-based readcounts; exit 1
fi

# Run fillout to backfill readcounts for events across the curated panel-of-normals (PoN)
pon_fillout=${dir}/maf/${tum}.${nrm}.combined-variants.vep.rmv.curated.fillout
pon_bams=${pon_bam_root}/${assay}*/*.bam
${fillout} --genome GRCh37 --format 1 --n_threads 8 --maf ${rm_var_maf} --output ${pon_fillout} --portal-output /dev/null --bams ${pon_bams}

if [ -s ${pon_fillout} ]
then echo STATUS: ${tum}/${nrm}: Running ngs-filters to add filter tags to MAF
else echo ERROR: ${tum}/${nrm}: Failed to run fillout on panel-of-normals; exit 1
fi

# Backup the input MAF, but don't overwrite an existing backup
if [ -s ${maf} ] && [ ! -s ${maf}.bkp ]
then mv ${maf} ${maf}.bkp
fi

# Run ngs-filters to add more FILTER tags to the MAF, most importantly the PoN filter
${maf_filter} --input-maf ${fillout_maf} --output-maf ${maf} --normal-panel-maf ${pon_fillout} --input-hotspot ${hotspot_txt}

if [ -s ${maf} ]
then echo STATUS: ${tum}/${nrm}: Completed redoing filters and replaced MAF
else echo ERROR: ${tum}/${nrm}: Failed to run ngs-filters to add filter tags to MAF; exit 1
fi

# Cleanup files we don't want to keep
rm -f ${dir}/maf/${tum}.${nrm}.combined-variants.vep.*

# Attach "roslin-filters-2.4.2" tag into log/stdout.log file at "VERSION:" line
mv log/stdout.log log/stdout.log.bkp
awk -F', ' 'BEGIN {OFS=", "} /^VERSIONS:/ && !/roslin-filter/{$2=$2", roslin-filters-2.4.2"} {print $0}' log/stdout.log.bkp > log/stdout.log
