#!/bin/bash

sing.sh seq-cna 1.0.0 getPairedCounts \
    TUMOR=../data/from-module-2/DU874145-T.rg.md.abra.fmi.printreads.bam \
    NORMAL=../data/from-module-2/DU874145-N.rg.md.abra.fmi.printreads.bam

sing.sh seq-cna 1.0.0 seqSegment \
    COUNTS=DU874145-T.rg.md.abra.fmi.printreads___DU874145-N.rg.md.abra.fmi.printreads_Counts.rda
