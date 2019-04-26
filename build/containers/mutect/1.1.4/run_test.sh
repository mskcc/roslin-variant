# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh help | head -2)

# expected output
expected=$(cat << EOM
---------------------------------------------------------------------------------
The Genome Analysis Toolkit (GATK) v2.2-25-g2a68eab, Compiled 2012/11/08 10:30:02
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