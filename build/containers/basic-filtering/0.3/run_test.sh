# get actual output of the tool

export CMO_RESOURCE_CONFIG=/usr/bin/basicfiltering/data/cmo_resources.json

actual=$(exec /usr/bin/runscript.sh mutect 2>&1 | grep "usage:")
actual=$actual$(exec /usr/bin/runscript.sh vardict 2>&1 | grep "usage:")
actual=$actual$(exec /usr/bin/runscript.sh complex 2>&1 | grep "usage:")

# expected output
expected=$(cat << EOM
usage: filter_mutect.py [options]usage: filter_vardict.py [options]usage: filter_complex.py [options]
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