#!/usr/bin/env python

import argparse
import sys
import re
import os
import fnmatch
from collections import OrderedDict

#####################################
## Find all count files matching pattern entered by user (there should be one count file
## per sample) and create a matrix with one row for each gene and one column for each sample
#####################################

def usage():
    print "You dun goofed"
    return


## create a list of full paths to files that match pattern entered

def printMatrix(matrix,allSamps,outFile):
    """
    """

    header = "\t".join(["InsertSize"]+allSamps)

    with open(outFile,'w') as out:
        print>>out,header
        for insertSize in matrix.keys():
            for samp in allSamps:
                if not samp in matrix[insertSize]:
                    matrix[insertSize][samp] = 0 
            print>>out,"\t".join([str(x) for x in [insertSize]+[matrix[insertSize][samp] for samp in allSamps]])
    return

def makeMatrix():
    """
    Find files to parse, create one matrix of all counts and print 
    matrix to file
    """

    parser = argparse.ArgumentParser()
    parser.add_argument("--output")
    parser.add_argument("--files", nargs="+")

    args = parser.parse_args()

    ## store all values in an ordered dict, keyed by sample
    matrix = OrderedDict()
    allSamps = []

    ## find all cutadapt stats files using pattern 
    #files = findFiles(rootDir,filePattern)

    files = args.files
    outFile = args.output

    if files:
        print>>sys.stderr, "\nCombining the following files:\n"
        for file in files:
            if 'Histogram' in file:
                continue
            print>>sys.stderr, file
            if os.stat(file)[6]==0: ## file is empty
                print>>sys.stderr, "WARNING: This file is empty!"
            else:
                with open(file,'r') as fl:
                    while not "## HISTOGRAM" in fl.readline():
                       next
                    samp = fl.readline().strip().split("\t")[1].split(".fr_count")[0] 
                    if samp in allSamps:
                        print "ERROR: sample %s found multiple times!!" %samp
                        continue
                    else:
                        allSamps.append(samp)
                    for line in fl:
                        if len(line.strip())>0:
                            cols = line.strip().split("\t")
                            insertSize = cols[0]
                            count = cols[1]
                            if not insertSize in matrix:
                                matrix[insertSize] = {}
                            if not samp in matrix[insertSize]:
                                matrix[insertSize][samp] = count                        

        printMatrix(matrix,allSamps,outFile)            

    else:
        print>>sys.stderr, "\nNo files found matching pattern entered. Exiting.\n"
        sys.exit(-1)

if __name__ == '__main__':
    makeMatrix()
