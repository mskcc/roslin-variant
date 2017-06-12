#!/usr/bin/env python

import glob
from jinja2 import Template


def write_to_disk(filename, yaml):
    "write to disk"

    with open(filename, "w") as file_out:
        file_out.write(yaml)


def generate(path_to_bams):
    "generate input yaml"

    file_list = glob.glob(path_to_bams)

    template = Template("""
maf:
  class: File
  path: ../data/from-module-4/DU874145-T.combined-variants.vep.rmv.maf
output_format: '1'
genome: GRCh37
bams:
{%- for file in files %}
  - class: File
    path: {{ file }}
{%- endfor %}

""")

    yaml = template.render(files=file_list)

    return yaml


def main():
    "main function"

    # fillout for curated BAM's
    yaml = generate('/ifs/work/zeng/dmp/resources/StdNormal/Impact410/20161202/Bam/*.bam')
    write_to_disk("inputs.yaml", yaml)


if __name__ == "__main__":

    main()
