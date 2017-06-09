#!/bin/bash

PYTHONPATH=/usr/local/lib/python2.7/site-packages/gxargparse-0.3.1-py2.7.egg \
    python /usr/bin/ngs-filters/run_ngs-filters.py \
    --generate_cwl_tool \
    --directory /data