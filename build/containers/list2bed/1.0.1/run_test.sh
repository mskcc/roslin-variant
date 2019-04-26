# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh help 2>&1 | head -1)

# expected output
expected=$(cat << EOM
usage: list2bed.py [-h] -i INPUT_FILE -o OUTPUT_FILE [-ns]
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