# get actual output of the tool
exec /usr/bin/runscript.sh --version > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM

                          Quality-/Adapter-/RRBS-Trimming
                               (powered by Cutadapt)
                                  version 0.2.5

                             Last update: 18 10 2012

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