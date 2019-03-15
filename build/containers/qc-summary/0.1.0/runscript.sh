if [ "$1" = "help" ]
then
	echo "qc_summary or generate_pdf"
	exit 1
fi

case $1 in
    qc_summary) shift; exec Rscript /usr/bin/qc_summary.R "$@" ;;
    generate_pdf) shift; exec python /usr/bin/generate_pdf.py "$@" ;;
    *) echo "qc_summary or generate_pdf"; exit 1 ;;
esac