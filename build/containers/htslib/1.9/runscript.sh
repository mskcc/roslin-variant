if [ "$1" = "help" ]
then
	echo "concat, annotate, or tabix?"
	exit 1
fi

export PYTHONNOUSERSITE="set"

case $1 in
	annotate) shift; exec /usr/bin/bcftools annotate "$@" ;;
    concat) shift; exec /usr/bin/bcftools concat "$@" ;;
    tabix) shift; exec /usr/local/bin/tabix "$@" ;;
    *) echo "annotate, concat, or tabix?"; exit 1 ;;
esac