# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh --version)

# expected output
expected=$(cat << EOM
samtools 1.3.1
Using htslib 1.3.1
Copyright (C) 2016 Genome Research Ltd.
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