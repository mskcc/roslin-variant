# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh --version)

# expected output
expected=$(cat << EOM

                          Quality-/Adapter-/RRBS-Trimming
                               (powered by Cutadapt)
                                  version 0.2.5

                             Last update: 18 10 2012

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