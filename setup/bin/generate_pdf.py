#!/usr/bin/env python

import sys, os, re, argparse, glob, subprocess
import fnmatch


def find_files(directory, pattern='*'):
    if not os.path.exists(directory):
        raise ValueError("Directory not found {}".format(directory))

    matches = []
    for root, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            full_path = os.path.join(root, filename)
            if fnmatch.filter([full_path], pattern):
                matches.append(os.path.join(root, filename))
    return matches



if __name__ == "__main__":
    path = os.path.dirname(os.path.realpath(__file__))

    parser = argparse.ArgumentParser()
    parser.add_argument("--gcbias-files", default="*.hstmetrics")
    parser.add_argument("--mdmetrics-files", default="*.md_metrics")
    parser.add_argument("--insertsize-files", default="*.ismetrics")
    parser.add_argument("--hsmetrics-files", default="*.hsmetrics")
    parser.add_argument("--qualmetrics-files", default="*.quality_by_cycle_metrics")
    parser.add_argument("--fingerprint-files", default="*_FP_base_counts.txt")
    parser.add_argument("--trimgalore-files", default="*_cl.stats")
    parser.add_argument("--globdir", required=True)
    parser.add_argument("--file-prefix", required=True)
    parser.add_argument("--fp-genotypes", required=True)
    parser.add_argument("--pairing-file", required=True)
    parser.add_argument("--grouping-file", required=True)
    parser.add_argument("--request-file", required=True)
    parser.add_argument("--minor-contam-threshold", default=".02")
    parser.add_argument("--major-contam-threshold", default=".55")
    parser.add_argument("--duplication-threshold", default="80")
    parser.add_argument("--cov-warn-threshold", default="200")
    parser.add_argument("--cov-fail-threshold", default="50")
    args = parser.parse_args()
    path_to_search = "/".join(args.globdir.split("/")[:-1])
    print "Search path: %s" % path_to_search
    datapath = os.path.dirname(os.path.realpath(args.request_file))
    print >>sys.stderr, "Generating merged picard metrics (Mark Dups, Hs Metrics)..."
    outfilenames = [ args.file_prefix + "_markDuplicatesMetrics.txt", args.file_prefix + "_HsMetrics.txt"]
    for i, files in enumerate([args.mdmetrics_files, args.hsmetrics_files]):
        temp_fh = open("temp_fof", "wb")
        filenames = find_files(path_to_search, pattern=files)
        uniquelist = []
        for name in filenames:
            print name
            rootname = name.split('/')[-1]
            if rootname in uniquelist:
                pass
            else:
                uniquelist.append(rootname)
                temp_fh.write(name + "\n")
        temp_fh.close()
        cmd = ["perl", os.path.join(path, "mergePicardMetrics.pl"), "-files", "temp_fof", ">", outfilenames[i]]
        print >>sys.stderr, " ".join(cmd)
        subprocess.call(" ".join(cmd), shell=True)
    print >>sys.stderr, "Generated MarkDuplicate, and HsMetrics inputs without error"
    print >>sys.stderr, "Generating GCBias summary inputs..."
    os.unlink("temp_fof")
    filenames= find_files(path_to_search, pattern=args.gcbias_files)
    temp_fh = open("temp_fof", "wb")
    uniquelist = []
    for name in filenames:
        print name
        rootname = name.split('/')[-1]
        if rootname in uniquelist:
            pass
        else:
            uniquelist.append(rootname)
            temp_fh.write(name + "\n")
    temp_fh.close()
    cmd = ['python', os.path.join(path,'mergeGcBiasMetrics.py'), 'temp_fof', args.file_prefix + "_GcBiasMetrics.txt" ]
    rv = subprocess.call(cmd, shell=False)
    print >>sys.stderr, " ".join(cmd)
    print >>sys.stderr, "Generating Insert Size Histogram..."
    temp_fh = open("temp_fof", "wb")
    filenames = find_files(path_to_search, pattern=args.insertsize_files)
    uniquelist = []
    for name in filenames:
        print name
        rootname = name.split('/')[-1]
        if rootname in uniquelist:
            pass
        else:
            uniquelist.append(rootname)
            temp_fh.write(name + "\n")
    temp_fh.close()
    cmd = ['python', os.path.join(path,'mergeInsertSizeHistograms.py'), 'temp_fof', args.file_prefix + "_InsertSizeMetrics_Histograms.txt" ]
    print >>sys.stderr, " ".join(cmd)
    rv = subprocess.call(cmd, shell=False)
    if rv !=0:
        print >>sys.stderr, "Error Generating IS hist"
        sys.exit(1)
    print >>sys.stderr, "Insert Size Histogram Generated!"
    print >>sys.stderr, "Generating Fingerprint from DOC inputs..."
    temp_fh = open("temp_fof", "wb")
    filenames = find_files(path_to_search, pattern=args.fingerprint_files)
    uniquelist = []
    for name in filenames:
        rootname = name.split('/')[-1]
        if rootname in uniquelist:
            pass
        else:
            uniquelist.append(rootname)
            temp_fh.write(name + "\n")
    temp_fh.close()
    cmd = ['python', os.path.join(path, 'analyzeFingerprint.py'), '-pre', args.file_prefix, '-fp', args.fp_genotypes, 
            '-group', args.grouping_file, '-outdir', '.', '-pair', args.pairing_file, "-fof", 'temp_fof']
    print >>sys.stderr, " ".join(cmd)
    rv = subprocess.call(cmd, shell=False)
    if rv !=0:
        print >>sys.stderr, "Error Generating fingerprint..."
        sys.exit(1)
    print >>sys.stderr, "Fingerprint File Generated!"
    print >>sys.stderr, "Generating Qual Files..."
    temp_fh = open("temp_fof", "wb")
    filenames = find_files(path_to_search, pattern=args.qualmetrics_files)
    uniquelist = []
    for name in filenames:
        rootname = name.split('/')[-1]
        if rootname in uniquelist:
            pass
        else:
            uniquelist.append(rootname)
            temp_fh.write(name + "\n")
    temp_fh.close()
    cmd = ['python', os.path.join(path, 'mergeMeanQualityHistograms.py'), 'temp_fof', args.file_prefix + "_post_recal_MeanQualityByCycle.txt", args.file_prefix + "_pre_recal_MeanQualityByCycle.txt"]
    print >>sys.stderr, " ".join(cmd)
    rv = subprocess.call(cmd, shell=False)
    if rv !=0:
        print >>sys.stderr, "Error Generating Mean Quality..."
        sys.exit(1)
    print >>sys.stderr, "Qual Files Generated!"
    print >>sys.stderr, "Generating CutAdapt Summary.."
    temp_fh = open("temp_fof", "wb")
    filenames = find_files(path_to_search, pattern=args.trimgalore_files)
    uniquelist = []
    for name in filenames:
        print name
        rootname = name.split('/')[-1]
        if rootname in uniquelist:
            pass
        else:
            uniquelist.append(rootname)
            temp_fh.write(name + "\n")
    temp_fh.close()
    cmd = ['python', os.path.join(path,'mergeCutAdaptStats.py'), 'temp_fof', args.file_prefix + "_CutAdaptStats.txt", args.pairing_file]
    print >>sys.stderr, cmd
    rv = subprocess.call(cmd, shell=False)
    if rv !=0:
        print >>sys.stderr, "Error Generating PDF..."
        sys.exit(1)

    print >>sys.stderr, "CutadaptSummary Generated!"
    print >>sys.stderr, "GENERATING THE GOSH DARN PDF!"
    cmd = ['perl', os.path.join(path, 'qcPDF.pl'), '-pre', args.file_prefix, '-path', '.', '-log', 'qcPDF.log', '-request', args.request_file, '-version', '1.0', '-cov_warn_threshold', args.cov_warn_threshold, '-cov_fail_threshold', args.cov_fail_threshold, '-dup_rate_threshold', args.duplication_threshold, '-minor_contam_threshold', args.minor_contam_threshold, '-major_contam_threshold', args.major_contam_threshold]
    print >>sys.stderr, " ".join(cmd)
    rv = subprocess.call(cmd, shell=False)
    if rv !=0:
        print >>sys.stderr, "Error Generating PDF..."
        sys.exit(1)
    print >>sys.stderr, "PDF Generated!"
    


