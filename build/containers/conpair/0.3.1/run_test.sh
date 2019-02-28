# get actual output from pileup
exec /usr/bin/runscript.sh pileup help 2>&1 | head -1 >> /srv/actual.diff.txt
# get actual output from concordance
exec /usr/bin/runscript.sh concordance help 2>&1 | head -1 >> /srv/actual.diff.txt
# get actual output from contamination
exec /usr/bin/runscript.sh contamination help 2>&1 | head -1 >> /srv/actual.diff.txt

# expected output from pileup output
cat > /srv/expected.diff.txt << EOM
Usage: run_gatk_pileup_for_sample.py [options]
usage: verify_concordances.py [options]
usage: estimate_tumor_normal_contaminations.py [options]
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