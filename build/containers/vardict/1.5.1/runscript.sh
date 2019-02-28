if [ "$1" == "help" ]
then
	echo "vardict, testsomatic.R, var2vcf_paired.pl?"
	exit 1
fi

case $1 in
    vardict) shift; exec /usr/bin/vardict/bin/VarDict "$@" ;;
    testsomatic.R) shift; exec /usr/bin/Rscript --vanilla /usr/bin/vardict/testsomatic.R ;;
    var2vcf_paired.pl) shift; exec /usr/bin/perl /usr/bin/vardict/var2vcf_paired.pl "$@" ;;
    *) echo "vardict, testsomatic.R, var2vcf_paired.pl?"; exit 1 ;;
esac