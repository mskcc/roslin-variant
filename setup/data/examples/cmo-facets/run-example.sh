#!/bin/bash

prism-runner.sh \
    -w cmo-facets.doFacets/1.5.4/cmo-facets.doFacets.cwl \
    -i inputs.yaml \
    -b singleMachine -d
