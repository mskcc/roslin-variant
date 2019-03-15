# Set home env
export HOME=/usr/local/bin/
# Set path
export PATH=/usr/local/bin/:$PATH

# get actual output of the tool
exec /usr/bin/runscript.sh vcf2vcf.pl --help | head -2 > /srv/actual.diff.txt
exec /usr/bin/runscript.sh vcf2maf.pl --help | head -2 >> /srv/actual.diff.txt
exec /usr/bin/runscript.sh maf2maf.pl --help | head -2 >> /srv/actual.diff.txt
exec /usr/bin/runscript.sh maf2vcf.pl --help | head -2 >> /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
Usage:
    perl vcf2vcf.pl --help
Usage:
	perl vcf2maf.pl --help
Usage:
	perl maf2maf.pl --help
Usage:
	perl maf2vcf.pl --help
EOM
cat /srv/expected.diff.txt | tr -d "[:space:]" > /srv/expected.diff.txt
cat /srv/actual.diff.txt | tr -d "[:space:]" > /srv/actual.diff.txt
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