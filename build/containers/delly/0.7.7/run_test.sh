# get actual output of the tool
actual=$(exec /usr/bin/runscript.sh help 2>&1 | head -9)

# expected output
expected=$(cat << EOM
**********************************************************************
Program: Delly
This is free software, and you are welcome to redistribute it under
certain conditions (GPL); for license details use '-l'.
This program comes with ABSOLUTELY NO WARRANTY; for details use '-w'.

Delly (Version: 0.7.7)
Contact: Tobias Rausch (rausch@embl.de)
**********************************************************************
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