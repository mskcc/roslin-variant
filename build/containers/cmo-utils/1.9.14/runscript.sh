
export PYTHONNOUSERSITE="set"
unset LANG

if [ "$1" = "help" ]
then
	echo "cmo_split_reads, cmo_fillout, or cmo_index?"
	exit 1
fi

export PYTHONNOUSERSITE="set"
case $1 in
    cmo_split_reads) shift; exec cmo_split_reads "$@" ;;
	cmo_fillout) shift; exec cmo_fillout "$@" ;;
	cmo_index) shift; exec cmo_index "$@" ;;
    *) echo "cmo_split_reads, cmo_fillout, or cmo_index?"; exit 1 ;;
esac