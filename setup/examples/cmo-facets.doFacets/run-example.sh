#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w cmo-facets.doFacets/1.5.5/cmo-facets.doFacets.cwl \
    -i inputs.yaml \
    -b lsf
