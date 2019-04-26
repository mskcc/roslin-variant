# Set home env
export HOME=/usr/local/bin/
# Set path
export PATH=/usr/local/bin/:$PATH

# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh vcf2vcf.pl --help | head -2)
actual=$actual$(exec /usr/bin/runscript.sh vcf2maf.pl --help | head -2)
actual=$actual$(exec /usr/bin/runscript.sh maf2maf.pl --help | head -2)
actual=$actual$(exec /usr/bin/runscript.sh maf2vcf.pl --help | head -2)

# expected output
expected=$(cat << EOM
Usage:
    perl vcf2vcf.pl --helpUsage:
	perl vcf2maf.pl --helpUsage:
	perl maf2maf.pl --helpUsage:
	perl maf2vcf.pl --help
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