# get actual output of the tool
exec /usr/bin/runscript.sh help 2>&1 | head -9 > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM
**********************************************************************
Program: Delly
This is free software, and you are welcome to redistribute it under
certain conditions (GPL); for license details use '-l'.
This program comes with ABSOLUTELY NO WARRANTY; for details use '-w'.

Delly (Version: 0.7.7)
Contact: Tobias Rausch (rausch@embl.de)
**********************************************************************
EOM

# diff
exitCode=0
if ! cmp -s /srv/actual.diff.txt /srv/expected.diff.txt
then
	diff /srv/actual.diff.txt /srv/expected.diff.txt
	exitCode=1
fi
# delete tmp
rm -rf /srv/*.diff.txt
exit $exitCode