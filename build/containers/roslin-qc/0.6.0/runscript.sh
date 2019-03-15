if [ "$1" = "help" ]
then
	echo "merge_cut_adapt_stats, analyze_fingerprint, qc_summary, merge_mean_quality_histograms, merge_gc_bias_metrics, merge_insert_size_histograms, merge_picard_metrics, stitch_pdf, hotspots_in_normals, or genlatex"
    exit 1
fi

export PYTHONNOUSERSITE="set"
case $1 in
    merge_cut_adapt_stats) shift; exec python /usr/bin/merge_cut_adapt_stats.py "$@" ;;
    analyze_fingerprint) shift; exec python /usr/bin/analyze_fingerprint.py "$@" ;;
    qc_summary) shift; exec Rscript /usr/bin/qc_summary.R "$@" ;;
    merge_mean_quality_histograms) shift; exec python /usr/bin/merge_mean_quality_histograms.py "$@" ;;
    merge_gc_bias_metrics) shift; exec python /usr/bin/merge_gc_bias_metrics.py "$@" ;;
    merge_insert_size_histograms) shift; exec python /usr/bin/merge_insert_size_histograms.py "$@" ;;
    merge_picard_metrics) shift; exec python /usr/bin/merge_picard_metrics.py "$@" ;;
    stitch_pdf) shift; exec java -jar /usr/bin/QCPDF.jar "$@" ;;
    generate_pdf) shift; exec python /usr/bin/generate_pdf.py "$@" ;;
    genlatex) shift; exec python /usr/bin/genlatex.py "$@" ;;
    create_cdna_contam) shift; exec python /usr/bin/create_cdna_contam.py "$@" ;;
    create_minor_contam_binlist) shift; exec python /usr/bin/create_minor_contam_binlist.py "$@" ;;
    create_hotspots_in_normal) shift; exec python /usr/bin/create_hotspots_in_normals.py "$@" ;;
    getbasecountsmultisample) shift; exec /usr/bin/GetBaseCountsMultiSample "$@" ;;
    *) echo "merge_cut_adapt_stats, analyze_fingerprint, qc_summary, merge_mean_quality_histograms, merge_gc_bias_metrics, merge_insert_size_histograms, merge_picard_metrics, stitch_pdf, hotspots_in_normals, or genlatex"; exit 1 ;;
esac