# get actual output of the tool

actual=$(exec /usr/bin/runscript.sh annotate --help 2>&1 | head -4 | tail -3)
actual=$actual$(exec /usr/bin/runscript.sh concat 2>&1 | head -3)
actual=$actual$(exec /usr/bin/runscript.sh tabix 2>&1 | head -3)

# expected output
expected=$(cat << EOM

About:   Annotate and edit VCF/BCF files.
Usage:   bcftools annotate [options] <in.vcf.gz>

About:   Concatenate or combine VCF/BCF files. All source files must have the same sample
         columns appearing in the same order. The program can be used, for example, to

Version: 1.9
Usage:   tabix [OPTIONS] [FILE] [REGION [...]]

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