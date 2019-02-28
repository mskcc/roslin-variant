# get actual output from facets doFacets
exec /usr/bin/runscript.sh doFacets 2>&1 | head -1 > /srv/actual.diff.txt

# expected facets output
cat > /srv/expected.diff.txt << EOM
usage: facets doFacets [-h] [-c CVAL] [-s SNP_NBHD] [-n NDEPTH] [-m MIN_NHET]
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