#!/usr/bin/env python

import argparse
import sys
import re
import os
import fnmatch
from collections import OrderedDict
import numpy as np
import pandas as pd

def usage():
    print "/opt/bin/python mergeGcBiasMetrics.py --files <space-delimited file names> --output <output file name>"
    return

## create a list of full paths to files that match pattern entered
def findFiles(rootDir,pattern):
    """
    create and return a list of full paths to files that match pattern entered
    """
    filepaths = []
    for path, dirs, files in os.walk(os.path.abspath(rootDir)):
        if fnmatch.filter(files, pattern):
            for file in fnmatch.filter(files, pattern):
                filepaths.append(os.path.join(path,file))
        else:
            if "Proj" in path.split("/")[-1] and "-" in path.split("/")[-1]:
                print>>sys.stderr, "WARNING: No files matching pattern %s found in %s" %(pattern, path)

    return filepaths

# def printMatrix(matrix,allSamps,outFile):
#     """
#     """

#     header = "\t".join(["GC"]+allSamps)

#     with open(outFile,'w') as out:
#         print>>out,header
#         for gc in matrix.keys():
#             for samp in allSamps:
#                 if not samp in matrix[gc]:
#                     matrix[gc][samp] = 0 
#             print>>out,"\t".join([str(x) for x in [gc]+[matrix[gc][samp] for samp in allSamps]])
#     return

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

    files = args.files
    outFile = args.output
    if files:
        printfile = open(outFile, 'w')
        print>>printfile, 'sample\tgc\tnormcoverage'

        print>>sys.stderr, "\nCombining the following files:\n"
        for file in files:
            print>>sys.stderr, file
            if os.stat(file)[6]==0: ## file is empty
                print>>sys.stderr, "WARNING: This file is empty!"
            else:
                fname = file.split("/")[-1].replace(".txt","")
#                pat_idx = fname.index(filePattern.replace("*",""))
                (samp, _) = fname.split(".", 1) ### WARNING: this is dumb as it assumes a certain pattern and should only be used with current naming convention of GCbias metrics files!
                if samp in allSamps:
                    print "ERROR: sample %s found multiple times!!" %samp
                    continue
                else:
                    allSamps.append(samp)

            df = pd.read_csv(file, sep='\t')
            gcbinlist = np.arange(.3, .9, .05)
            gcbinlist = ['%.2f' % x for x in gcbinlist]
            gcdict = {}
            ncdict = {}
            for gckey in gcbinlist:
                gcdict[gckey] = []
                ncdict[gckey] = []
            for g, n in zip(df['%gc'], df['normalized_coverage']):
                if .30 > g:
                    gcdict['0.30'].append(g)
                    ncdict['0.30'].append(n)
                elif .30 <= g < .35:
                    gcdict['0.35'].append(g)
                    ncdict['0.35'].append(n)
                elif .35 <= g < .40:
                    gcdict['0.40'].append(g)
                    ncdict['0.40'].append(n)
                elif .40 <= g < .45:
                    gcdict['0.45'].append(g)
                    ncdict['0.45'].append(n)
                elif .45 <= g < .50:
                    gcdict['0.50'].append(g)
                    ncdict['0.50'].append(n)
                elif .50 <= g < .55:
                    gcdict['0.55'].append(g)
                    ncdict['0.55'].append(n)
                elif .55 <= g < .60:
                    gcdict['0.60'].append(g)
                    ncdict['0.60'].append(n)
                elif .60 <= g < .65:
                    gcdict['0.65'].append(g)
                    ncdict['0.65'].append(n)
                elif .65 <= g < .70:
                    gcdict['0.70'].append(g)
                    ncdict['0.70'].append(n)
                elif .70 <= g < .75:
                    gcdict['0.75'].append(g)
                    ncdict['0.75'].append(n)
                elif .75 <= g < .80:
                    gcdict['0.80'].append(g)
                    ncdict['0.80'].append(n)
                elif g >= .80:
                    gcdict['0.85'].append(g)
                    ncdict['0.85'].append(n)

            for gckey in gcbinlist:
                samplename = file.split('/')[-1].split('.')[0]
                if sum(gcdict[gckey]) == 0:
                    pass
                else:
                    print>>printfile, "%s\t%f\t%f" % (samplename, np.mean(gcdict[gckey]), np.mean(ncdict[gckey]))
                    # print "%s\t%f\t%f" % (samplename, np.mean(gcdict[gckey]), np.mean(ncdict[gckey]))


                # with open(file, 'r') as fl:
                #     for line in fl:
                #         line = line.rstrip()
                #         print line

                #         header = line.strip("\n").split("\t")
                #         gc_idx = header.index("GC")
                #         nc_idx = header.index("NORMALIZED_COVERAGE")
                #         cols = line.strip().split("\t")
                #         gc = cols[gc_idx]
                #         nc = cols[nc_idx]
                #         if not gc in matrix:
                #             matrix[gc] = {}
                #         if not samp in matrix[gc]:
                #             matrix[gc][samp] = nc                        

        # printMatrix(matrix,allSamps,outFile)            

    else:
        print>>sys.stderr, "\nNo files found matching pattern entered. Exiting.\n"
        sys.exit(-1)

if __name__ == '__main__':
    makeMatrix()
