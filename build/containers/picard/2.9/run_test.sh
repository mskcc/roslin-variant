# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh -jar MarkDuplicates 2>&1 | grep -o "Version: 2.9.0-1-gf5b9f50-SNAPSHOT")
actual=$actual$(exec /usr/bin/runscript.sh -jar AddOrReplaceReadGroups 2>&1 | grep -o "Version: 2.9.0-1-gf5b9f50-SNAPSHOT")

# expected output
expected=$(cat << EOM
Version: 2.9.0-1-gf5b9f50-SNAPSHOTVersion: 2.9.0-1-gf5b9f50-SNAPSHOT
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