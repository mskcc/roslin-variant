# get actual output of the tool

actual=$(exec /usr/bin/runscript.sh cmo_split_reads 2>&1 | grep "usage:")
# expected output
expected=$(cat << EOM
usage: cmo_split_reads [-h] -f1 FASTQ1 [-f2 FASTQ2] -p PLATFORM_UNIT
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