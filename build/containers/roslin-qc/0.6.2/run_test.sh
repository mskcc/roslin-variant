# get actual output from generate_pdf
actual=$(exec /usr/bin/runscript.sh generate_pdf 2>&1 | head -1)

# expected generate_pdf output
expected=$(cat << EOM
usage: generate_pdf.py [-h] [--gcbias-files GCBIAS_FILES]
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