# get actual output of the tool
exec /usr/bin/runscript.sh -jar --version > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
3.3-0-g37228af
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