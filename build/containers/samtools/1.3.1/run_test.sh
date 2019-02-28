# get actual output of the tool
exec /usr/bin/runscript.sh --version > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
samtools 1.3.1
Using htslib 1.3.1
Copyright (C) 2016 Genome Research Ltd.
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