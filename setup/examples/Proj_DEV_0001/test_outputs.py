#!/usr/bin/python

import re
from nose.tools import assert_equals
from nose.tools import assert_true
from nose.tools import nottest


def get_cmdline(log, software_name):
    "get command-line for a given software in the log file"

    cmdlines = []

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
            cwl_filename = match2.group(1)

            # remove .cwl
            found_software_name = cwl_filename.replace(".cwl", "")

            if software_name != found_software_name:
                continue

            # this is the very first arg
            # either "sing.sh" or "cmo_*"
            cmd0 = match2.group(2).rstrip("\\")

            # extract only the arguments
            match3 = re.finditer(r"$.*?\s{2,}(.*?)$", raw_cmd, re.DOTALL | re.MULTILINE)
            args = [arg.group(1).rstrip(" \\") for arg in match3]

            # construct the finall command line
            final_command_line = (cmd0 + " ".join(args)).rstrip()

            cmdlines.append(final_command_line)

    return cmdlines


class TestUM(object):
    "system under test"

    def __init__(self):
        with open('outputs/log/cwltoil.log', 'rt') as flog:
            self.log = flog.read()

    def setup(self):
        "setup before each test method"
        pass

    def teardown(self):
        "teardown after each test method"
        pass

    @classmethod
    def setup_class(cls):
        "setup before any methods in this class"
        pass

    @classmethod
    def teardown_class(cls):
        "teardown after any methods in this class"
        pass

    def test_cmo_gatk_print_reads(self):
        "cmo-gatk.PrintReads should run with --read_filter BadCigar"

        cmdlines = get_cmdline(self.log, 'cmo-gatk.PrintReads')
        for cmdline in cmdlines:
            assert_true("--read_filter BadCigar" in cmdline)

    def test_cmo_gatk_base_recalibrator(self):
        "cmo-gatk.BaseRecalibrator should run with --read_filter BadCigar"

        cmdlines = get_cmdline(self.log, 'cmo-gatk.BaseRecalibrator')
        for cmdline in cmdlines:
            assert_true("--read_filter BadCigar" in cmdline)
