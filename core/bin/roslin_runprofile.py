#!/usr/bin/env python

import os
import subprocess
import hashlib
import json
import logging
import argparse
import re
import ruamel.yaml
import redis


logger = logging.getLogger("roslin_runprofile")
logger.setLevel(logging.INFO)

# create a file log handler
log_file_handler = logging.FileHandler('roslin_runprofile.log')
log_file_handler.setLevel(logging.INFO)

# create a logging format
log_formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
log_file_handler.setFormatter(log_formatter)

# add the handlers to the logger
logger.addHandler(log_file_handler)

DOC_VERSION = "1.0.0"

IMG_METADATA_CACHE = {}
CWL_METADATA_CACHE = {}


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


def read_file(filename):
    """return file contents"""

    with open(filename, 'r') as file_in:
        return file_in.read()


def write_file(filename, data):
    """write to file"""

    with open(filename, 'w') as file_out:
        file_out.write(data)


def get_references(inputs_yaml_path):
    "get references"

    references = {}

    # read inputs.yaml
    yaml = ruamel.yaml.load(
        read_file(inputs_yaml_path),
        ruamel.yaml.RoundTripLoader
    )

    runparams = yaml["runparams"]
    db_files = yaml["db_files"]

    if "genome" in runparams:
        references["genome"] = runparams["genome"]

    if "hapmap" in db_files:
        references["hapmap"] = item(
            path=db_files["hapmap"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["hapmap"]["path"])
        )

    if "dbsnp" in db_files:
        references["dbsnp"] = item(
            path=db_files["dbsnp"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["dbsnp"]["path"])
        )

    if "indels_1000g" in db_files:
        references["indels_1000g"] = item(
            path=db_files["indels_1000g"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["indels_1000g"]["path"])
        )

    if "snps_1000g" in db_files:
        references["snps_1000g"] = item(
            path=db_files["snps_1000g"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["snps_1000g"]["path"])
        )

    if "cosmic" in db_files:
        references["cosmic"] = item(
            path=db_files["cosmic"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["cosmic"]["path"])
        )

    if "refseq" in db_files:
        references["refseq"] = item(
            path=db_files["refseq"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["refseq"]["path"])
        )

##
    if "hotspot_list" in db_files:
        references["hotspot_list"] = item(
            path=db_files["hotspot_list"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["hotspot_list"]["path"])
        )

    if "exac_filter" in db_files:
        references["exac_filter"] = item(
            path=db_files["exac_filter"]["path"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=generate_sha1(db_files["exac_filter"]["path"])
        )

    if "vep_data" in db_files:
        references["vep_data"] = item(
            path=db_files["vep_data"],
            version="x.y.z",
            checksum_method="sha1",
            checksum_value=None
        )

    return references


# fixme: common
def run(cmd, shell=False, strip_newline=True):
    "run a command and return (stdout, stderr, exit code)"

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=shell)

    stdout, stderr = process.communicate()

    if strip_newline:
        stdout = stdout.rstrip("\n")
        stderr = stderr.rstrip("\n")

    return stdout, stderr, process.returncode


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

    path = os.environ.get("ROSLIN_SINGULARITY_PATH")

    version, _, _ = run([path, "--version"])

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
    version = os.environ.get("ROSLIN_VERSION")
    path = os.environ.get("ROSLIN_BIN_PATH")

    return item(
        path=path,
        version=version,
        checksum_method=None,
        checksum_value=None
    )


def get_cmo_pkg_info():
    "get cmo package info"

    # __version__
    # __file__
    # __path__
    cmd = 'python -s -c "import cmo,os; print cmo.__version__, os.path.abspath(cmo.__file__), os.path.abspath(cmo.__path__[0])"'
    stdout, _, _ = run(cmd, shell=True)

    # fixme: command return nothing in other user's env
    if stdout.strip() == "":
        return None

    version, init_pyc, path = stdout.split()

    # checksum on __init__.pyc
    sha1 = generate_sha1(init_pyc)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_cwltoil_info():
    "get cwltoil info"

    path, _, _ = run(["which", "cwltoil"])

    # version is returned to stderr
    _, version, _ = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_node_info():
    "get node info"

    path, _, _ = run(["which", "node"])

    version, _, _ = run([path, "--version"])

    sha1 = generate_sha1(path)

    return item(
        path=path,
        version=version,
        checksum_method="sha1",
        checksum_value=sha1
    )


def get_bioinformatics_software_version(cmd0, cmdline):
    "get bioinformatics software version from command-line"

    version = "unknown"

    # fixme: pre-compile regex

    if cmdline.startswith("cmo_"):
        # e.g.
        # cmo_fillout --version 1.2.1 --bams /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpS6aqu1/stg29923382-4f57-4c0c-8d60-4535ba29df76/Proj_06049_Pool_indelRealigned_recal_s_UD_ffpepool1_N.bam --genome GRCh37 --maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpS6aqu1/stg9817baee-e905-46be-8786-2ee268ac4744/DU874145-T.combined-variants.vep.rmv.fillout.maf
        # cmo_gatk -T CombineVariants --version 3.3-0 --genotypemergeoption PRIORITIZE --java_args '-Xmx48g -Xms256m -XX:-UseGCOverheadLimit' --out DU874145-T.combined-variants.vcf --reference_sequence GRCh37 --rod_priority_list VarDict,MuTect,SomaticIndelDetector,Pindel --unsafe ALLOW_SEQ_DICT_INCOMPATIBILITY --variant:MuTect /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg5ab3984b-e1b5-4f0b-b674-bed9751ff5c4/mutect-norm.vcf --variant:Pindel /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg78805a6c-ca48-4fd2-acbd-e9c1d688201a/pindel-norm.vcf --variant:SomaticIndelDetector /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg880a5b93-61f6-4d4d-8aae-def851518761/sid-norm.vcf --variant:VarDict /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpcLzgrB/stg0e559e5f-ae73-48e7-b6ae-2f2ecaaa1c69/vardict-norm.vcf
        # cmo_vcf2maf --custom-enst /usr/bin/vcf2maf/data/isoform_overrides_at_mskcc --filter-vcf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpjAYWb9/stg044c2363-364d-4a64-a8ab-c17b43fd8051/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz --input-vcf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpjAYWb9/stg6f3ecae7-3ae5-4e71-9c12-cb0098e06db9/DU874145-T.combined-variants.vcf --maf-center mskcc.org --max-filter-ac 10 --min-hom-vaf 0.7 --ncbi-build GRCh37 --normal-id DU874145-N --output-maf DU874145-T.combined-variants.vep.maf --ref-fasta /ifs/work/chunj/prism-proto/ifs/depot/assemblies/H.sapiens/b37/b37.fasta --retain-info set,TYPE,FAILURE_REASON --species homo_sapiens --tmp-dir '/scratch/<username>/...' --tumor-id DU874145-T --vcf-normal-id DU874145-N --vcf-tumor-id DU874145-T --vep-data /ifs/work/chunj/prism-proto/ifs/depot/resources/vep/v86 --vep-forks 4 --vep-path /usr/bin/vep/ --vep-release 86
        # cmo_bcftools norm --fasta-ref GRCh37 --output pindel-norm.vcf
        # --output-type v
        # /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpQqLuI7/stg236751d5-5a29-4760-9d43-68b380bbbbe3/DU874145-T.rg.md.abra.fmi.printreads.pindel_STDfilter.vcf
        match = re.search(r"--version (.*?)(\s|$)", cmdline)
        if match:
            version = match.group(1)
    elif cmdline.startswith("sing.sh"):
        # e.g.
        # sing.sh basic-filtering 0.1.6 vardict --alleledepth 5 --totaldepth 0 --inputVcf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmptk5s_V/stg40644b70-9d21-47c8-a09e-52e827acf0b4/DU874145-T.rg.md.abra.fmi.printreads.vardict.vcf --tnRatio 5 --tsampleName DU874145-T --variantfrequency 0.01
        # sing.sh replace-allele-counts 0.1.1 --fillout /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmp1hUWm4/stg6ad9f673-22ee-4d07-ae5a-b2517cc74004/DU874145-T.combined-variants.vep.rmv.fillout --input-maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmp1hUWm4/stg1bc79f0d-4930-4d5f-ab59-feebd63cc605/DU874145-T.combined-variants.vep.rmv.maf --output-maf DU874145-T.combined-variants.vep.rmv.fillout.maf
        # sing.sh ngs-filters 1.1.4 --ffpe_pool_maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stg5e734d22-dae1-4854-908b-ba69d4a4bb65/DU874145-T.combined-variants.vep.rmv.ffpe-normal.fillout --normal-panel-maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stg58b57686-d51d-4d8a-a47c-664b911b7753/DU874145-T.combined-variants.vep.rmv.curated.fillout --input-hotspot /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stg28775ebc-b4e7-4d37-810b-4aa8b9fb0f62/hotspot-list-union-v1-v2.txt --input-maf /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpTpF0kC/stgf99ef4b3-5a10-44c6-ad1f-23b039fff9b4/DU874145-T.combined-variants.vep.rmv.fillout.maf --output-maf DU874145-T.maf
        # sing.sh remove-variants 0.1.1 --input-maf
        # /ifs/work/chunj/prism-proto/ifs/prism/outputs/995fa9a4/995fa9a4-5089-11e7-a370-645106efb11c/outputs/tmpGkmuhb/stg7866a0f7-41d4-4731-ab80-c686de2dc2c8/DU874145-T.combined-variants.vep.maf
        # --output-maf DU874145-T.combined-variants.vep.rmv.maf
        match = re.search(r"sing.sh .*? (.*?)\s", cmdline)
        if match:
            version = match.group(1)

    # fixme: revise cwl so that baseCommand has something like --version
    if version == "unknown":
        if cmd0.startswith("cmo_split_reads"):
            version = "1.0.0"
        elif cmd0.startswith("cmo_index"):
            version = "1.0.0"
        elif cmd0.startswith("cmo_trimgalore"):
            version = "0.2.5.mod"
        elif cmd0.startswith("cmo_vcf2maf"):
            version = "1.6.12"
        elif cmd0.startswith("cmo_bcftools"):
            version = "1.3.1"
        elif cmd0.startswith("cmo_abra"):
            version = "0.92"
        elif cmdline.startswith("cmo_picard --cmd AddOrReplaceReadGroups"):
            version = "1.96"
        elif cmdline.startswith("cmo_picard --cmd MarkDuplicates"):
            version = "1.96"
        elif cmdline.startswith("cmo_picard --cmd FixMateInformation"):
            version = "1.96"

    return version


def get_img_metadata(sing_cmdline):
    "get singularity image metadata by running sing.sh with -i"

    cache_key = " ".join(sing_cmdline.split(" ")[:3])
    if cache_key in IMG_METADATA_CACHE:
        return IMG_METADATA_CACHE[cache_key]

    # add -i to run in inspection mode
    sing_cmdline = sing_cmdline.replace("sing.sh", "sing.sh -i")

    metadata, _, exitcode = run(sing_cmdline, shell=True)

    if exitcode != 0:
        out = {
            "error": "not found"
        }
    else:
        # convert to json
        metadata = json.loads(metadata)

        # remove maintainer
        del metadata["maintainer"]

        # MongoDB doesn't like dots in the field name
        out = {}
        for key, value in metadata.iteritems():
            out[key.replace(".", "-")] = value

    IMG_METADATA_CACHE[cache_key] = out

    return out


def lookup_cmo_sing_cmdline(cmd0, version):
    """
    for a given cmo command and version, get sing command-line by looking up roslin_resources.json
    e.g. cmo0 = cmo_trimgalore
         version = 0.2.5.mod
    """

    try:
        # read roslin_resources.json
        bin_path = os.environ.get("ROSLIN_BIN_PATH")
        res_json_path = os.path.join(bin_path, "pipeline/1.0.0/roslin_resources.json")
        resources = json.loads(read_file(res_json_path))

        # may or may not be trailing whitespaces
        cmd0 = cmd0.rstrip()

        # mapping between cmo_* and key in roslin_resources.json
        # fixme: handle some special cases
        if cmd0 == "cmo_split_reads":
            cmd0 = "split-reads"
        elif cmd0 == "cmo_fillout":
            cmd0 = "getbasecountsmultisample"
        else:
            cmd0 = cmd0.split("_")[1]

        sing_cmdline = resources["programs"][cmd0][version]

        return sing_cmdline

    except Exception:
        return None


def get_cwl_metadata(cwl_filename, version):
    "get cwl metadata"

    cache_key = cwl_filename + ":" + version
    if cache_key in CWL_METADATA_CACHE:
        return CWL_METADATA_CACHE[cache_key]

    # fixme: this will fail if different users work on different bin base
    bin_path = os.environ.get("ROSLIN_BIN_PATH")
    cwl_path = os.path.join(
        bin_path, "pipeline/1.0.0/",
        cwl_filename.replace(".cwl", ""), version, cwl_filename
    )

    try:
        cwl_str = read_file(cwl_path)
        yaml = ruamel.yaml.load(
            cwl_str,
            ruamel.yaml.RoundTripLoader
        )

        out = {
            "path": cwl_path,
        }

        try:
            for ver in yaml["doap:release"]:
                key = ("version-" + ver["doap:name"]).replace(".", "-")
                out[key] = ver["doap:revision"]
        except Exception:
            pass

    except Exception:
        out = {
            "error": "not found"
        }

    CWL_METADATA_CACHE[cache_key] = out

    return out


def get_toil_log_level(log):
    "get toil log level"

    match = re.search(r"'toil' logger at level '(.*?)'", log)

    if match:
        return match.group(1)
    else:
        return None


def get_bioinformatics_software_info_loglevel_INFO(log):
    "get bioinformatics software info when log level is set to INFO"

    sw_list = {}

    already_processed = {}

    matches = re.finditer(r"Issued job '(.*?)'.*(\w\/\w\/job\w{6})", log)

    for match1 in matches:

        base_cmd = match1.group(1)

        # skip if already processed,
        # otherwise mark as processed so that we don't reprocess again next round
        if base_cmd in already_processed:
            continue
        else:
            already_processed[base_cmd] = "1"

        # replace . with - (MongoDB doesn't allow . in the field name)
        if base_cmd.startswith("sing.sh"):
            software_name = base_cmd.split()[1]
        elif base_cmd.startswith("cmo_"):
            if base_cmd.startswith("cmo_gatk"):
                software_name = base_cmd.replace(" -T ", "-")
            elif base_cmd.startswith("cmo_picard"):
                software_name = base_cmd.replace(" --cmd ", "-")
            else:
                software_name = base_cmd
            software_name = re.sub(r"--version .*[\s]?", "", software_name).rstrip()
        software_name = software_name.replace(".", "-").replace(" ", "-").replace("_", "-")

        # if this is the first time this software appears
        if not software_name in sw_list:
            sw_list[software_name] = []

        entry = {
            "cmdline": None,
            "img": None,
            "cwl": None
        }

        # this is the very first arg
        # either "sing.sh" or "cmo_*"
        cmd0 = base_cmd.split()[0]

        entry["cmdline"] = base_cmd

        # extract version from command-line args
        version = get_bioinformatics_software_version(cmd0, base_cmd)

        # if this is the first time this version appears for this software
        if cmd0.startswith("sing.sh"):
            entry["img"] = get_img_metadata(base_cmd)
        elif cmd0.startswith("cmo_"):
            sing_cmdline = lookup_cmo_sing_cmdline(cmd0, version)
            if sing_cmdline:
                entry["img"] = get_img_metadata(sing_cmdline)

        sw_list[software_name].append(entry)

    return sw_list


def get_bioinformatics_software_info_loglevel_DEBUG(log):
    "get bioinformatics software info when log level is set to DEBUG"

    sw_list = {}

    # this method can cover non-cmo-pkg tools
    # e.g.
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

    already_processed = {}

    matches = re.finditer(r"INFO:cwltool:(\[job .*?\].*?\w    )[\w\[]", log, re.DOTALL)

    for match1 in matches:
        raw_cmd = match1.group(1)

        # fixme: toil has a logging bug that repeats the same log message over and over again
        # in general module-1-2-3.chunk.cwl generates 2MB, but we experienced 412MB log file.
        # this causes profiling forever
        # so, extract unique temp dir assigned to each job
        # and use this to not repeat already processed job
        # e.g.
        # x/z/job9Tx8l_ in 'cmo_bwa_mem' cmo_bwa_mem x/z/job9Tx8l_    [job
        # cmo-bwa-mem.cwl]
        # /ifs/work/chunj/prism-proto/ifs/prism/outputs/35cd528a/35cd528a-50a0-11e7-817f-645106efb11c/outputs/tmpje5c7F$
        # cmo_bwa_mem \

        match_job_tmp_dir = re.search(r"(\w\/\w\/job\w{6})", raw_cmd)
        job_tmp_dir = match_job_tmp_dir.group(1) if match_job_tmp_dir else None

        # skip if already processed,
        # otherwise mark as processed so that we don't reprocess again next round
        if job_tmp_dir in already_processed:
            continue
        else:
            already_processed[job_tmp_dir] = "1"

        # the regex captures extra that contains "completed success". ignore.
        if "completed success" in raw_cmd:
            continue

        # command constructor
        match2 = re.search(r"\[job (.*?)\].*?\$\s(.*)", raw_cmd)
        if match2:

            # get software name (e.g. cmo-bwa-mem.cwl)
            cwl_filename = match2.group(1)

            # remove .cwl
            # replace . with - (MongoDB doesn't allow . in the field name)
            software_name = cwl_filename.replace(".cwl", "").replace(".", "-")

            # if this is the first time this software appears
            if not software_name in sw_list:
                sw_list[software_name] = []

            entry = {
                "cmdline": None,
                "img": None,
                "cwl": None
            }

            # this is the very first arg
            # either "sing.sh" or "cmo_*"
            cmd0 = match2.group(2).rstrip("\\")

            # extract only the arguments
            match3 = re.finditer(r"$.*?\s{2,}(.*?)$", raw_cmd, re.DOTALL | re.MULTILINE)
            args = [arg.group(1).rstrip(" \\") for arg in match3]

            # construct the finall command line
            final_command_line = (cmd0 + " ".join(args)).rstrip()
            entry["cmdline"] = final_command_line

            # extract version from command-line args
            version = get_bioinformatics_software_version(cmd0, final_command_line)

            # if this is the first time this version appears for this software
            if cmd0.startswith("sing.sh"):
                entry["img"] = get_img_metadata(final_command_line)
            elif cmd0.startswith("cmo_"):
                sing_cmdline = lookup_cmo_sing_cmdline(cmd0, version)
                if sing_cmdline:
                    entry["img"] = get_img_metadata(sing_cmdline)

            if cwl_filename + version in CWL_METADATA_CACHE:
                entry["cwl"] = CWL_METADATA_CACHE[cwl_filename + version]
            else:
                entry["cwl"] = get_cwl_metadata(cwl_filename, version)

            sw_list[software_name].append(entry)

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


def get_bioinformatics_software_info(cwltoil_log):
    "get bioinformatics software info"

    log = read_file(cwltoil_log)

    log_level = get_toil_log_level(log)

    if log_level == "INFO":
        return get_bioinformatics_software_info_loglevel_INFO(log)
    elif log_level == "DEBUG":
        return get_bioinformatics_software_info_loglevel_DEBUG(log)
    else:
        return {}


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
        "--job-uuid",
        action="store",
        dest="job_uuid",
        required=True
    )

    parser.add_argument(
        "--work-dir",
        action="store",
        dest="work_dir",
        help="toil working directory",
        required=True
    )

    parser.add_argument(
        "--cwltoil-log",
        action="store",
        dest="cwltoil_log_path",
        help="Path to cwltoil.log",
        required=True
    )

    params = parser.parse_args()

    try:

        inputs_yaml_path = os.path.join(params.work_dir, "inputs.yaml")

        # generate run-profile
        run_profile = make_runprofile(params.job_uuid, inputs_yaml_path, params.cwltoil_log_path)

        # display run-profile to screen
        print json.dumps(run_profile, indent=2)

        # write run-profile to a file
        write_file(
            os.path.join(params.work_dir, "run-profile.json"),
            json.dumps(run_profile, indent=2)
        )

        # publish run-profile to redis
        publish_to_redis(params.job_uuid, run_profile)

    except Exception as e:
        logger.error(repr(e))


if __name__ == "__main__":

    main()
