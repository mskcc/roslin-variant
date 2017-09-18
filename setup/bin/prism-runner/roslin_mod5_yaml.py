import os
import sys
import argparse
import logging
import cmo
import yaml
import tempfile
import shutil


logger = logging.getLogger('replace_allele_counts')
logger.propagate = False
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
ch.setFormatter(formatter)
logger.addHandler(ch)


def find_files(searchdir):
    bams = []
    md_metrics = []
    trim_metrics = []
    mapping = None
    pairing = None
    grouping = None
    request = None
    for root, dirs, files in os.walk(searchdir):
        for filename in files:
            if filename.find("mapping.txt") > -1:
                mapping = os.path.join(root, filename)
            elif filename.find("grouping.txt") > -1:
                grouping = os.path.join(root, filename)
            elif filename.find("request.txt") > -1:
                request = os.path.join(root, filename)
            elif filename.find("pairing.txt") > -1:
                pairing = os.path.join(root, filename)
            elif filename.find(".printreads.bam") > -1:
                bams.append(os.path.join(root, filename))
            elif filename.find(".md_metrics") > -1:
                md_metrics.append(os.path.join(root, filename))
            elif filename.find("_cl.stats") > -1:
                trim_metrics.append(os.path.join(root, filename))
    return (bams, md_metrics, trim_metrics, mapping, pairing, request, grouping)


def get_project_prefix(request_file):
    yaml_obj = yaml.load(open(request_file))
    return yaml_obj['ProjectID']


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="run another qc starting from a project directory")
    parser.add_argument("-d", "--dir", help="directory to pipeline outputs", required=True)
    parser.add_argument("-m", help="optionally directly supply the mapping file..we'll try to locate this in project dir if left blank")
    parser.add_argument("-p", help="optionally directly supply the pairing file..we'll try to locate this in project dir if left blank")
    parser.add_argument("-g", help="optionally directly supply the grouping file..we'll try to locate this in project dir if left blank")
    parser.add_argument("-r", help="optionally directly supply the request file..we'll try to locate this in project dir if left blank")
    parser.add_argument("-t", "--targets", choices=cmo.util.targets.keys(), help="use an installed bait/target combo")
    parser.add_argument("-rt", "--raw-targets-file", help="use a properly formatted picard intervals target file of your own. Warning, must end in .intervals for some versions of picard.")
    parser.add_argument("-rb", "--raw-baits-file", help="use a properly formatted picard intervals bait file of your own. Warning, must end in .intervals for some versions of picard.")
    parser.add_argument("--execute", help="execute command, and cleanup tempdir. if not specified, prints command for you to execute instead", action="store_true")
    # FIXME someday this needs to select genome string as well
    args = parser.parse_args()
    if args.targets and args.raw_targets_file:
        logger.critical("You can't use both targets and raw-targets-file, boss.")
        sys.exit(1)
    elif not args.targets and (not args.raw_baits_file or not args.raw_targets_file):
        logger.critical("You have to supply at least 'targets', or both 'raw' files, you 'tater head.")
        sys.exit(1)
    searchdir = os.path.abspath(args.dir)
    (bams, md_metrics, trim_metrics, mapping, pairing, request, grouping) = find_files(searchdir)
    logger.info("Found: %s bams" % len(bams))
    logger.info("Found %s mark dup stat files" % len(md_metrics))
    logger.info("Found: %s trim stat files" % len(trim_metrics))
    out = {}
    bams = [{"class": "File", "path": x} for x in bams]
    md_metrics = [[{"class": "File", "path": x}] for x in md_metrics]
    trim_metrics = [[{"class": "File", "path": x}] for x in trim_metrics]
    out['project_prefix'] = get_project_prefix(request)
    out['bams'] = bams
    out['genome'] = 'GRCh37'
    out['request_file'] = {"class": "File", "path": str(request)}
    out['pairing_file'] = {"class": "File", "path": str(pairing)}
    out['grouping_file'] = {"class": "File", "path": str(grouping)}
    out['mapping_file'] = {"class": "File", "path": str(mapping)}
    out['md_metrics_files'] = md_metrics
    out['trim_metrics_files'] = trim_metrics
    if args.targets:
        logger.info("using %s targets, filepath: %s" % (args.targets, cmo.util.targets[args.targets]['targets_list']))
        logger.info("using %s baits, filepath: %s" % (args.targets, cmo.util.targets[args.targets]['baits_list']))
        out['bait_intervals'] = {"class": "File", "path": str(cmo.util.targets[args.targets]['baits_list'])}
        out['target_intervals'] = {"class": "File", "path": str(cmo.util.targets[args.targets]['targets_list'])}
        out['fp_intervals'] = {"class": "File", "path": str(cmo.util.targets[args.targets]['FP_intervals'])}
        out['fp_genotypes'] = {"class": "File", "path": str(cmo.util.targets[args.targets]['FP_genotypes'])}

    else:
        logger.info("using supplied targets, filepath: %s" % (args.raw_targets_file))
        logger.info("using supplied baits, filepath: %s" % (args.raw_baits_file))
        # use fp intervals from another target bc they are all the same
        # potential FIXME
        out['bait_intervals'] = {"class": "File", "path": str(os.path.abspath(args.raw_targets_file))}
        out['target_intervals'] = {"class": "File", "path": str(os.path.abspath(args.raw_baits_file))}
        out['fp_intervals'] = {"class": "File", "path": str(cmo.util.targets['IMPACT468']['FP_intervals'])}
        out['fp_genotypes'] = {"class": "File", "path": str(cmo.util.targets['IMPACT468']['FP_genotypes'])}

    tempdir = tempfile.mkdtemp()
    os.chdir(tempdir)
    shutil.copy(request, tempdir)
    shutil.copy(mapping, tempdir)
    shutil.copy(pairing, tempdir)
    shutil.copy(grouping, tempdir)
    final_file = open("inputs.yaml", "w")
    yaml.dump(out, final_file, default_flow_style=True)
    final_file.close()
    cmd = ["roslin_submit.py", "--id", out['project_prefix'], '--path', tempdir, '--workflow', 'module-5.cwl']
    if args.execute:
        logger.info("Executing %s" % " ".join(cmd))
        subprocess.call(cmd)
        logger.info("Cleaning up temp...")
        shutil.rmtree(tempdir)
    logger.info("All Done.")
