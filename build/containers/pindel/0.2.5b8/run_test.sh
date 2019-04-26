# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh pindel -h | head -2)
actual=$actual$(exec /usr/bin/runscript.sh pindel2vcf -h | head -3)

# expected output
expected=$(cat << EOM
Initializing parameters...
Pindel version 0.2.5b8, 20151210.
Program:    pindel2vcf (conversion of Pindel output to VCF format)
Version:    0.6.3
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