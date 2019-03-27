# get actual output of the tool

exec /usr/bin/runscript.sh annotate 2>&1 | head -3 >> /srv/actual.diff.txt
exec /usr/bin/runscript.sh concat 2>&1 | head -3 >> /srv/actual.diff.txt
exec /usr/bin/runscript.sh tabix 2>&1 | head -3 >> /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM

About:   Annotate and edit VCF/BCF files.
Usage:   bcftools annotate [options] <in.vcf.gz>


About:   Concatenate or combine VCF/BCF files. All source files must have the same sample
         columns appearing in the same order. The program can be used, for example, to


Usage: bcftools tabix [options] <in.gz> [reg1 [...]]

EOM

# diff
exitCode=0
cat /srv/expected.diff.txt | tr -d "[:space:]" > /srv/expected.diff.txt
cat /srv/actual.diff.txt | tr -d "[:space:]" > /srv/actual.diff.txt
if ! cmp -s /srv/actual.diff.txt /srv/expected.diff.txt
then
	diff /srv/actual.diff.txt /srv/expected.diff.txt
	exitCode=1
fi
# delete tmp
rm -rf /srv/*.diff.txt
exit $exitCode