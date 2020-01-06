# get actual output from facets doFacets
actual=$(exec /usr/bin/runscript.sh doFacets 2>&1 | head -1)

# expected facets output
expected=$(cat << EOM
usage: facets doFacets [-h] [-c CVAL] [-s SNP_NBHD] [-n NDEPTH] [-m MIN_NHET]
EOM
)

expected_no_space=$(echo $expected | tr -d "[:space:]")
actual_no_space=$(echo $actual | tr -d "[:space:]")
# diff
if [ "$actual_no_space" != "$expected_no_space" ]
then
    echo "-----expected-----"
    echo $expected
    echo "-----actual-----"
    echo $actual
    exit 1
fi