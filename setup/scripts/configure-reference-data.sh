#!/bin/bash -e

# load config
source ./settings.sh

usage()
{
cat << EOF

USAGE: $0 [options]

OPTIONS:

   -l      Location of the genome reference files
           (either "ifs" or "local", case-sensitive)

           "ifs"  : uses the files from the /ifs on ifs
           "local" : uses the files that were shipped with the installation package
           "s3"    : uses the files in AWS S3

EXAMPLES:

   `basename $0` -l ifs

EOF
}

while getopts “l:h” OPTION
do
    case $OPTION in
        l) LOC_GENASSM=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

case $LOC_GENASSM in

    ifs)

        if [ -z $SKIP_B3 ]
        then
            # copy and configure reference data
            mkdir -p ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
            cp /ifs/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/* ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
            cp /ifs/depot/assemblies/H.sapiens/b37/b37.* ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/
        fi
        ;;

    local)

        # directories for reference data
        if [ -z $USE_VAGRANT_BIG_DISK ]
        then
            mkdir -p ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
        else
            mkdir -p ${PRISM_DATA_PATH}}/depot/assemblies/H.sapiens/b37/index/bwa
            sudo mkdir -p /vagrant/bigdisk/b37
            ln -snf /vagrant/bigdisk/depot/assemblies/H.sapiens/b37/index/bwa ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
        fi

        if [ -z $SKIP_B3 ]
        then
            # copy and configure reference data
            cat ../data/assemblies/b37.tar.gz.part_* > ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.tar.gz
            tar xvzf ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.tar.gz -C ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
            rm -rf ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.tar.gz
            chmod -R +r ${PRISM_DATA_PATH}/depot/
        fi
        ;;

    s3)

        if [ -z $SKIP_B3 ]
        then

            mkdir -p ../data/assemblies
            mkdir -p ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
            mkdir -p /ifs/work/prism/chunj/test-data/ref

            # sync from s3 (b37)
            aws s3 sync s3://chunj-ifs/depot/assemblies/H.sapiens/b37 ../data/assemblies

            # copy and configure reference data (b37)
            cat ../data/assemblies/b37.tar.gz.part_* > ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.tar.gz
            tar xvzf ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.tar.gz -C ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12
            rm -rf ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.tar.gz
            chmod -R +r ${PRISM_DATA_PATH}/depot/

            cp ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.fasta ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/
            cp ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.fasta.fai ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/
            cp ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/index/bwa/0.7.12/b37.dict ${PRISM_DATA_PATH}/depot/assemblies/H.sapiens/b37/

            # sync from s3 (vcf, ...)
            aws s3 sync s3://chunj-ref /ifs/work/prism/chunj/test-data/
            mkdir -p /ifs/work/prism/chunj/test-data/ref/
            mkdir -p /ifs/work/prism/chunj/test-data/vep/86

            tar xvzf ref.tgz -C /ifs/work/prism/chunj/test-data/ref/
            tar xvzf vep86.tgz -C /ifs/work/prism/chunj/test-data/vep/86/

            # clean up
            rm -rf /tmp/prism-v1.0.0/setup/data/assemblies/
            rm -rf /ifs/work/prism/chunj/test-data/ref.tgz
            rm -rf /ifs/work/prism/chunj/test-data/vep86.tgz
        fi
        ;;

    *)

        usage
        exit 1
        ;;
esac
