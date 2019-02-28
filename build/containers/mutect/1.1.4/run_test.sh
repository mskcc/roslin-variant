# get actual output of the tool
exec /usr/bin/runscript.sh help | head -2 > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
---------------------------------------------------------------------------------
The Genome Analysis Toolkit (GATK) v2.2-25-g2a68eab, Compiled 2012/11/08 10:30:02
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