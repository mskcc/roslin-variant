if [ "$1" = "help" ]
then
	echo "concat, annotate, or tabix?"
	exit 1
fi

case $1 in
	annotate) shift; exec /usr/bin/bcftools annotate "$@" ;;
    concat) shift; exec /usr/bin/bcftools concat "$@" ;;
    tabix) shift; exec /usr/local/bin/tabix "$@" ;;
    *) echo "concat, annotate, or tabix?"; exit 1 ;;
esac