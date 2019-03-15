if [ "$1" = "help" ]
then
	echo "Please use either doFacets, mafAnno, normDepth, geneLevel, or mergeTN"
	exit 1
fi
export PYTHONNOUSERSITE="set"
export FACETS_OVERRIDE_EXITCODE="set"

case $1 in
    doFacets) shift; exec python /usr/bin/facets-suite/facets doFacets "$@" ;;
    mafAnno) shift; exec python /usr/bin/facets-suite/facets mafAnno "$@" ;;
    normDepth) shift; exec python /usr/bin/facets-suite/facets normDepth "$@" ;;
    geneLevel) shift; exec python /usr/bin/facets-suite/facets geneLevel "$@" ;;
    mergeTN) shift; exec python /usr/bin/facets-suite/facets mergeTN "$@" ;;
    *) echo "Please use either doFacets, mafAnno, normDepth, geneLevel, or mergeTN"; exit 1 ;;
esac