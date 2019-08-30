# get actual output from pileup
actual=$(exec /usr/bin/runscript.sh pileup help 2>&1 | head -1)
# get actual output from concordance
actual=$actual$(exec /usr/bin/runscript.sh concordance help 2>&1 | head -1)
# get actual output from contamination
actual=$actual$(exec /usr/bin/runscript.sh contamination help 2>&1 | head -1)

# expected output from pileup output
expected=$(cat << EOM
Usage: run_gatk_pileup_for_sample.py [options]usage: verify_concordances.py [options]usage: estimate_tumor_normal_contaminations.py [options]
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