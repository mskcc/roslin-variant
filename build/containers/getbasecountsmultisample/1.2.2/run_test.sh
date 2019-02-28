# get actual output of the tool
exec /usr/bin/runscript.sh | head -2 > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM

GetBaseCountsMultiSample 1.2.2
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