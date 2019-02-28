# get actual output of the tool
exec /usr/bin/runscript.sh help 2>&1 | head -1 > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
usage: list2bed.py [-h] -i INPUT_FILE -o OUTPUT_FILE [-ns]
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