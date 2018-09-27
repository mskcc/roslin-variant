#!/usr/bin/env python

# This is a python port of mergePicardMetrics.pl

import argparse
import sys
import os

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--output")
    parser.add_argument("--files", nargs="+")

    args = parser.parse_args()

    files = args.files
    outFile = args.output
    hflag = 0
    for f in files:
        mflag = 0
        with open(f, 'rb') as current_file:
            for line in current_file:
                line= line.strip()
                if line.find("## METRICS CLASS") != -1:
                    if mflag == 0:
                        mflag = 1
                    header = current_file.next()
                    if hflag == 0:
                        print(header)
                        hflag =1    
                else:
                    if mflag == 0:
                        continue
                    else:
                        if line:
                            print(line)
                        else:
                            break

if __name__ == '__main__':
    main()
