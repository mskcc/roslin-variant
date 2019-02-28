# get actual output of the tool
exec /usr/bin/runscript.sh MarkDuplicates 2>&1 | grep "Version" > /srv/actual.diff.txt || true
exec /usr/bin/runscript.sh AddOrReplaceReadGroups 2>&1 | grep "Version" >> /srv/actual.diff.txt || true

# expected output
cat > /srv/expected.diff.txt << EOM
Version: 2.9.0-1-gf5b9f50-SNAPSHOT
Version: 2.9.0-1-gf5b9f50-SNAPSHOT
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