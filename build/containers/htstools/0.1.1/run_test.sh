# get actual output from snp-pileup
exec /usr/bin/runscript.sh snp-pileup --help > /srv/actual.diff.txt
# get actual output from ppflag-fixer
exec /usr/bin/runscript.sh ppflag-fixer --help >> /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
Usage: snp-pileup [OPTION...] <vcf file> <output file> <sequence files...>

  -A, --count-orphans        Do not discard anomalous read pairs.
  -d, --max-depth=DEPTH      Sets the maximum depth. Default is 4000.
  -g, --gzip                 Compresses the output file with BGZF.
  -p, --progress             Show a progress bar. WARNING: requires additional
                             time to calculate number of SNPs, and will take
                             longer than normal.
  -P, --pseudo-snps=MULTIPLE Every MULTIPLE positions, if there is no SNP,
                             insert a blank record with the total count at the
                             position.
  -q, --min-map-quality=QUALITY   Sets the minimum threshold for mapping
                             quality. Default is 0.
  -Q, --min-base-quality=QUALITY   Sets the minimum threshold for base quality.
                             Default is 0.
  -r, --min-read-counts=READS   Comma separated list of minimum read counts for
                             a position to be output. Default is 0.
  -v, --verbose              Show detailed messages.
  -x, --ignore-overlaps      Disable read-pair overlap detection.
  -?, --help                 Give this help list
      --usage                Give a short usage message

Mandatory or optional arguments to long options are also mandatory or optional
for any corresponding short options.
Usage: ppflag-fixer [OPTION...] <input file> <output file>

  -m, --max-tlen=LENGTH      Sets a maximum bound of LENGTH on all fragments;
                             any greater and they won't be marked as proper
                             pair.
  -p, --progress             Keep track of progress through the file. This
                             requires the file to be indexed.
  -?, --help                 Give this help list
      --usage                Give a short usage message

Mandatory or optional arguments to long options are also mandatory or optional
for any corresponding short options.
EOM

# diff
exitCode=0
if ! cmp -s /srv/actual.diff.txt /srv/expected.diff.txt
then
  diff /srv/actual.diff.txt /srv/expected.diff.txt
  exitCode=1
fi
# delete tmp
rm -rf /srv/*.diff.txt
exit $exitCode