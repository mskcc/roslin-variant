#!/usr/bin/env python

import os
import subprocess
import hashlib
import json
import argparse
import re
import ruamel.yaml
import redis


DOC_VERSION = "0.0.1"


def item(path, version, checksum_method, checksum_value):

    if checksum_method and checksum_value:
        checksum = "{}${}".format(checksum_method, checksum_value)
    else:
        checksum = "n/a"

    return {
        "path": path,
        "version": version,
        "checksum": checksum
    }


def read(filename):
    """return file contents"""

    with open(filename, 'r') as file_in:
        return file_in.read()


def write(filename, cwl):
    """write to file"""

    with open(filename, 'w') as file_out:
        file_out.write(cwl)


def get_references(inputs_yaml_path):
    "get references"

    references = {}

    # read inputs.yaml
    yaml = ruamel.yaml.load(
        read(inputs_yaml_path),
        ruamel.yaml.RoundTripLoader
    )

    if "genome" in yaml:
        references["genome"] = yaml["genome"]

    if "hapmap" in yaml:
        references["hapmap"] = item(
            path=yaml["hapmap"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["hapmap"]["path"])
        )

    if "dbsnp" in yaml:
        references["dbsnp"] = item(
            path=yaml["dbsnp"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["dbsnp"]["path"])
        )

    if "indels_1000g" in yaml:
        references["indels_1000g"] = item(
            path=yaml["indels_1000g"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["indels_1000g"]["path"])
        )

    if "snps_1000g" in yaml:
        references["snps_1000g"] = item(
            path=yaml["snps_1000g"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["snps_1000g"]["path"])
        )

    if "cosmic" in yaml:
        references["cosmic"] = item(
            path=yaml["cosmic"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["cosmic"]["path"])
        )

    if "refseq" in yaml:
        references["refseq"] = item(
            path=yaml["refseq"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(yaml["refseq"]["path"])
        )

    return references


# fixme: common
def run(cmd, shell=False, strip_newline=True):
    "run a command"

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=shell)
    stdout = process.stdout.read()
    if strip_newline:
        stdout = stdout.rstrip("\n")
    return stdout


# fixme: common
def generate_sha1(filename):
    "generate SHA1 hash out of file"

    # 64kb chunks
    buf_size = 65536

    sha1 = hashlib.sha1()

    with open(filename, 'rb') as f:
        while True:
            data = f.read(buf_size)
            if not data:
                break
            sha1.update(data)

    return sha1.hexdigest()


def get_singularity_info():
    "get singularity info"

    path = os.environ.get("PRISM_SINGULARITY_PATH")

    version = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_roslin_info():
    "get roslin info"

    # fixme: roslin
    version = os.environ.get("PRISM_VERSION")
    path = os.environ.get("PRISM_BIN_PATH")

    return item(
        path=path,
        version=version,
        checksum_method=None,
        checksum_value=None
    )


def get_cmo_pkg_info():
    "get cmo package info"

    path = run(["which", "cmo_bwa_mem"])
    bin_path = os.environ.get("PRISM_BIN_PATH")
    res_json_path = os.path.join(bin_path, "pipeline/1.0.0/prism_resources.json")

    cmd = 'CMO_RESOURCE_CONFIG="{}" python -c "import cmo; print cmo.__version__"'.format(res_json_path)
    version = run(cmd, True)

    return item(
        path=path,
        version=version,
        checksum_method=None,
        checksum_value=None
    )


def get_cwltoil_info():
    "get cwltoil info"

    path = run(["which", "cwltoil"])

    version = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_node_info():
    "get node info"

    path = run(["which", "node"])

    version = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_bioinformatics_software_version(cmdline):
    "get bioinformatics software version from command-line"

    version = "unknown"

    # fixme: pre-compile regex

    if cmdline.startswith("cmo_"):
        # cmo_fillout --version 1.2.1 --bams /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpS6aqu1/stg29923382-4f57-4c0c-8d60-4535ba29df76/Proj_06049_Pool_indelRealigned_recal_s_UD_ffpepool1_N.bam --genome GRCh37 --maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpS6aqu1/stg9817baee-e905-46be-8786-2ee268ac4744/DU874145-T.combined-variants.vep.rmv.fillout.maf
        # cmo_gatk -T CombineVariants --version 3.3-0 --genotypemergeoption PRIORITIZE --java_args '-Xmx48g -Xms256m -XX:-UseGCOverheadLimit' --out DU874145-T.combined-variants.vcf --reference_sequence GRCh37 --rod_priority_list VarDict,MuTect,SomaticIndelDetector,Pindel --unsafe ALLOW_SEQ_DICT_INCOMPATIBILITY --variant:MuTect /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg5ab3984b-e1b5-4f0b-b674-bed9751ff5c4/mutect-norm.vcf --variant:Pindel /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg78805a6c-ca48-4fd2-acbd-e9c1d688201a/pindel-norm.vcf --variant:SomaticIndelDetector /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg880a5b93-61f6-4d4d-8aae-def851518761/sid-norm.vcf --variant:VarDict /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg0e559e5f-ae73-48e7-b6ae-2f2ecaaa1c69/vardict-norm.vcf
        # cmo_vcf2maf --custom-enst /usr/bin/vcf2maf/data/isoform_overrides_at_mskcc --filter-vcf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpjAYWb9/stg044c2363-364d-4a64-a8ab-c17b43fd8051/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz --input-vcf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpjAYWb9/stg6f3ecae7-3ae5-4e71-9c12-cb0098e06db9/DU874145-T.combined-variants.vcf --maf-center mskcc.org --max-filter-ac 10 --min-hom-vaf 0.7 --ncbi-build GRCh37 --normal-id DU874145-N --output-maf DU874145-T.combined-variants.vep.maf --ref-fasta /ifs/work/chunj/prism-proto/ifs/depot/assemblies/H.sapiens/b37/b37.fasta --retain-info set,TYPE,FAILURE_REASON --species homo_sapiens --tmp-dir '/scratch/<username>/...' --tumor-id DU874145-T --vcf-normal-id DU874145-N --vcf-tumor-id DU874145-T --vep-data /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86 --vep-forks 4 --vep-path /usr/bin/vep/ --vep-release 86
        # cmo_bcftools norm --fasta-ref GRCh37 --output pindel-norm.vcf
        # --output-type v
        # /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpQqLuI7/stg236751d5-5a29-4760-9d43-68b380bbbbe3/DU874145-T.rg.md.abra.fmi.printreads.pindel_STDfilter.vcf
        match = re.search(r"--version (.*?)\s", cmdline)
        if match:
            version = match.group(1)
    elif cmdline.startswith("sing.sh"):
        # sing.sh basic-filtering 0.1.6 vardict --alleledepth 5 --totaldepth 0 --inputVcf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmptk5s_V/stg40644b70-9d21-47c8-a09e-52e827acf0b4/DU874145-T.rg.md.abra.fmi.printreads.vardict.vcf --tnRatio 5 --tsampleName DU874145-T --variantfrequency 0.01
        # sing.sh replace-allele-counts 0.1.1 --fillout /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmp1hUWm4/stg6ad9f673-22ee-4d07-ae5a-b2517cc74004/DU874145-T.combined-variants.vep.rmv.fillout --input-maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmp1hUWm4/stg1bc79f0d-4930-4d5f-ab59-feebd63cc605/DU874145-T.combined-variants.vep.rmv.maf --output-maf DU874145-T.combined-variants.vep.rmv.fillout.maf
        # sing.sh ngs-filters 1.1.4 --ffpe_pool_maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stg5e734d22-dae1-4854-908b-ba69d4a4bb65/DU874145-T.combined-variants.vep.rmv.ffpe-normal.fillout --normal-panel-maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stg58b57686-d51d-4d8a-a47c-664b911b7753/DU874145-T.combined-variants.vep.rmv.curated.fillout --input-hotspot /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stg28775ebc-b4e7-4d37-810b-4aa8b9fb0f62/hotspot-list-union-v1-v2.txt --input-maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stgf99ef4b3-5a10-44c6-ad1f-23b039fff9b4/DU874145-T.combined-variants.vep.rmv.fillout.maf --output-maf DU874145-T.maf
        # sing.sh remove-variants 0.1.1 --input-maf
        # /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpGkmuhb/stg7866a0f7-41d4-4731-ab80-c686de2dc2c8/DU874145-T.combined-variants.vep.maf
        # --output-maf DU874145-T.combined-variants.vep.rmv.maf
        match = re.search(r"sing.sh .*? (.*?)\s", cmdline)
        if match:
            version = match.group(1)

    return version


def get_bioinformatics_software_info(cwltoil_log):
    "get bioinformatics software info"

    sw_list = {}

    with open(cwltoil_log, "r") as log_file:
        log = log_file.read()

    # this method can cover non-cmo-pkg tools
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_    [job cmo-bwa-mem.cwl] /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpje5c7F$ cmo_bwa_mem \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --fastq1 \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpDv9yQE/stgcfbf51cd-dc37-4e11-a7df-96c8f96facc1/DU874145-T_R1.chunk000_cl.fastq.gz \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --fastq2 \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpDv9yQE/stg0f06777c-eeae-4dd4-89e1-99bdbb2dd844/DU874145-T_R2.chunk000_cl.fastq.gz \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --genome \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        GRCh37 \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --output \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        DU874145-T.chunk000.bam \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --version \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        default
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_    INFO:cwltool:[job cmo-bwa-mem.cwl] /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpje5c7F$ cmo_bwa_mem \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --fastq1 \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpDv9yQE/stgcfbf51cd-dc37-4e11-a7df-96c8f96facc1/DU874145-T_R1.chunk000_cl.fastq.gz \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --fastq2 \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpDv9yQE/stg0f06777c-eeae-4dd4-89e1-99bdbb2dd844/DU874145-T_R2.chunk000_cl.fastq.gz \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --genome \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        GRCh37 \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --output \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        DU874145-T.chunk000.bam \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        --version \
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_        default
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_    [job cmo-bwa-mem.cwl] completed success
#'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_    INFO:cwltool:[job cmo-bwa-mem.cwl] completed success

    matches = re.finditer(r"INFO:cwltool:(\[job .*?\].*?\w    )[\w\[]", log, re.DOTALL)

    for match1 in matches:
        raw_cmd = match1.group(1)

        # the regex captures extra that contains "completed success". ignore.
        if "completed success" in raw_cmd:
            continue

        # command constructor
        match2 = re.search(r"\[job (.*?)\].*?\$\s(.*)", raw_cmd)
        if match2:

            # get software name (e.g. cmo-bwa-mem.cwl)
            software_name = match2.group(1)

            # remove .cwl
            # replace . with - (MongoDB doesn't allow . in the field name)
            software_name = software_name.replace(".cwl", "").replace(".", "-")

            # if this is the first time this software appears
            if not software_name in sw_list:
                sw_list[software_name] = {
                    "cmdline": [],
                    "version": "unknown"
                }

            # this is the very first arg
            cmd = match2.group(2).rstrip("\\")

            # extract only the arguments
            match3 = re.finditer(r"$.*?\s{2,}(.*?)$", raw_cmd, re.DOTALL | re.MULTILINE)
            args = [arg.group(1).rstrip(" \\") for arg in match3]

            # construct the finall command line
            final_command_line = (cmd + " ".join(args)).rstrip()

            # there could be multiple command-lines under the same software
            # e.g. running bwa-mem two times
            sw_list[software_name]["cmdline"].append(final_command_line)

            # extract version from command-line args
            sw_list[software_name]["version"] = get_bioinformatics_software_version(final_command_line)

    # this only works for cmo-pkg tools
    # matches = re.finditer(r"'(.*?)'.*?call_cmd.*?:\s+(.*)", log, re.MULTILINE)

    # for match in matches:
    #     software_name = match.group(1)
    #     command = match.group(2)
    #     if software_name in sw_list:
    #         sw_list[software_name].append(command)
    #     else:
    #         sw_list[software_name] = [command]

    return sw_list


def make_runprofile(job_uuid, inputs_yaml_path, cwltoil_log_path):
    "make run profile"

    run_profile = {

        "version": DOC_VERSION,

        "pipelineJobId": job_uuid,

        "softwareUsed": {
            "roslin": get_roslin_info(),
            "cmo": get_cmo_pkg_info(),
            "singularity": get_singularity_info(),
            "cwltoil": get_cwltoil_info(),
            "node": get_node_info(),
            "bioinformatics": get_bioinformatics_software_info(cwltoil_log_path)
        },

        "references": get_references(inputs_yaml_path)
    }

    return run_profile


def publish_to_redis(job_uuid, run_profile):
    "publish to redis"

    # connect to redis
    # fixme: configurable host, port, credentials
    redis_client = redis.StrictRedis(host='pitchfork', port=9006, db=0)

    json_results = json.dumps(run_profile)

    redis_client.publish('roslin-run-profiles', json_results)
    redis_client.setex(job_uuid, 86400, json_results)


def main():
    "main function"

    parser = argparse.ArgumentParser(description='make_runprofile')

    parser.add_argument(
        "--job_uuid",
        action="store",
        dest="job_uuid",
        required=True
    )

    parser.add_argument(
        "--inputs_yaml",
        action="store",
        dest="inputs_yaml_path",
        help="Path to inputs.yaml",
        required=True
    )

    parser.add_argument(
        "--cwltoil_log",
        action="store",
        dest="cwltoil_log_path",
        help="Path to cwltoil.log",
        required=True
    )

    params = parser.parse_args()

    run_profile = make_runprofile(params.job_uuid, params.inputs_yaml_path, params.cwltoil_log_path)

    print json.dumps(run_profile, indent=2)

    publish_to_redis(params.job_uuid, run_profile)


if __name__ == "__main__":

    main()
