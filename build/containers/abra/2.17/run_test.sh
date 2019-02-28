# get actual output of abra
# Should pick out the abra version from the top of the help output
# INFO    Wed Oct 03 15:03:40 EDT 2018    Abra version: 2.17
# INFO    Wed Oct 03 15:03:40 EDT 2018    Abra params: [/usr/bin/
# abra.jar --help]
exec /usr/bin/runscript.sh help 2>&1 | grep -q "Abra version: 2.17" || { echo "no match" >&2; exit 1; }