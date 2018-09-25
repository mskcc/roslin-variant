#!/usr/bin/perl

use strict;
use Getopt::Long qw(GetOptions);
use FindBin qw($Bin); 

###
### LSF AND SGE HANDLE QUOTES DEREFERENCING DIFFERENTLY
### SO STICKING IT IN A WRAPPER FOR SIMPLICITY
###

my ($pre, $path, $config, $logfile, $request, $version, $cov_warn_threshold, $dup_rate_threshold, $cov_fail_threshold, $minor_contam_threshold, $major_contam_threshold);
GetOptions ('pre=s' => \$pre,
	    'path=s' => \$path,
            'logfile=s' => \$logfile,
            'request=s' => \$request,
            'version=s' => \$version,
            'cov_warn_threshold=s' => \$cov_warn_threshold,
            'dup_rate_threshold=s' => \$dup_rate_threshold,
            'cov_fail_threshold=s' => \$cov_fail_threshold,
            'minor_contam_threshold=s' => \$minor_contam_threshold,
            'major_contam_threshold=s' => \$major_contam_threshold,
	   ) or exit(1);

if(!$pre || !$path  || !$request || !$logfile || !$version){
    die "MUST PROVIDE PRE, PATH, CONFIG, REQUEST FILE, SVN REVISION NUMBER AND OUTPUT\n";
}

my $JAVA = '/usr/bin/';
## generate a PDF file for each plot, a project summary text file and a sample summary text file
`qc_summary.R --pre=$pre --path=$path --bin=$Bin --logfile=$logfile --cov_warn_threshold=$cov_warn_threshold --cov_fail_threshold=$cov_fail_threshold --dup_rate_threshold=$dup_rate_threshold --minor_contam_threshold=$minor_contam_threshold --major_contam_threshold=$major_contam_threshold`;

#my $ec = $? >> 8;

## generate the complete, formal PDF report
#print "$JAVA/java -jar $Bin/QCPDF.jar -rf $request -v $version -d $path -o $path -cf $cov_fail_threshold -cw $cov_warn_threshold -pl Variants\n"; 
#`$JAVA/java -jar $Bin/QCPDF.jar -rf $request -v $version -d $path -o $path -cf $cov_fail_threshold -cw $cov_warn_threshold -pl Variants`;

#my $ec2 = $? >> 8;

#if($ec != 0 || $ec2 != 0){ die; }


