# get actual output of the tool
exec /usr/bin/runscript.sh pindel -h | head -2 > /srv/actual.diff.txt
exec /usr/bin/runscript.sh pindel2vcf -h | head -3  >> /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
Initializing parameters...
Pindel version 0.2.5b8, 20151210.

Program:    pindel2vcf (conversion of Pindel output to VCF format)
Version:    0.6.3
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