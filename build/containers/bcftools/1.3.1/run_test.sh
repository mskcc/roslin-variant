# get actual output of the tool
exec /usr/bin/runscript.sh help 2>&1 | sed -n "2p;3p;" > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
Program: bcftools (Tools for variant calling and manipulating VCFs and BCFs)
Version: 1.3.1 (using htslib 1.3.1)
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