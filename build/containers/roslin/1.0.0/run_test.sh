# get actual output of the tool
exec /usr/bin/runscript.sh help | head -1 > /srv/actual.diff.txt

# expected output
cat > /srv/expected.diff.txt << EOM

 ______     ______     ______     __         __     __   __
/\  == \   /\  __ \   /\  ___\   /\ \       /\ \   /\ "-.\ \
\ \  __<   \ \ \/\ \  \ \___  \  \ \ \____  \ \ \  \ \ \-.  \
 \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \_\  \ \_\\"\_\
  \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/   \/_/ \/_/
EOM

# diff
diff /srv/actual.diff.txt /srv/expected.diff.txt

# delete tmp
rm -rf /srv/*.diff.txt