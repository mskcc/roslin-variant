# get actual output from generate_pdf
exec /usr/bin/runscript.sh generate_pdf 2>&1 | head -1 > /srv/actual.diff.txt

# expected generate_pdf output
cat > /srv/expected.diff.txt << EOM
usage: generate_pdf.py [-h] [--gcbias-files GCBIAS_FILES]
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